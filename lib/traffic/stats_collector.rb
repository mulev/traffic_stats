module Traffic
  # StatsCollector is responsible for collecting and persisting statistics
  # for the last ten seconds and last two minutes
  class StatsCollector
    attr_accessor :ten_secs, :two_mins

    def initialize(format, file, threshold)
      @file = file
      @threshold = threshold

      initialize_ten_secs
      initialize_two_mins
      @parser = Traffic::Parser.new(format)
    end

    # Get a log line and update all stats
    #
    # @param log [String] log line
    def consider(log)
      log = @parser.parse(log)
      return if log.nil?

      update_counters(log)
    end

    # Reset all stats to their initial state
    # 
    # @param type [Symbol] stats type
    def reset(type)
      case type
      when :ten_secs
        initialize_ten_secs
      when :two_mins
        initialize_two_mins
      end
    end

    private

    def initialize_ten_secs
      @ten_secs = {
        file: @file,
        ttl: 0,
        ttl_bytes: 0,
        biggest_request: 0,
        sections: {},
        hosts: {},
        users: {},
        methods: {},
        statuses: {}
      }
    end

    def initialize_two_mins
      @two_mins = { threshold: @threshold, ttl: 0 }
    end

    def update_counters(log)
      @two_mins[:ttl] += 1
      update_ten_secs(log)
    end

    def update_ten_secs(log)
      update_totals(log)
      update_aggregates(:sections, log[:request][:path][:section])
      update_aggregates(:hosts, log[:host])
      update_aggregates(:users, log[:user])
      update_aggregates(:methods, log[:request][:method])
      update_aggregates(:statuses, log[:status])
    end

    def update_totals(log)
      @ten_secs[:ttl] += 1
      @ten_secs[:ttl_bytes] += log[:bytes]
      @ten_secs[:biggest_request] = log[:bytes] if log[:bytes] > @ten_secs[:biggest_request]
    end

    def update_aggregates(type, counter)
      if @ten_secs[type][counter]
        @ten_secs[type][counter] += 1
      else
        @ten_secs[type][counter] = 1
      end
    end
  end
end
