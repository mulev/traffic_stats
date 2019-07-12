require 'app_helper'

RSpec.describe Traffic::Tasks::TenSeconds do
  subject { described_class.new(opts) }

  let(:format)        { '%h %l %u %t \"%r\" %>s %b' }
  let(:file)          { 'log/access.log' }
  let(:threshold)     { 1 }
  let(:alert_manager) { Traffic::AlertsManager.new }
  let(:stats)         { Traffic::StatsCollector.new(format, file, threshold) }
  let(:opts)          { { alert_manager: alert_manager, stats: stats } }

  describe '#new' do
    it 'creates an instance of a ten seconds task' do
      expect(subject).to be_an_instance_of described_class
    end
  end

  describe '#run' do
    let(:log_line) do
      '127.0.0.1 - james [09/May/2018:16:00:39 +0000] ' \
        '"GET /accounts HTTP/1.0" 200 123'
    end

    before do
      stats.consider(log_line)
    end

    it 'publishes ten seconds traffic statistics to STDOUT' do
      expect { subject.run }.to output.to_stdout
    end

    it 'resets traffic statistics' do
      expect(stats.ten_secs[:ttl]).to eq 1
      subject.run
      expect(stats.ten_secs[:ttl]).to eq 0
    end
  end
end
