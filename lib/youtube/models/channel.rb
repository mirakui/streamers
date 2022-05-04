require_relative './video'

module YouTube
  module Models
    class Channel
      def initialize(client, channel_id)
        @client = client
        @channel_id = channel_id
      end

      def subscribers_count(approx: true)
      end

      def video_on_live
        res = @client.fetch_channel_video_on_live(@channel_id)
        video = Video.new(@client, res[:video_id], watching: res[:watching])
        video
      end
    end
  end
end
