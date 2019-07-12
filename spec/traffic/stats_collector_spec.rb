require 'app_helper'

RSpec.describe Traffic::StatsCollector do
  subject { described_class.new(format, file, threshold) }

  let(:format)    { '%h %l %u %t \"%r\" %>s %b' }
  let(:file)      { 'access.log' }
  let(:threshold) { 1 }

  let(:log_line) do
    '127.0.0.1 - james [09/May/2018:16:00:39 +0000] ' \
      '"GET /accounts HTTP/1.0" 200 123'
  end

  let(:ten_secs) do
    {
      file: file,
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

  let(:two_mins) { { threshold: threshold, ttl: 0 } }

  describe '#new' do
    it 'creates an instance of a traffic statistics collector' do
      expect(subject).to be_an_instance_of described_class
    end

    it 'sets a ten seconds statistics container to a default state' do
      expect(subject.ten_secs).to eq ten_secs
    end

    it 'sets a two minutes statistics container to a default state' do
      expect(subject.two_mins).to eq two_mins
    end
  end

  describe '#consider' do
    let(:ten_secs) do
      {
        file: file,
        ttl: 1,
        ttl_bytes: 123,
        biggest_request: 123,
        sections: { 'accounts' => 1 },
        hosts: { '127.0.0.1' => 1 },
        users: { 'james' => 1 },
        methods: { 'GET' => 1 },
        statuses: { 200 => 1 }
      }
    end

    let(:two_mins) { { threshold: threshold, ttl: 1 } }

    before do
      subject.consider(log_line)
    end

    it 'populates a ten seconds statistics container' do
      expect(subject.ten_secs).to eq ten_secs
    end

    it 'populates a two minutes statistics container' do
      expect(subject.two_mins).to eq two_mins
    end
  end

  describe '#reset' do
    before do
      subject.consider(log_line)
    end

    it 'resets a ten seconds statistics container to a default state' do
      subject.reset(:ten_secs)
      expect(subject.ten_secs).to eq ten_secs
    end

    it 'resets a two minutes statistics container to a default state' do
      subject.reset(:two_mins)
      expect(subject.two_mins).to eq two_mins
    end
  end
end
