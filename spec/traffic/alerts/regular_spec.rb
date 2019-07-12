require 'app_helper'

RSpec.describe Traffic::Alerts::Regular do
  subject { described_class.new }

  describe '#new' do
    it 'creates an instance of a Regular alert' do
      expect(subject).to be_an_instance_of described_class
    end

    it 'sets an alert type to `:regular`' do
      expect(subject.type).to eq :regular
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

    context 'when dataset is valid, but empty' do
      before do
        subject.prepare(data)
      end

      it 'sets a default message' do
        expect(subject.message).to include(
          'Total traffic:       0 hit(-s)',
          'Top 10 sections:     no data about sections',
          'Top 10 users:        no data about users',
          'Top 10 IPs (hosts):  no data about hosts'
        )
      end
    end

    context 'when dataset contains calculations' do
      before do
        data[:ttl] = 1
        data[:ttl_bytes] = 123
        data[:biggest_request] = 123
        data[:sections]['regular'] = 1
        data[:users]['james'] = 1
        data[:hosts]['localhost'] = 1
        data[:methods]['GET'] = 1
        data[:statuses][200] = 1

        subject.prepare(data)
      end

      it 'sets a message with traffic statistics from a dataset' do
        expect(subject.message).to include(
          'Total traffic:       1 hit(-s)',
          'Top 10 sections:     regular => 1 hit(-s)',
          'Top 10 users:        james => 1 hit(-s)',
          'Top 10 IPs (hosts):  localhost => 1 hit(-s)'
        )
      end
    end
  end
end
