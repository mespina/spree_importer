#encoding: utf-8

require 'roo'
require 'httparty'

module SpreeImporter
  class Importer
    def initialize filename, filepath, options={}
      @filename = filename
      @filepath = filepath

      @spreadsheet = nil

      @product_identifier = ProductIdentifier.new('A', :name)

      @mappers = []
      @mappers << Mappers::ProductMapper.new('A', :name)
      @mappers << Mappers::ProductMapper.new('B', :sku)
      @mappers << Mappers::ProductMapper.new('C', :prototype_id)
      @mappers << Mappers::ProductMapper.new('D', :price)
      @mappers << Mappers::ProductMapper.new('E', :available_on)
      @mappers << Mappers::ProductMapper.new('F', :shipping_category_id)
    end

    # Load a file and the get data from each file row
    def load_products
      puts I18n.t(:reading, scope: [:spree, :spree_importer, :logs], filename: @filename) if Spree::Config.verbose

      start = Time.now
      begin
        open_spreadsheet
      rescue RuntimeError => e
        # ToDo - Corregir
        return e.message
      end
      puts I18n.t(:loading_file, scope: [:spree, :spree_importer, :logs], filename: @filename, time: Time.now - start) if Spree::Config.verbose


      start = Time.now

      failed_rows = []

      # Load each row element
      2.upto(@spreadsheet.last_row).each do |row_index|
        Spree::Product.transaction do
          begin
            if @product_identifier.exists?(@spreadsheet, row_index)
              puts I18n.t(:already_exists, scope: [:spree, :spree_importer, :logs], filename: @filename, row: row_index, rows: @spreadsheet.last_row, data: @spreadsheet.row(row_index))
              next
            end

            data = default_hash.deep_dup


            @mappers.each do |mapper|
              mapper.load @spreadsheet, row_index, data
            end

            before_make data
            make_products data
            make_variants data
            make_aditionals data
            after_make data

            if Spree::Config.verbose and row_index % Spree::Config[:log_progress_every] == 0
              puts I18n.t(:progress, scope: [:spree, :spree_importer, :logs], filename: @filename, time: Time.now - start, row: row_index, rows: @spreadsheet.last_row, data: data)
              start = Time.now
            end

          rescue RuntimeError => e
            puts I18n.t(:error, scope: [:spree, :spree_importer, :logs], filename: @filename, row: row_index, rows: @spreadsheet.last_row, data: data.inspect, message: e.message) if Spree::Config.verbose

            failed_rows << {row_index: row_index, message: e.message, data: data, backtrace: e.backtrace}

            raise ActiveRecord::Rollback
          rescue => e
            puts I18n.t(:error, scope: [:spree, :spree_importer, :logs], filename: @filename, row: row_index, rows: @spreadsheet.last_row, data: data.inspect, message: e.message) if Spree::Config.verbose

            failed_rows << {row_index: row_index, message: e.message, data: data, backtrace: e.backtrace}

            raise ActiveRecord::Rollback
          ensure

          end
        end
      end

      puts I18n.t(:done, scope: [:spree, :spree_importer, :logs], filename: @filename) if Spree::Config.verbose

      if failed_rows.empty?
        NotificationMailer.successfully(@filename).deliver
      else
        NotificationMailer.error(@filename, failed_rows).deliver
      end
    end


    private
      # Receives a file instance and then returns a Roo object acording the file extension
      #
      # @params:
      #   file     File   -  a file intance with data to load
      #
      # Returns a Roo instance acording the file extension.
      def open_spreadsheet
        case File.extname(@filename)
          when '.csv'  then @spreadsheet = Roo::CSV.new(@filepath)
          when '.xls'  then @spreadsheet = Roo::Excel.new(@filepath, nil, :ignore)
          when '.xlsx' then @spreadsheet = Roo::Excelx.new(@filepath, nil, :ignore)
          else raise "#{__FILE__}:#{__LINE__} #{I18n.t(:unknown_file_type, scope: [:spree, :spree_importer, :messages], filename: @filename)}"
        end

        @spreadsheet.default_sheet = @spreadsheet.sheets.first
      end

      # Defines the hash with default data and structure used to read the data in each row from excel
      # This allows easy customizations, overwriting this function
      #
      # Returns an Hash
      def default_hash
        {
          product: {},        # {attribute1: VALUE_OR_VALUES, attribute2: VALUE_OR_VALUES, ...}
          option_types: [],   # [{attribute1: VALUE_OR_VALUES, ...}, ...]
          option_values: {},  # {option_type1: [option_value1, option_value2, ...], ...}
          variants: [],       # [{attribute1: VALUE_OR_VALUES, attribute2: VALUE_OR_VALUES, ...}, ...]
          aditionals: {},     # {aditional1: ADITIONAL_VALUE_OR_VALUES, aditional2: ADITIONAL_VALUE_OR_VALUES, ....}


          taxons: [],       # [taxon1, taxon2, ......]
          properties: [],   # [{property_name1: PROPERTY_VALUE}, {property_name2: PROPERTY_VALUE}, ....]
          images: []        # [file_name1, file_name2, ......]
        }
      end

      # You must define here your global hash revision logic
      # To customize the data loaded from the given file, change the hash values, by the appropriate values
      # You can remove or modify every key into the hash, except those defined in #default_hash, the importer requiere this structure
      def before_make row
      end

      # You must define here your hash revision logic
      # To customize the data loaded from the given file, change the hash values, by the appropriate values
      # You can remove or modify every key into the hash, except those defined in #default_hash, the importer requiere this structure
      def before_make_products row
      end

      # Is responsible for creating the Product
      def make_products row
        before_make_products row

        product = Spree::Product.create row[:product]

        raise product.errors.full_messages.join(', ') if product.errors.any?

        # Store the Product :id in the row Hash data
        row[:product][:id] = product.id

        after_make_products row
      end

      # You must define here your post-insert revision logic
      # At this point you can check:
      #   - the data inserted,
      #   - the final values ​​in the hash data, or
      #   - perform some required process
      def after_make_products row
      end

      # You must define here your hash revision logic
      # To customize the data loaded from the given file, change the hash values, by the appropriate values
      # You can remove or modify every key into the hash, except those defined in #default_hash, the importer requiere this structure
      def before_make_variants row
      end

      # Is responsible for creating the Product
      def make_variants row
        before_make_variants row

        row[:variants].each do |attributes|
          variant = Spree::Variant.create attributes

          raise variant.errors.full_messages.join(', ') if variant.errors.any?

          # Store the Variant :id in the row Hash data
          attributes[:id] = variant.id
        end

        after_make_variants row
      end

      # You must define here your post-insert revision logic
      # At this point you can check:
      #   - the data inserted,
      #   - the final values ​​in the hash data, or
      #   - perform some required process
      def after_make_variants row
      end

      # You must define here your hash revision logic
      # To customize the data loaded from the given file, change the hash values, by the appropriate values
      # You can remove or modify every key into the hash, except those defined in #default_hash, the importer requiere this structure
      def before_make_aditionals row
      end

      # You must define here your creation logic
      def make_aditionals row
        before_make_aditionals row
        # Put your logic at this level
        after_make_aditionals row
      end

      # You must define here your post-insert revision logic
      # At this point you can check:
      #   - the data inserted,
      #   - the final values ​​in the hash data, or
      #   - perform some required process
      def after_make_aditionals row
      end

      # You must define here your global post-insert revision logic
      # At this point you can check:
      #   - the data inserted,
      #   - the final values ​​in the hash data, or
      #   - perform some required process
      def after_make row
      end
  end
end