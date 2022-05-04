require_relative 'clients/web'

module YouTube
  class Client
    def initialize
      @web = Clients::Web.new
    end

    def fetch_channel_video_on_live(channel_id)
      video_renderer = nil
      res = @web.fetch_channel_videos_on_live(channel_id)

      begin
        video_renderer = res['contents']['twoColumnBrowseResultsRenderer']['tabs'].
          first['tabRenderer']['content']['sectionListRenderer']['contents'].
          first['itemSectionRenderer']['contents'].
          first['channelFeaturedContentRenderer']['items'].
          first['videoRenderer']
      rescue
        raise "failed to parse videoRenderer: channel_id=#{channel_id}"
      end

      video_id = video_renderer['videoId']
      unless video_id =~ /\A[a-zA-Z0-9]+\z/
        raise "unexpected video id: #{video_id}"
      end

      watching_str = video_renderer['viewCountText']['runs'].first['text']
      unless watching_str =~ /\A\d+\z/
        raise "unexpected 'watching' value: #{watching_str}"
      end

      {
        video_id: video_id,
        watching: watching_str.to_i
      }
    end
  end
end
