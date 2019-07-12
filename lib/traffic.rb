begin
  require 'apachelogregex'
  require 'colorize'
  require 'concurrent'
  require 'date'
  require 'file-tail'
  require 'pry'
rescue LoadError
  puts 'Not all dependencies were installed, please run `bundle install`'
  exit 1
end

# Alerts
require_relative 'traffic/alerts/basic'
require_relative 'traffic/alerts/regular'
require_relative 'traffic/alerts/high_traffic'
require_relative 'traffic/alerts/normalized_traffic'

# Tasks
require_relative 'traffic/tasks/ten_seconds'
require_relative 'traffic/tasks/two_minutes'

# Business logic
require_relative 'traffic/alerts_manager'
require_relative 'traffic/parser'
require_relative 'traffic/stats_collector'
require_relative 'traffic/watcher'
require_relative 'traffic/version'
