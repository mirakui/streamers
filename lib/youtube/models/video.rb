module YouTube
  module Models
    class Video
      attr_reader :video_id, :watching

      def initialize(client, video_id, watching: nil)
        @client = client
        @video_id = video_id
        @watching = watching
      end
    end
  end
end
