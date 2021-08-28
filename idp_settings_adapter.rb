module Saml
  class IdpSettingsAdapter
    def self.settings(idp_entity_id)
      certificates = [
        AdminSettings::SAML.instance.idp_cert,
        AdminSettings::SAML.instance.old_idp_cert # `nil` unless a certificate is being rotated
      ].compact

      {
        security: {
          signature_method: XMLSecurity::Document::RSA_SHA256
        },
        assertion_consumer_service_url: "https://#{Settings.basic.base_domain}/users/saml/auth",
        assertion_consumer_service_binding: "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST",
        name_identifier_format: "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress",
        issuer: "https://#{Settings.basic.base_domain}/users/saml/metadata",
        idp_slo_target_url: AdminSettings::SAML.instance.slo_endpoint_url,
        idp_sso_target_url: AdminSettings::SAML.instance.sso_endpoint_url,
        idp_cert_multi: {
          signing: certificates,
          encryption: certificates
        }
      }
    end
  end
end
