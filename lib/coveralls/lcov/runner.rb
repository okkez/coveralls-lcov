require "optparse"
require "coveralls"
require "coveralls/lcov/converter"

module Coveralls
  module Lcov
    class Runner
      def initialize(argv)
        @argv = argv
        @verbose = false
        @dry_run = false
        @parser = OptionParser.new(@argv)
        @parser.banner = <<BANNER
  Usage: coveralls [options] coverage.info

  e.g. coveralls -v coverage.info

BANNER
        @parser.on("-v", "--verbose", "Print payload") do
          @verbose = true
        end
        @parser.on("-n", "--dry-run", "Dry run") do
          @dry_run = true
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
        puts payload.to_json if @verbose
        unless @dry_run
          Coveralls::API.post_json("jobs", payload)
        end
      end
    end
  end
end
