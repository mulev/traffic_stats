require 'app_helper'

RSpec.describe Traffic::AlertsManager do
  subject { described_class.new }

  describe '#new' do
    it 'creates an instance of an alert manager' do
      expect(subject).to be_an_instance_of described_class
    end

    it 'initializes an empty alerts list' do
      expect(subject.active_alerts?).to eq false
    end
  end

  describe '#active_alerts?' do
    context 'when manager has active alerts' do
      before do
        subject.notify(:high_traffic, {})
      end

      it 'returns true' do
        expect(subject.active_alerts?).to eq true
      end
    end

    context 'when manager has no alerts' do
      it 'returns false' do
        expect(subject.active_alerts?).to eq false
      end
    end
  end

  describe '#notify' do
    context 'when called with an invalid alert type' do
      it 'raises an ArgumentError' do
        expect { subject.notify(:foo, {}) }.to raise_error(
          ArgumentError,
          'Unknown alert type: foo'
        )
      end
    end

    context 'when called for a Regular alert' do
      let(:data) do
        {
          file: 'access.log',
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

      it 'publishes a regular statistics report to the STDOUT' do
        expect { subject.notify(:regular, data) }.to output.to_stdout
      end

      it 'does not add a published alert into an alerts list' do
        subject.notify(:regular, data)
        expect(subject.active_alerts?).to eq false
      end
    end

    context 'when called for a HighTraffic alert' do
      let(:data) { { threshold: 1, ttl: 2 } }

      it 'publishes a high traffic alert to the STDOUT' do
        expect { subject.notify(:high_traffic, data) }.to output.to_stdout
      end

      it 'adds a published alert into an alerts list' do
        subject.notify(:high_traffic, data)
        expect(subject.active_alerts?).to eq true
      end
    end

    context 'when called for a NormalizedTraffic alert' do
      let(:data) { { threshold: 2, ttl: 1 } }

      it 'publishes a normalized traffic alert to the STDOUT' do
        expect { subject.notify(:normalized_traffic, data) }.to output.to_stdout
      end

      it 'cleans an alerts list after publication' do
        subject.notify(:normalized_traffic, data)
        expect(subject.active_alerts?).to eq false
      end
    end
  end
end
