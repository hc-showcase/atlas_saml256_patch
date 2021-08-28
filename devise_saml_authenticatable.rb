  [mkaesz@tfe ~]$ cat atlas-patch/devise_saml_authenticatable.rb
# ==> Configuration for :saml_authenticatable
#
# We run this as an #after_initialize block because we will rely on Vault to
#   fetch encrypted values in AdminSettings, and the Vault initializer runs
#   relatively late in the initializer process (because alphabets.)
#
Atlas::Application.config.after_initialize do
  Devise.setup do |config|
    # Create user if the user does not exist. (Default is false)
    #
    config.saml_create_user = true

    # Update the attributes of the user after a successful login.
    #   (Default is false)
    #
    config.saml_update_user = true

    # Set the default user key. The user will be looked up by this key. Make sure
    #   that the Authentication Response includes the attribute.
    #
    config.saml_default_user_key = :email

    # Optional. This stores the session index defined by the IDP during login.  If
    #   provided it will be used as a salt for the user's session to facilitate an
    #   IDP initiated logout request.
    #
    config.saml_session_index_key = :session_index

    # You can set this value to use Subject or SAML assertation as info to which
    #   email will be compared. If you don't set it then email will be extracted
    #   from SAML assertation attributes.
    #
    config.saml_use_subject = true

    # You can support multiple IdPs by setting this value to a class that
    #   implements a #settings method which takes an IdP entity id as an argument
    #   and returns a hash of idp settings for the corresponding IdP.
    #
    config.idp_settings_adapter = Saml::IdpSettingsAdapter

    # You provide you own method to find the idp_entity_id in a SAML message in
    #   the case of multiple IdPs by setting this to a custom reader class, or use
    #   the default.
    #
    # config.idp_entity_id_reader = DeviseSamlAuthenticatable::DefaultIdpEntityIdReader

    # You can set a handler object that takes the response for a failed SAML
    #   request and the strategy, and implements a #handle method. This method can
    #   then redirect the user, return error messages, etc.
    #
    config.saml_failed_callback = SAML::ErrorManager

    # Configure with your SAML settings (see [ruby-saml][] for more information).
    #
    config.saml_configure do |settings|
      # Local endpoint where the IdP sends the SAML response
      #
      settings.assertion_consumer_service_url =
        "https://#{Settings.basic.base_domain}/users/saml/auth"

      settings.assertion_consumer_service_binding =
       "urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
      settings.name_identifier_format = "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"

      settings.issuer        = "#{Settings.basic.pretty_url}/users/saml/metadata"
      settings.authn_context = nil
      settings.security[:signature_method] = XMLSecurity::Document::RSA_SHA256


      # The IdP URL that TFE will send logout requests to
      # Example:
      #
      # settings.idp_slo_target_url =
      #   "https://hashicorp.onelogin.com/trust/saml2/http-redirect/slo/708088"
      #
      settings.idp_slo_target_url = nil

      # The IdP URL that TFE will send login requests to
      # Example:
      #
      # settings.idp_sso_target_url =
      #   "https://hashicorp.onelogin.com/trust/saml2/http-redirect/sso/708088"
      #
      settings.idp_sso_target_url = nil

      # Used to decode the signature included in the SAML response
      #
      # Example:
      #
      #      settings.idp_cert =  <<-CERT.chomp
      # -----BEGIN CERTIFICATE-----
      # MIIEHTCCAwWgAwIBAgIUE0JwGxa2JCZLgFF09uC4QBi6+B0wDQYJKoZIhvcNAQEF
      # BQAwWjELMAkGA1UEBhMCVVMxEjAQBgNVBAoMCUhhc2hpQ29ycDEVMBMGA1UECwwM
      # T25lTG9naW4gSWRQMSAwHgYDVQQDDBdPbmVMb2dpbiBBY2NvdW50IDEwNjUxNzAe
      # Fw0xNzA1MTAxNzIwMTNaFw0yMjA1MTExNzIwMTNaMFoxCzAJBgNVBAYTAlVTMRIw
      # EAYDVQQKDAlIYXNoaUNvcnAxFTATBgNVBAsMDE9uZUxvZ2luIElkUDEgMB4GA1UE
      # AwwXT25lTG9naW4gQWNjb3VudCAxMDY1MTcwggEiMA0GCSqGSIb3DQEBAQUAA4IB
      # DwAwggEKAoIBAQDYqsVOqBatYwDzHghUYqstW2ZHnO3XYveoN5/umBD3bdK0ixg+
      # NAiPSJW6Tk1eT6N+9ZzuhaOIIWS4VyWth07/uWmr/twKSHYFHttXar1J6rFQuYRC
      # x5Ka/1Whe2Xmp1S7BZ7kN0mlODHFKk1G7iyMCs5xjbveC1D4m+PKOTmtaEGJXr0s
      # ohIEQXuZTott4wUKjh5r6zGycB98PagyhKa2oC1Ox4Zp+arzsBv2Gzxa6TJCx3ZW
      # Xco4hFuVVWsS9PlwJxctMBGQaziFYU/J8Q2PEqYme8Fp697iVHvJ3/90ObxZ7jl4
      # k9r2PRXMHtL0UaCu+qA7qSIh/aUxysvq27D7AgMBAAGjgdowgdcwDAYDVR0TAQH/
      # BAIwADAdBgNVHQ4EFgQUQgyQJhzft3+Ym4A4OJzYrR8fuKowgZcGA1UdIwSBjzCB
      # jIAUQgyQJhzft3+Ym4A4OJzYrR8fuKqhXqRcMFoxCzAJBgNVBAYTAlVTMRIwEAYD
      # VQQKDAlIYXNoaUNvcnAxFTATBgNVBAsMDE9uZUxvZ2luIElkUDEgMB4GA1UEAwwX
      # T25lTG9naW4gQWNjb3VudCAxMDY1MTeCFBNCcBsWtiQmS4BRdPbguEAYuvgdMA4G
      # A1UdDwEB/wQEAwIHgDANBgkqhkiG9w0BAQUFAAOCAQEAkrbaoePzLTxFmnUVqJ3u
      # KcEV3HecrWK6pv0V1oGVhdv3OZvLhL5Vi2qDC1uSflKVndfZZQu7gAuKCXBDBBN2
      # pVuZI+zl398F8l9Tk87CHpj22+pz+3+F3AAj7gYKUxd+8Yx+D6hLKTUidKq5syet
      # y54fWKJiR7DbyTOIb+0kiHEdf+DJ7h3gQKlOxs6zLOp8CuQkaIJcicUuk/zEZzsS
      # Hjv7AadRRwcjYltGkVG1fSCDEfuHZz3sZQKLx3YLpqo19q2ehbXhqUhYsz/lTEl9
      # xWPoLZ2wYaOCWUNDzQpbe5RCdbHE1GrPVzkVxOrgYlVoBL74qwRV3NnJEqIBK/jN
      # Eg==
      # -----END CERTIFICATE-----
      #    CERT
      #
      settings.idp_cert = nil

      # This is nasty. There's no hiding that fact. How do we ensure these models work
      # during the `after_initialize` process?
      begin
        connection = ApplicationRecord.connection

        if connection.data_source_exists?(:admin_settings_saml) && connection.migration_context.get_all_versions.any? { |id| id == 20200309032118 }
          settings.certificate = AdminSettings::SAML.instance.certificate
          settings.private_key = AdminSettings::SAML.instance.private_key

          settings.security[:authn_requests_signed] = AdminSettings::SAML.instance.authn_requests_signed
          settings.security[:want_assertions_signed] = AdminSettings::SAML.instance.want_assertions_signed
        end
      rescue PG::ConnectionBad, ActiveRecord::NoDatabaseError
        # In this instance, for CircleCI I believe that we're just not providing the database
        # which is leading to a failure to connect to postgresql.
      end
    end
  end
end
