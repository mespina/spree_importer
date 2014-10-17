#encoding: utf-8
module SpreeImporter
  module Mappers
    class AditionalMapper < BaseMapper
      def load spreadsheet, row, data
        cell = spreadsheet.cell(row, @col)

        unless cell.nil?
          data[:aditionals][@attribute] = parse(cell)
        end
      end
    end
  end
end