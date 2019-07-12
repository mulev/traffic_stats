require 'app_helper'

RSpec.describe Traffic::Alerts::Basic do
  let(:type) { :regular }

  describe '#new' do
    context 'when called with a type' do
      let(:type) { :regular }

      it 'creates an instance of a basic alert' do
        expect(described_class.new(type: type)).to be_an_instance_of described_class
      end

      it 'sets an alert status to `:new`' do
        expect(described_class.new(type: type).status).to eq :new
      end

      it 'sets an alert type to a given type' do
        expect(described_class.new(type: type).type).to eq type
      end
    end

    context 'when called without a type' do
      it 'raises an error' do
        expect { described_class.new }.to raise_error ArgumentError
      end
    end
  end

  describe '#prepare' do
    it 'raises a NotImplementedError' do
      expect { described_class.new(type: type).prepare('foo') }.to raise_error(
        NotImplementedError,
        'Basic alert can not be prepared, use specific alerts'
      )
    end
  end

  describe '#mark_published' do
    it 'sets the alert status to `:published`' do
      alert = described_class.new(type: type)
      alert.mark_published
      expect(alert.status).to eq :published
    end
  end
end
