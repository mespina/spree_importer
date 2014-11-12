module SpreeImporter
  class Engine < Rails::Engine
    require 'spree/core'
    isolate_namespace Spree
    engine_name 'spree_importer'

    config.autoload_paths += %W(#{config.root}/lib)

    # use rspec for tests
    config.generators do |g|
      g.test_framework :rspec
    end

    initializer "spree.importer.preferences", :before => :load_config_initializers do |app|
      Spree::AppConfiguration.class_eval do
        # Setting notification email
        preference :importer_from, :string, :default => 'notification@importer.com'
        preference :importer_to,   :string, :default => 'notification@importer.com'

        # Setting path to example CSV file
        preference :sample_file,   :string, :default => Rails.root.join('lib/templates/example.csv')

        # Setting a step to log progress status
        preference :log_progress_every, :integer, :default => 10

        # Verbose
        preference :verbose, :boolean, :default => true

        # Setting to skip loading if product already exists
        preference :skip_if_product_exists, :boolean, :default => true
      end
    end

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), '../../app/**/*_decorator*.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end

      Dir.glob(File.join(File.dirname(__FILE__), '../../app/workers/*_worker.rb')) do |c|
        Rails.configuration.cache_classes ? require(c) : load(c)
      end
    end

    config.to_prepare &method(:activate).to_proc
  end
end
