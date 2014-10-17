#encoding: utf-8
module SpreeImporter
  module Parsers
    class ArrayParser < BaseParser
      def initialize splitter=','
        @splitter = splitter
      end

      def parse value
        value.split(@splitter)
      end
    end
  end
end
