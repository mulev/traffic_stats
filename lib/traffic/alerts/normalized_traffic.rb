module Traffic
  module Alerts
    class NormalizedTraffic < Traffic::Alerts::Basic
      def initialize
        super(type: :normalized_traffic)
      end

      def prepare(data)
        return if data.nil? || data.empty?

        @message =  "==================== ALERT RECOVERED =====================\n\n".green
        @message << "High traffic alert RECOVERED at #{Time.now}\n\n"
        @message << "Total traffic for the last two minutes:  #{data[:ttl]}\n"
        @message << "Current threshold value:                 #{data[:threshold]}\n\n"
        @message << "==========================================================\n\n".green
      end
    end
  end
end
