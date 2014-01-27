require "optparse"
require "json"
require "net/http"
require "coveralls/lcov/converter"

module Coveralls
  # URI: https://coveralls.io/api/v1/jobs
  HOST = "coveralls.io"
  PATH = "/api/v1/jobs"

  module Lcov
    class Runner
      def initialize(argv)
        @argv = argv
        @repo_token = nil
        @verbose = false
        @dry_run = false
        @parser = OptionParser.new(@argv)
        @parser.banner = <<BANNER
  Usage: coveralls-lcov [options] coverage.info

  e.g. coveralls-lcov -v coverage.info

BANNER
        @parser.on("-t", "--repo-token=TOKEN", "Repository token") do |token|
          @repo_token = token
        end
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
        payload[:repo_token] = @repo_token if @repo_token
        payload_json = payload.to_json
        puts payload_json if @verbose
        unless @dry_run
          post(payload_json)
        end
      end

      def post(payload)
        Net::HTTP.version_1_2

        http = Net::HTTP.new(HOST, 443)
        http.use_ssl = true
        http.start do
          request = Net::HTTP::Post.new(PATH)
          request["content-type"] = "multipart/form-data; boundary=boundary"
          request.body = <<BODY.gsub(/\n/, "\r\n")
--boundary
content-disposition: form-data; name="json_file"; filename="payload.json"

#{payload}

--boundary--
BODY
          response = http.request(request)
          p response
          puts response.body
        end
      end
    end
  end
end
