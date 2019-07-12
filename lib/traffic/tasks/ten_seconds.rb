module Traffic
  module Tasks
    class TenSeconds
      def initialize(opts)
        @alert_manager = opts[:alert_manager]
        @stats = opts[:stats]
      end

      def run
        @alert_manager.notify(:regular, @stats.ten_secs)
        @stats.reset(:ten_secs)
      end
    end
  end
end
