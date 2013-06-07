require 'spec_helper'

class Helpers ; include Shuttle::PathHelpers ; end

describe Shuttle::PathHelpers do
  let(:target) do
    Hashr.new(:deploy_to => '/tmp')
  end

  subject { Helpers.new }
  before  { subject.stub(:target).and_return(target) }

  describe '#deploy_path' do
    it 'returns application deployment path' do
      expect(subject.deploy_path).to eq '/tmp'
    end
  end

  describe '#shared_path' do
    it 'returns shared deployment path' do
      expect(subject.shared_path).to eq '/tmp/shared'
    end
  end

  describe '#release_path' do
    before { subject.stub(:version).and_return(1) }

    it 'returns current release path' do
      expect(subject.release_path).to eq '/tmp/releases/1'
    end
  end

  describe '#current_path' do
    it 'returns current linked release path' do
      expect(subject.current_path).to eq '/tmp/current'
    end
  end

  describe '#version_path' do
    it 'returns version file path' do
      expect(subject.version_path).to eq '/tmp/version'
    end
  end

  describe '#scm_path' do
    it 'returns project repository path' do
      expect(subject.scm_path).to eq '/tmp/scm'
    end
  end
end