module Traffic
  module Alerts
    class Regular < Traffic::Alerts::Basic
      def initialize
        super(type: :regular)
      end

      def prepare(data)
        return if data.nil? || data.empty?

        @data = data

        @message =  "Traffic statistics for the last 10 seconds\n"
        @message << "------------------------------------------\n"
        @message << "Current time:        #{Time.now}\n"
        @message << "Log file:            #{@data[:file]}\n"
        @message << "Total traffic:       #{@data[:ttl]} hit(-s)\n"
        @message << "Total bytes:         #{@data[:ttl_bytes]} byte(-s)\n"
        @message << "Biggest request:     #{@data[:biggest_request]} byte(-s)\n"
        @message << "Number of 5xx:       #{get_fatals}\n\n"
        @message << "Top 10 sections:     #{sorted_data(:sections)}"
        @message << "Top 10 users:        #{sorted_data(:users)}"
        @message << "Top 10 IPs (hosts):  #{sorted_data(:hosts)}"
        @message << "Top 10 HTTP methods: #{sorted_data(:methods)}"
        @message << "Top 10 statuses:     #{sorted_data(:statuses)}"
        @message << "==========================================\n\n"
      end

      private

      def get_fatals
        @data[:statuses].each_with_object(0) do |(k, v), qty|
          qty += v if k.to_s.split.first == '5'
        end
      end

      def sorted_data(type)
        sorted = @data[type].sort_by { |k, v| -v }[0..9]
        return "no data about #{type}\n" unless sorted.any?

        msg = "#{sorted.first.first} => #{sorted.first.last} hit(-s)\n"
        sorted[1..sorted.length].each do |section|
          msg << "                     "
          msg << "#{section.first} => #{section.last} hit(-s)\n"
        end
        msg
      end
    end
  end
end
