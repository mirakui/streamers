require_relative './video'

module YouTube
  module Models
    class Channel
      attr_reader :id, :name, :approx_subscribers

      def initialize(client, channel_id)
        @client = client
        @id = channel_id
      end

      def subscribers_count(approx: true)
      end

      def video_on_live
        res = fetch_video_on_live_cached
        video = Video.new(@client, res[:video_id], watching: res[:watching], title: res[:title])
        video
      end

      def name
        @name ||= begin
          res = fetch_video_on_live_cached
          res[:channel_name]
        end
      end

      def approx_subscribers
        @approx_subscribers ||= begin
          res = fetch_video_on_live_cached
          res[:approx_subscribers]
        end
      end

      private
      def fetch_video_on_live_cached
        @fetch_video_on_live_cached ||= begin
          @client.fetch_channel_video_on_live(@id)
        end
      end
    end
  end
end
