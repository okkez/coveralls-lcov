require "optparse"
require "json"
require "net/http"
require "net/https"
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
        @n_times = 3
        @delay = 3
        @source_encoding = Encoding::UTF_8
        @service_name = "travis-ci"
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
        @parser.on("-s", "--service-name=SERVICENAME", "Service name") do |service_name|
          @service_name = service_name
        end
        @parser.on("--service-job-id=JOB_ID", "Service job id. ex. TRAVIS_JOB_ID") do |service_job_id|
          @service_job_id = service_job_id
        end
        @parser.on("--retry=N", Integer, "Retry to POST N times (default: 3)") do |n_times|
          @n_times = n_times
        end
        @parser.on("--delay=N", Integer, "Delay in N secs when retry (default: 3)") do |delay|
          @delay = delay
        end
        @parser.on("--source-encoding=ENCODING",
                   "Source files encoding  (default: UTF-8)") do |encoding|
          @source_encoding = Encoding.find(encoding)
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
        converter = Converter.new(tracefile, @source_encoding, @service_name)
        payload = converter.convert
        payload[:repo_token] = @repo_token if @repo_token
        payload_json = payload.to_json
        puts payload_json if @verbose
        unless @dry_run
          @n_times.times do
            response = post(payload_json)
            return true if response.is_a?(Net::HTTPSuccess)
            sleep @delay
          end
        end
        false
      end

      def post(payload)
        Net::HTTP.version_1_2
        response = nil

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

        response
      end
    end
  end
end
