require 'app_helper'

RSpec.describe Traffic::Alerts::HighTraffic do
  subject { described_class.new }

  describe '#new' do
    it 'creates an instance of a HighTraffic alert' do
      expect(subject).to be_an_instance_of described_class
    end

    it 'sets an alert type to `:high_traffic`' do
      expect(subject.type).to eq :high_traffic
    end
  end

  describe '#prepare' do
    context 'when dataset is not provided' do
      it 'does not set an alert message' do
        subject.prepare(nil)
        expect(subject.message).to eq ''
      end
    end

    context 'when dataset is an empty hash' do
      it 'does not set an alert message' do
        subject.prepare({})
        expect(subject.message).to eq ''
      end
    end

    let(:data) { { threshold: 1, ttl: 2 } }

    context 'when dataset is valid' do
      before do
        subject.prepare(data)
      end

      it 'sets an alerting message' do
        expect(subject.message).to include(
          'High traffic generated an alert - hits =',
          'Current threshold value:'
        )
      end
    end
  end
end
