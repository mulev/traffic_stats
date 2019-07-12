begin
  require 'slop'
rescue LoadError
  puts 'Not all dependencies were installed, please run `bundle install`'
  exit 1
end

require_relative '../lib/traffic'

opts = Slop.parse do |o|
  o.string '-s', '--source', 'path to a log file', default: '/tmp/access.log'
  o.string '-f', '--format', 'apache log format', default: '%h %l %u %t \"%r\" %>s %b'
  o.integer '-t', '--threshold', 'traffic threshold for 2 minutes interval', default: 1200

  o.on '-v', '--version' do
    puts Stats::VERSION
    exit 0
  end

  o.on '-h', '--help' do
    puts o
    exit 0
  end
end

begin
  Traffic::Watcher.run(opts.to_hash)
rescue Interrupt
  puts ''
  puts 'Thanks for using this traffic monitoring tool!'
  puts 'Please report any issues or ideas here: https://github.com/mulev/traffic_stats/issues'
  puts ''
  puts '(c) Mike Mulev, 2019 | https://github.com/mulev'

  exit 0
end
