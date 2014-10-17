module Spree
  module Admin
    class ImporterController < Spree::Admin::BaseController
      # include Spree::Backend::Callbacks

      # GET admin/importer
      def index
      end

      # GET admin/importer/template
      def template
        file = File.open(Spree::Config[:sample_file])

        send_data file.read, :filename => File.basename(Spree::Config[:sample_file])
      end

      # POST admin/importer
      def create
        if params[:file]
          if SpreeImporter::Handler.import(params[:file])
            flash[:success] = I18n.t(:importing, scope: [:spree, :spree_importer, :messages, :controller])
          else
            flash[:error] = I18n.t(:error, scope: [:spree, :spree_importer, :messages, :controller])
          end
        else
          flash[:error] = I18n.t(:file_required, scope: [:spree, :spree_importer, :messages, :controller])
        end

        redirect_to admin_importer_index_path
      end
    end
  end
end
