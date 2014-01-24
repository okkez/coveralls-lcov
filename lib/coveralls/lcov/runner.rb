require "optparse"
require "coveralls"

module Coveralls
  module Lcov
    class Runner
      def initialize(argv)
        @argv = argv
        @verbose = false
        @parser = OptionParser.new(@argv)
        @parser.banner = <<BANNER
  Usage: coveralls [options] coverage.info

  e.g. coveralls -v coverage.info

BANNER
        @parser.on("-v", "--verbose", "Print payload") do
          @verbose = true
        end
      end

      def run
        @parser.parse!
        unless @argv.size == 1
          warn "Too many arguments! <#{@argv.join(",")}>"
          warn @parser.help
          exit false
        end
        tracefile = @argv.shift
        converter = Converter.new(tracefile)
        payload = converter.convert
        Coveralls::API.post_json("jobs", payload)
      end
    end
  end
end
