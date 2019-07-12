FROM ruby:2.6.3

RUN touch /tmp/access.log

WORKDIR /usr/src/traffic_stats
COPY . .

RUN bundle install

ENTRYPOINT ["ruby", "bin/traffic_stats.rb"]
