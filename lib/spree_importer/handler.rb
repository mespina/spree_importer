#encoding: utf-8

require 'roo'
require 'httparty'

module SpreeImporter
  class Handler
    # Receives a file to import and add it to a run queue
    def self.import(file, options={})
      filename = Rails.env.test? ? File.basename(file) : file.original_filename

      SpreeImporter::ImporterWorker.perform_async(filename, file.path, options)

      return true
    end
  end
end
