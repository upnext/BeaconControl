require "active_support/log_subscriber"

module Rails
  module Rack
    class Logger < ActiveSupport::LogSubscriber
      alias_method :original_started_request_message,
        :started_request_message

      def started_request_message(request)
        RequestInfo.new(request)
        original_started_request_message(request)
      end

      private

      class RequestInfo
        def initialize(request)
          self.request = request
          set_correlation_id
          set_request_env
          set_entry_point
        end

        private

        attr_accessor :access_token, :request

        NullRecord = Naught.build

        def set_entry_point
          Thread.current[:entry_point] = entry_point
        end

        def set_request_env
          Thread.current[:request_env] = request.env
        end

        def set_correlation_id
          @correlation_id ||= if authentication_request?
                                generate_new_correlation_id
                              elsif api_v1_call?
                                fetch_mobile_device_correlation_id
                              elsif status_call?
                                ''
                              else
                                fetch_admin_correlation_id
                              end

          Thread.current[:request_correlation_id] = @correlation_id
        end

        def correlation_id
          @correlation_id || Thread.current[:request_correlation_id]
        end

        def authentication_request?
          asks_for_api_v1_token? || asks_for_s2s_api_token? || signs_in_to_admin_ui?
        end

        def asks_for_api_v1_token?
          request.post? && request.path_info.starts_with?("/api/v1/oauth/token")
        end

        def asks_for_s2s_api_token?
          request.post? && request.path_info.starts_with?("/s2s_api/v1/oauth/token")
        end

        def signs_in_to_admin_ui?
          request.post? && request.path_info.starts_with?("/admins/sign_in")
        end

        def status_call?
          request.path_info =~ /\/status/
        end

        def api_v1_call?
          request.path_info =~ /\/api\/v1\//
        end

        def s2s_api_call?
          request.path_info =~ /\/s2s_api\/v1\//
        end

        def assets_call?
          (request.path_info =~ /\/assets/) || (request.path_info =~ /\/uploads/)
        end

        def mobile_call?
          (request.path_info =~ /^\/mobile/)
        end

        def entry_point
          if api_v1_call?
            "api_v1"
          elsif s2s_api_call?
            "s2s_api"
          elsif assets_call?
            "assets"
          elsif mobile_call?
            "mobile"
          elsif status_call?
            "status"
          else
            "admin_ui"
          end
        end

        def generate_new_correlation_id
          SecureRandom.uuid
        end

        def mobile_device
          MobileDevice.where(id: access_token_record.resource_owner_id).first ||
            NullRecord.new
        end

        def fetch_mobile_device_correlation_id
          mobile_device.correlation_id
        end

        def fetch_admin_correlation_id
          (admin_from_session.presence || admin_from_access_token.presence ||
            NullRecord.new).correlation_id
        end

        def admin_from_access_token
          Admin.where(id: access_token_record.resource_owner_id).first if access_token
        end

        def admin_id_from_session
          decrypt_session_cookie["warden.user.admin.key"].first
        end

        def admin_from_session
          if admin_id = admin_id_from_session
            Admin.where(id: admin_id).first
          end
        rescue
          nil
        end

        def access_token_record
          Doorkeeper::AccessToken.where(token: access_token).first ||
            NullRecord.new
        end

        def access_token
          request.query_parameters[:access_token] ||
            request.headers["Authorization"].to_s.split(" ").last
        end

        def decrypt_session_cookie
          config       = Rails.application.config
          cookie       = CGI::unescape(request.cookies[config.session_options[:key]])
          key          = Rails.application.secrets.secret_key_base
          key_iter_num = 1000
          salt         = config.action_dispatch.encrypted_cookie_salt
          signed_salt  = config.action_dispatch.encrypted_signed_cookie_salt

          key_generator = ActiveSupport::KeyGenerator.new(key, iterations: key_iter_num)
          secret = key_generator.generate_key(salt)
          sign_secret = key_generator.generate_key(signed_salt)

          encryptor = ActiveSupport::MessageEncryptor.new(secret, sign_secret, serializer: JSON)
          encryptor.decrypt_and_verify(cookie)
        end
      end
    end
  end
end
