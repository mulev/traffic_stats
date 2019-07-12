require 'app_helper'

RSpec.describe Traffic::Watcher do
  subject { described_class.new(opts) }

  let(:format)    { '%h %l %u %t \"%r\" %>s %b' }
  let(:file)      { 'log/access.log' }
  let(:threshold) { 1 }
  let(:opts)      { { source: file, threshold: threshold, format: format } }

  describe '#new' do
    it 'creates an instance of a traffic log watcher' do
      expect(subject).to be_an_instance_of described_class
    end
  end
end
