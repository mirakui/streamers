require 'json'
require 'google/cloud/bigquery'
require_relative 'lib/youtube/client'
require_relative 'lib/youtube/models/channel'

NUM_THREADS = 5
client = YouTube::Client.new

results = []

i=0
channels = []
open('hololive_channels.tsv') do |f|
  while line=f.gets
    nickname, channel_id = line.chomp.split("\t")
    next unless nickname
    channels << { nickname: nickname, channel_id: channel_id }
    # break if (i+=1) > 3
  end
end

results = []
threads = []
now = Time.now.strftime('%Y-%m-%d %H:%M:%S')
NUM_THREADS.times do |i|
  th = Thread.new do
    puts "[#{i}] thread start"
    client = YouTube::Client.new
    while !channels.empty?
      ch_info = channels.shift
      puts "[#{i}] #{ch_info} start"

      channel = YouTube::Models::Channel.new(client, ch_info[:channel_id])
      video = channel.video_on_live

      results << {
        'time' => now,
        'channel_nickname' => ch_info[:nickname],
        'channel_id' => channel.id,
        'channel_name' => channel.name,
        'approx_subscribers' => channel.approx_subscribers.to_i,
        'video_id' => video&.id,
        'video_title' => video&.title,
        'video_watching' => video&.watching.to_i,
      }

      puts "[#{i}] #{ch_info} end"
      Thread.pass
    end
    puts "[#{i}] thread end"
  end
  threads << th
end

threads.map(&:join)

# puts results.to_json

bigquery = Google::Cloud::Bigquery.new
dataset = bigquery.dataset 'hololive'
table = dataset.table 'channel_activities'

response = table.insert results

if response.success?
  puts "Inserted rows successfully"
else
  puts "Failed to insert #{response.error_rows.count} rows"
end
