module Traffic
  # AlertsManager is responsible for publishing all types of alerts
  class AlertsManager
    ALERT_TYPES = %i[regular high_traffic normalized_traffic].freeze

    def initialize
      @alerts = []
    end

    def active_alerts?
      @alerts.any?
    end

    # Publish a specific alert
    # 
    # @param type [String] alert type
    # @param data [Hash] alert information
    def notify(type, data)
      raise ArgumentError, "Unknown alert type: #{type}" unless valid_type?(type)

      alert = load_alert(type)
      alert.prepare(data)

      publish(alert)
      clean_queue
    end

    private

    def valid_type?(type)
      ALERT_TYPES.include?(type.to_sym)
    end

    def load_alert(type)
      alert_class = type.to_s.split('_').map(&:capitalize).join
      Object.const_get("Traffic::Alerts::#{alert_class}").new
    end

    def publish(alert)
      puts alert.message
      alert.mark_published
      @alerts << alert unless alert.type == :regular
    end

    def clean_queue
      @alerts.clear if @alerts.last&.type == :normalized_traffic
    end
  end
end
