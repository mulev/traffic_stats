# Console traffic statistics monitor

This small tool monitors a specified Apache access log and publishes
some interesting statistics to STDOUT.

## Installation

It can be installed as a pure Ruby project, or can be used as a docker container.  
If a version is not specified, the latest stable is assumed.

### Pure Ruby application

**Requirements**:

- ruby 2.6.3
- bundler (included in ruby)

In order to install the application, please follow these steps:

``` bash
$ > git clone https://github.com/mulev/traffic_stats.git
$ > cd traffic_stats
$ traffic_stats > bundle install
```

### Docker container

**Requirements**:

- Docker
- docker-compose

In order to install the application, please follow these steps:

``` bash
$ > git clone https://github.com/mulev/traffic_stats.git
$ > cd traffic_stats
$ traffic_stats > docker-compose build
```

## Usage

This is a console tool, so in order to use it, one needs to run it in a console. 

It monitors two different things:

- traffic statistics for every ten seconds interval, including:
  
  - total number of requests for this interval
  - total number of bytes received
  - largest request received in bytes
  - total number of 5xx errors occured
  - top 10 path sections
  - top 10 users
  - top 10 IPs or hosts
  - top 10 HTTP methods used
  - top 10 response statuses returned

- total traffic statistics for every two minutes interval

If total traffic received within two minutes will exceed a certain threshold, 
it will publish an alert.  
If two minutes after traffic will be normalized, it will publish a notification 
that previous alerts have been released, otherwise another alert.

**Default settings**:

- `-s`, or `--source`: `/tmp/access.log`
- `-f`, or `--format`: `'%h %l %u %t \"%r\" %>s %b'` Apache log format
- `-t`, or `--threshold`: 1200

Supported log formats are:

- `'%h %l %u %t \"%r\" %>s %b'`: host, logname, user, datetime, request, status, bytes
- `'%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"'`: the same with referer and a user agent

### Monitor access log with default settings

```bash
$ traffic_stats > ruby bin/traffic_stats.rb
```

or

```bash
$ traffic_stats > LOG_DIR=/tmp docker-compose run stats
```

### Specify a log file and a threshold

```bash
$ traffic_stats > ruby bin/traffic_stats.rb -s ./log/access.log -t 10
```

or

```bash
$ traffic_stats > LOG_DIR=./log docker-compose run stats -s ./log/access.log -t 10
```
### Show help

```bash
$ traffic_stats > ruby bin/traffic_stats.rb -h
```

or

```bash
$ traffic_stats > LOG_DIR=/tmp docker-compose run stats -h
```

### Show version

```bash
$ traffic_stats > ruby bin/traffic_stats.rb -v
```

or

```bash
$ traffic_stats > LOG_DIR=/tmp docker-compose run stats -v
```

## Testing

In order to run tests you should have ruby and all required gems installed. 
Then run:

```bash
$ traffic_stats > bundle exec rspec -f doc
```

## Architecture

Application architecture is quite simple yet offering some not so tough customization.

### Structure

```
- bin/
  - traffic_stats.rb            # CLI
-lib/
  - traffic.rb
  - traffic/
    - alerts/                   # a directory for all alerts
      - basic.rb                # base alert class
      - high_traffic.rb         # alert about passed threshold
      - normalized_traffic.rb   # traffic normalization message
      - regular.rb              # regular informational alert
    - tasks/                    # a directory for all tasks
      - ten_seconds.rb          # task to publish regular information every ten seconds
      - two_minutes.rb          # task to publish alerts every two minutes
    - alerts_manager.rb         # alerts manager, responsible for all alerts
    - parser.rb                 # log file parser
    - stats_collector.rb        # statistics collector, responsible for preserving stats
    - watcher.rb                # log file watcher
- spec/                         # tests
```

To further enrich the tool, new alerts can be added to the `alerts/` directory, 
new tasks can be added to the `tasks/` directory.


### Further developments

- statistics persistence in a RDBMS
- alerts and tasks should be described as sets of configuration parameters, instead of `.rb` files. These should be also stored in a RDBMS
- configurable ten seconds statistics output - enabling and disabling of different parts of the output, add averages etc.
- distributed gem and executable
- type annotations using Sorbet for more stability


