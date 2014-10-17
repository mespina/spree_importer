#encoding: utf-8
module SpreeImporter
  module Mappers
    class TaxonMapper < BaseMapper
      def load spreadsheet, row, data
        cell = spreadsheet.cell(row, @col)

        unless cell.nil?
          data[:product][@attribute] = [] unless data[:product][@attribute]
          data[:product][@attribute] += parse(cell)
        end
      end
    end
  end
end