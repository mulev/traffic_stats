require 'app_helper'

RSpec.describe Traffic::Tasks::TwoMinutes do
  subject { described_class.new(opts) }

  let(:format)        { '%h %l %u %t \"%r\" %>s %b' }
  let(:file)          { 'log/access.log' }
  let(:threshold)     { 1 }
  let(:alert_manager) { Traffic::AlertsManager.new }
  let(:stats)         { Traffic::StatsCollector.new(format, file, threshold) }

  let(:opts) do
    {
      alert_manager: alert_manager,
      stats: stats,
      threshold: threshold
    }
  end

  describe '#new' do
    it 'creates an instance of a two minutes task' do
      expect(subject).to be_an_instance_of described_class
    end
  end

  describe '#run' do
    let(:log_line) do
      '127.0.0.1 - james [09/May/2018:16:00:39 +0000] ' \
        '"GET /accounts HTTP/1.0" 200 123'
    end

    context 'when threshold passed' do
      before do
        2.times { stats.consider(log_line) }
      end

      it 'publishes an alert to STDOUT' do
        expect { subject.run }.to output.to_stdout
      end

      it 'resets traffic statistics' do
        expect(stats.two_mins[:ttl]).to eq 2
        subject.run
        expect(stats.two_mins[:ttl]).to eq 0
      end
    end

    context 'when threshold not passed' do
      context 'without any previous alerts' do
        before do
          stats.consider(log_line)
        end

        it 'does not publish any alerts' do
          expect { subject.run }.not_to output.to_stdout
        end

        it 'resets traffic statistics' do
          expect(stats.two_mins[:ttl]).to eq 1
          subject.run
          expect(stats.two_mins[:ttl]).to eq 0
        end
      end

      context 'with previously published alert' do
        before do
          5.times { stats.consider(log_line) }
          subject.run
          stats.consider(log_line)
        end

        it 'publishes an alert release message to STDOUT' do
          expect { subject.run }.to output.to_stdout
        end

        it 'resets traffic statistics' do
          expect(stats.two_mins[:ttl]).to eq 1
          subject.run
          expect(stats.two_mins[:ttl]).to eq 0
        end

        it 'cleans all saved alerts from the list' do
          expect(alert_manager.active_alerts?).to eq true
          subject.run
          expect(alert_manager.active_alerts?).to eq false
        end
      end
    end
  end
end
