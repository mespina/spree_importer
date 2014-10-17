#encoding: utf-8
module SpreeImporter
  module Mappers
    class ProductMapper < BaseMapper
      def load spreadsheet, row, data
        cell = spreadsheet.cell(row, @col)

        unless cell.nil?
          data[:product][@attribute] = parse(cell)
        end
      end
    end
  end
end
