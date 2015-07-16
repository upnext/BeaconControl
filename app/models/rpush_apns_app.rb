###
# Copyright (c) 2015, Upnext Technologies Sp. z o.o.
# All rights reserved.
#
# This source code is licensed under the BSD 3-Clause License found in the
# LICENSE.txt file in the root directory of this source tree. 
###

class RpushApnsApp
  include Virtus.model

  attribute :cert_p12
  attribute :cert_pem
  attribute :passphrase, String, default: ''
  attribute :environment
  attribute :application

  #
  # Buils +Rpush::Apns::App+ with given attributes from params.
  #
  def app
    if cert_p12.blank?
      rpush_app.errors.add(:certificate, :blank)
      return rpush_app
    end

    rpush_app.name        = "APNS #{application.name} - #{environment} (#{application.id})"
    rpush_app.password    = passphrase
    rpush_app.certificate = pem_content
    rpush_app
  end

  private

  def rpush_app
    @rpush_app ||= Rpush::Apns::App.where(
      environment: environment,
      application_id: application.id
    ).first_or_initialize
  end

  #
  # Reads certificate file content and returns as String.
  #
  def pem_content # :doc:
    cert_p12_content = cert_p12.read

    begin
      pkcs12 = OpenSSL::PKCS12.new(cert_p12_content, passphrase)
      "#{pkcs12.certificate}#{pkcs12.key}"
    rescue OpenSSL::PKCS12::PKCS12Error => e
      rpush_app.errors.add(:password, I18n.t("models.rpush_apns.passphrase_error"))
      rpush_app.errors.add(:certificate, I18n.t("models.rpush_apns.cert_error"))

      Rails.logger.error e.message
      Rails.logger.error e.backtrace.join("\n")
    end
  end

  def env_name
    raise NotImplementedError
  end

  def default_values
    self.environment ||= env_name
  end
end
