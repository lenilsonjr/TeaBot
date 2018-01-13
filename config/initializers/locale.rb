# Where the I18n library should search for translation files
I18n.load_path += Dir[Rails.root.join('lib', 'config/locales', '*.{rb,yml}')]

I18n.config.enforce_available_locales = false
I18n.config..available_locales = ["pt-BR"]
# Set default locale to something other than :en
I18n.default_locale = :'pt-BR'
