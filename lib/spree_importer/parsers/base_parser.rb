#encoding: utf-8
module SpreeImporter
  module Parsers
    class BaseParser
      def parse value
        raise 'You must define this function'
      end
    end
  end
end
