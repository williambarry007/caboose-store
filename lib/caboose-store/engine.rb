
require 'caboose'

module CabooseStore
  class Engine < ::Rails::Engine
    isolate_namespace CabooseStore
    
    # Inject assets
    Caboose::javascripts << 'caboose_store/application'
    Caboose::stylesheets << 'caboose_store/application'
    
    initializer 'caboose_store.assets.precompile' do |app|            
      app.config.assets.precompile += [
        # Images
        'caboose_store/caboose_logo_small.png',
        'caboose_store/caboose_nav_black.png',
        'caboose_store/caboose_nav.png',
        'caboose_store/default_user_pic.png',
        'caboose_store/loading_green.gif',
        'caboose_store/loading_small_white_on_black.gif',
        'caboose_store/loading_white_on_black.gif',
        # Javascript
        # 'caboose_store/admin_products.js',
        # 'caboose_store/admin.js',
        # 'caboose_store/application.js',
        # 'caboose_store/modal_integration.js',
        # 'caboose_store/modal.js',
        # 'caboose_store/model.form.page.js',
        # 'caboose_store/model.form.user.js',
        # 'caboose_store/shortcut.js',
        # 'caboose_store/station.js',
        'caboose_store/*.js',
        # CSS
        # 'caboose_store/admin_products.css',
        # 'caboose_store/admin.css',
        # 'caboose_store/application.css',
        # 'caboose_store/bound_input.css',
        # 'caboose_store/caboose.css',
        # 'caboose_store/fonts/big_noodle_titling_oblique.ttf',
        # 'caboose_store/fonts/big_noodle_titling.ttf',
        # 'caboose_store/fonts.css',
        # 'caboose_store/login.css',
        # 'caboose_store/modal.css',
        # 'caboose_store/page_bar_generator.css',
        # 'caboose_store/register.css',
        # 'caboose_store/station_modal.css',
        # 'caboose_store/station_sidebar.css',
        # 'caboose_store/tinymce.css',
        'caboose_store/*.css'
      ]      
    end
    
    initializer 'caboose_store.smtp_config' do |app|
      app.config.action_mailer.smtp_settings = CabooseStore::smtp_settings
    end
    
    initializer 'caboose_store.shipping_login' do |app|
      app.config.shipping = CabooseStore::shipping
    end
    
    initializer 'caboose_store.payment_processor', after: :finish_hook do |app|
      case CabooseStore::payment_processor
        when 'authorize.net' then CabooseStore::PaymentProcessor = CabooseStore::PaymentProcessors::AuthorizeNet
        when 'payscape'      then CabooseStore::PaymentProcessor = CabooseStore::PaymentProcessors::Payscape
      end
    end
  end
end

      