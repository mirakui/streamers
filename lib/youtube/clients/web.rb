require 'uri'
require 'net/https'
require 'json'

module YouTube
  module Clients
    class Web
      URI_BASE = 'https://www.youtube.com/'

      def initialize
      end

      def fetch_channel_videos_on_live(channel_id)
        uri = build_uri("/channel/#{channel_id}/video", {view: 2, live_view: 501})
        fetch(uri)
      end

      def build_uri(path, query={})
        uri = URI(URI_BASE)
        uri.path = path
        uri.query = URI.encode_www_form(query)
        uri
      end

      def fetch(uri)
        req = Net::HTTP::Get.new(uri)
        req['Accept-Language'] = 'en-us'

        res = Net::HTTP.start(uri.host, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
          http.request(req)
        end

        unless res.code_type == Net::HTTPOK
          raise "fetch error (#{res.code}): #{uri}"
        end
        # puts uri
        # matched = res.body.match(%r/ytInitialPlayerResponse\s*=(.*)/)
        matched = res.body.match(%r!var ytInitialData\s*=\s*(.*?);</script>!m)
        unless matched
          raise "body parse error: #{uri}"
        end

        json_str = matched[1]
        json = JSON.parse(json_str)
        json
      end
    end
  end
end
