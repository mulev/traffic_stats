module Traffic
  module Alerts
    class Basic
      attr_reader :type, :message, :status

      def initialize(type:)
        @type = type
        @status = :new
        @message = ''
      end

      def prepare(data)
        raise NotImplementedError, 'Basic alert can not be prepared, use specific alerts'
      end

      def mark_published
        @status = :published
      end
    end
  end
end
