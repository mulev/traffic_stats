module Traffic
  module Alerts
    class HighTraffic < Traffic::Alerts::Basic
      def initialize
        super(type: :high_traffic)
      end

      def prepare(data)
        return if data.nil? || data.empty?

        @message =  "==================================================================================\n"
        @message << "                                     ALERT!                                       \n".red
        @message << "==================================================================================\n\n"
        @message << "High traffic generated an alert - hits = "
        @message << "#{data[:ttl]}".red
        @message << ", triggered at #{Time.now}\n\n"
        @message << "Current threshold value: "
        @message << "#{data[:threshold]}\n\n".red
        @message << "==================================================================================\n"
        @message << "                                  END OF ALERT!                                   \n".red
        @message << "==================================================================================\n\n"
      end
    end
  end
end
