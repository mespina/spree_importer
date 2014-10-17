#encoding: utf-8
module SpreeImporter
  module Mappers
    class BaseMapper
      def initialize col, attribute, formater=nil
        @col       = col
        @attribute = attribute
        @formater  = formater
      end

      def parse cell
        if @formater
          return @formater.parse(cell)
        else
          return cell
        end
      end

      def load
        raise 'You must define this function'
      end
    end
  end
end
