module Traffic
  # Parser is responsible for parsing log lines and tranforming them to an
  # interally used hash with all log data
  class Parser
    def initialize(format)
      @parser = ApacheLogRegex.new(format)
    end

    # @param line [String] log line
    # @returns [Hash]
    def parse(line)
      log = @parser.parse(line)
      return if log.nil?

      log = transform_log(log)
      return unless valid_log?(log)

      log
    end

    private

    def transform_log(log)
      log.each_with_object({}) do |(k, v), obj|
        key = define_key(k)
        next if key.nil?

        value = %i[datetime request bytes status].include?(key) ? optimize_value(key, v) : v
        obj[key] = value
      end
    end

    def define_key(subst)
      case subst
      when '%h'
        :host
      when '%l'
        :logname
      when '%u'
        :user
      when '%t'
        :datetime
      when '%r'
        :request
      when '%>s'
        :status
      when '%b'
        :bytes
      when '%{Referer}i'
        :referer
      when '%{User-Agent}i'
        :ua
      when '%v'
        :virtual_host
      else
        nil
      end
    end

    def optimize_value(key, value)
      case key
      when :datetime
        DateTime.strptime(value.sub!('[', '').sub!(']', ''), '%d/%b/%Y:%H:%M:%S %z')
      when :bytes, :status
          value.to_i
      when :request
        scanner = StringScanner.new(value)
        obj = { method: nil, path: nil, proto: nil }

        obj[:method] = scanner.scan_until(/(GET|POST|PUT|DELETE|HEAD|OPTIONS)/)
        scanner.scan_until(/\s+/)

        path = scanner.scan_until(/\S+/)
        obj[:path] = { full: path, section: path.split('/')[1] }
        scanner.scan_until(/\s+/)

        obj[:proto] = scanner.scan_until(/\S+/)
        obj
      end
    rescue
      nil
    end

    def valid_log?(log)
      return false if log.nil?
      return false unless log[:datetime] && log[:request] && log[:status]
      true
    end
  end
end
