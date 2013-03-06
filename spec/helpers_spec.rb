require 'spec_helper'

describe Shuttle::Helpers do
  class Klass ; include Shuttle::Helpers ; end
  let(:subject) { Klass.new }

  it { should respond_to :log }
  it { should respond_to :error }
  it { should respond_to :git_installed? }
  it { should respond_to :svn_installed? }
  it { should respond_to :release_exists? }
  it { should respond_to :stream_output }

  describe '#log' do
    it 'prints a formatted message' do
      STDOUT.should_receive(:puts).with('-----> message')
      subject.log('message')
    end
  end

  describe '#error' do
    it 'prints an error message' do
      STDOUT.should_receive(:puts).with('-----> ERROR: message')
      expect { subject.error('message') }.to raise_error Shuttle::DeployError
    end

    it 'raises a deploy error' do
      STDOUT.stub(:puts)
      expect { subject.error('message') }.to raise_error Shuttle::DeployError, 'message'
    end
  end

  describe '#stream_output' do
    let(:string) { "line1\nline2\nline3\n\n" }

    it 'prints a formatted string' do
      result = "       line1\n       line2\n       line3"
      STDOUT.should_receive(:puts).with(result)
      subject.stream_output(string)
    end
  end
end