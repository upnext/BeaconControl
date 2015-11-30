# Be sure to restart your server when you modify this file.
if AppConfig.landing_page_url
  Rails.application.config.session_store :cookie_store, key: '_beacon_os_session', domain: :all
else
  Rails.application.config.session_store :cookie_store, key: '_beacon_os_session', domain: :all
end
