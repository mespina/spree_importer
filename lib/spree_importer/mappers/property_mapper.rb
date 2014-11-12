#encoding: utf-8
module SpreeImporter
  module Mappers
    class PropertyMapper < BaseMapper
      def load spreadsheet, row, data
        cell = spreadsheet.cell(row, @col)
        header = spreadsheet.cell(1, @col)

        unless cell.nil?
          data[:product][@attribute] = [] unless data[:product][@attribute]
          data[:product][@attribute] << {property_name: header, value: cell}
        end
      end
    end
  end
end