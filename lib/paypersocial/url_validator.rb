module Paypersocial
  class UrlValidator
    class << self
      def is_valid?(url)
        is_well_formatted?(url) && is_alive?(url)
      end

      def is_well_formatted?(url)
        url =~ Paypersocial::Constants::URL_PATTERN
      end

      def is_alive?(url)
        begin
          parsed_url = URI.parse(url)
          req = Net::HTTP.new(parsed_url.host, parsed_url.port)
          path = parsed_url.path.blank? ? '/' : parsed_url.path
          res = req.request_head(path)
          #NOTE: some URLs give 401; 403, etc, but when put them in browser it redirects to correct(live) page
          res.code.starts_with?('2') || res.code.starts_with?('3') || res.code.starts_with?('4')
        rescue
          false
        end
      end
    end
  end
end