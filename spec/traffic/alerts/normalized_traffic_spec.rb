require 'app_helper'

RSpec.describe Traffic::Alerts::NormalizedTraffic do
  subject { described_class.new }

  describe '#new' do
    it 'creates an instance of a NormalizedTraffic alert' do
      expect(subject).to be_an_instance_of described_class
    end

    it 'sets an alert type to `:normalized_traffic`' do
      expect(subject.type).to eq :normalized_traffic
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

    let(:data) { { threshold: 2, ttl: 1 } }

    context 'when dataset is valid' do
      before do
        subject.prepare(data)
      end

      it 'sets an alerting message' do
        expect(subject.message).to include(
          'High traffic alert RECOVERED at',
          'Total traffic for the last two minutes:  1',
          'Current threshold value:                 2'
        )
      end
    end
  end
end
