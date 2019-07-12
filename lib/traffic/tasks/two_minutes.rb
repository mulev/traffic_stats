module Traffic
  module Tasks
    class TwoMinutes
      def initialize(opts)
        @alert_manager = opts[:alert_manager]
        @stats = opts[:stats]
        @threshold = opts[:threshold]
      end

      def run
        if @stats.two_mins[:ttl] > @threshold
          @alert_manager.notify(:high_traffic, @stats.two_mins)
        elsif (@stats.two_mins[:ttl] <= @threshold) && @alert_manager.active_alerts?
          @alert_manager.notify(:normalized_traffic, @stats.two_mins)
        end

        @stats.reset(:two_mins)
      end
    end
  end
end
