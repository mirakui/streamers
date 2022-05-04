require_relative 'clients/web'

module YouTube
  class Client
    def initialize
      @web = Clients::Web.new
    end

    def fetch_channel_video_on_live(channel_id)
      res = @web.fetch_channel_video_on_live(channel_id)

      approx_subscribers_str = nil
      begin
        approx_subscribers_str = res['header']['c4TabbedHeaderRenderer']['subscriberCountText']['simpleText']
      rescue
        raise "failed to parse subscriberCountText: channel_id=#{channel_id}"
      end
      approx_subscribers = self.class.parse_approx_subscribers(approx_subscribers_str)


      video_renderer = nil
      begin
        video_renderer = res['contents']['twoColumnBrowseResultsRenderer']['tabs'].
          first['tabRenderer']['content']['sectionListRenderer']['contents'].
          first['itemSectionRenderer']['contents'].
          first['channelFeaturedContentRenderer']['items'].
          first['videoRenderer']
      rescue
        # do nothing
      end

      video_id = nil
      watching = nil
      title = nil
      channel_name = nil
      if video_renderer
        video_id = video_renderer['videoId']
        unless video_id =~ /\A[a-zA-Z0-9]+\z/
          raise "unexpected video id: #{video_id}"
        end

        watching_str = video_renderer['viewCountText']['runs'].first['text']
        unless watching_str =~ /\A\d+\z/
          raise "unexpected 'watching' count: #{watching_str}"
        end
        watching = watching_str.to_i

        channel_name = video_renderer['longBylineText']['runs'].first['text']
        unless channel_name =~ /[^\s]+/
          raise "unexpected channel name: #{channel_name.inspect}"
        end

        title = video_renderer['title']['runs'].first['text']
      end

      {
        video_id: video_id,
        watching: watching,
        title: title,
        channel_name: channel_name,
        approx_subscribers: approx_subscribers,
      }
    end

    def self.parse_approx_subscribers(approx_subscribers_str)
      matched = approx_subscribers_str.match(/\A([\d\.,]+)([KM]?)\s*/)

      unless matched
        raise "unexpected subscriber count: #{approx_subscribers_str}"
      end

      num = matched[1].gsub(',', '').to_f
      case matched[2]
      when 'K'
        num *= 1_000
      when 'M'
        num *= 1_000_000
      when ''
      else
        raise "unexpected subscriber count: #{approx_subscribers_str}"
      end

      num.to_i
    end
  end
end
