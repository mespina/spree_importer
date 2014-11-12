#encoding: utf-8
module SpreeImporter
  module Parsers
    class StringParser < BaseParser
      def initialize splitter='.'
        @splitter = splitter
      end

      def parse value
        value.to_s.split(@splitter).first
      end
    end
  end
end
