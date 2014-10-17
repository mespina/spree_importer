#encoding: utf-8
module SpreeImporter
  class ProductIdentifier
    def initialize col, attribute, model=Spree::Product
      @col = col
      @attribute = attribute
      @model = model
    end

    def exists? spreadsheet, row
      cell = spreadsheet.cell(row, @col)

      if cell.nil?
        return false
      else
        return @model.exists?(@attribute => cell)
      end
    end
  end
end
