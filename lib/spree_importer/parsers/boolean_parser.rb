#encoding: utf-8
module SpreeImporter
  module Parsers
    class BooleanParser < BaseParser
      def initialize true_value='Y'
        @true_value = true_value
      end

      def parse value
        return value == @true_value
      end
    end
  end
end
