#encoding: utf-8
module SpreeImporter
  module Parsers
    class DateTimeParser < BaseParser
       def initialize format="%m/%d/%y"
        @format = format
      end

      def parse value
        DateTime.strptime(value, @format).to_s
      end
    end
  end
end
