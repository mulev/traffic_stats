module Traffic
  # Watcher is responsible for tailing a given log file, sending data from
  # a log file to a Statistics Collector, and running monitoring tasks
  class Watcher
    def self.run(**opts)
      watcher = new(opts)
      watcher.watch
    end

    def initialize(**opts)
      @log_file = opts[:source]
      @threshold = opts[:threshold]
      validate_file

      @stats = Traffic::StatsCollector.new(opts[:format], @log_file, @threshold)
      @alert_manager = Traffic::AlertsManager.new
      setup_tasks
    end

    # Open and infinitely tail a given log file
    def watch
      File.open(@log_file) do |log|
        log.extend(File::Tail)
        log.interval = 0
        log.backward
        log.tail { |line| @stats.consider(line) }
      end
    end

    private

    def validate_file
      exit 1 unless File.exist?(@log_file)
    end

    def setup_tasks
      ten_seconds_task
      two_minutes_task
    end

    def ten_seconds_task
      task = Traffic::Tasks::TenSeconds.new(
        alert_manager: @alert_manager,
        stats: @stats
      )
      Concurrent::TimerTask.new(execution_interval: 10) { task.run }.execute
    end

    def two_minutes_task
      task = Traffic::Tasks::TwoMinutes.new(
        alert_manager: @alert_manager,
        stats: @stats,
        threshold: @threshold
      )
      Concurrent::TimerTask.new(execution_interval: 120) { task.run }.execute
    end
  end
end
