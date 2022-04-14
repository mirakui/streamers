require 'uri'
require 'net/http'
require 'json'

API_KEY = ENV.fetch('YOUTUBE_API_KEY')

def youtube_uri(path, queries=nil)
  queries = [queries, "key=#{API_KEY}"].compact.join('&')
  URI("https://youtube.googleapis.com#{path}?#{queries}")
end

def youtube_get(path, queries=nil)
  res = Net::HTTP.get_response(youtube_uri(path, queries))

  if res.code != '200'
    raise res.code_type.to_s
  end

  JSON.parse(res.body)
end

def youtube_get_channel_details(channel_id)
  youtube_get('/youtube/v3/channels', "id=#{channel_id}&part=statistics")
end

def youtube_get_live_streams(channel_id)
  youtube_get('/youtube/v3/search', "channelId=#{channel_id}&part=snippet&type=video&eventType=live")
end

def youtube_get_live_stream_details(video_id)
  youtube_get('/youtube/v3/videos', "id=#{video_id}&part=liveStreamingDetails")
end

channel_ids = %w(
UC5CwaMl1eIgY8h02uZw7u8A
)

channels = {}
videos = {}

channel_ids.each do |channel_id|
  result = youtube_get_live_streams(channel_id)
  video = result['items']&.first
  title = video['snippet']['title']
  channel_title = video['snippet']['channelTitle']
  video_id = video['id']['videoId']
  channels[channel_id] = { 'channel_id' => channel_id, 'channel_title' => channel_title }
  videos[video_id] = { 'channel_id' => channel_id, 'video_id' => video_id, 'title' => title }
end

stream_details = youtube_get_live_stream_details(videos.keys.join(','))

stream_details['items']&.each do |item|
  video_id = item['id']
  detail = item['liveStreamingDetails']
  videos[video_id].merge!({
    'concurrent_viewers' => detail['concurrentViewers'],
    'actualStartTime' => detail['actualStartTime'],
    'scheduledStartTime' => detail['scheduledStartTime'],
  })
end

channel_details = youtube_get_channel_details(channel_ids.join)

channel_details['items']&.each do |item|
  channel_id = item['id']
  stats = item['statistics']
  channels[channel_id].merge!({
    'channel_view_count' => stats['viewCount'],
    'subscriber_count' => stats['subscriberCount'],
    'video_count' => stats['videoCount'],
  })
end

videos.values.each {|v| channels[v['channel_id']]['video'] = v }
puts channels.values.to_json

