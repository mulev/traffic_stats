require 'app_helper'

RSpec.describe Traffic::Parser do
  subject { described_class.new('%h %l %u %t \"%r\" %>s %b') }

  describe '#new' do
    it 'creates an instance of a traffic log parser' do
      expect(subject).to be_an_instance_of described_class
    end
  end

  describe '#parse' do
    context 'when given a valid log line' do
      let(:line) do
        '127.0.0.1 - james [09/May/2018:16:00:39 +0000] ' \
          '"GET /accounts HTTP/1.0" 200 123'
      end

      let(:dataset) do
        {
          host: '127.0.0.1',
          logname: '-',
          user: 'james',
          datetime: DateTime.new(2018, 5, 9, 16, 0, 39),
          request: {
            method: 'GET',
            path: { full: "/accounts", section: "accounts"},
            proto: 'HTTP/1.0'
          },
          status: 200,
          bytes: 123
        }
      end

      it 'returns a hash with log line data' do
        expect(subject.parse(line)).to eq dataset
      end
    end

    context 'when log line is not in Apache format' do
      it 'returns nil' do
        expect(subject.parse('line')).to be_nil
      end
    end
  end
end
