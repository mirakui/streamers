module YouTube
  module Models
    class Video
      attr_reader :id, :watching

      def initialize(client, video_id, watching: nil, title: nil)
        @client = client
        @id = video_id
        @watching = watching
        @title = title
      end
    end
  end
end
