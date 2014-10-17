# encoding: utf-8

require 'rubygems'
require 'sidekiq'

module SpreeImporter
  class ImporterWorker
    include Sidekiq::Worker

    sidekiq_options retry: false

    def perform(filename, filepath, options={})
      importer = SpreeImporter::Importer.new filename, filepath, options

      importer.load_products
    end
  end
end
