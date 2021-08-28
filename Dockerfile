FROM cf0b0e4b120f

#COPY idp_settings_adapter.rb /app/lib/saml/
COPY devise_saml_authenticatable.rb /app/config/initializers/

ENTRYPOINT ["/usr/bin/init.sh"]
