require 'spec_helper'

describe Shuttle::Target do
  describe '#connection' do
    subject do
      Shuttle::Target.new(
        :host     => 'host.com', 
        :user     => 'user',
        :password => 'password'
      )
    end

    it 'returns a new ssh session connection' do
      subject.connection.should be_a Net::SSH::Session
    end
  end

  describe '#validate!' do
    subject { Shuttle::Target.new(attributes) }

    context 'with valid attributes' do
      let(:attributes) do
        {:host => 'host.com', :user => 'user', :deploy_to => '/home'}
      end

      it 'does not raise errors' do
        expect { subject.validate! }.not_to raise_error
      end
    end

    context 'with incomplete attributes' do
      let(:attributes) do
        {:host => 'host.com', :user => 'user'}
      end

      it 'raises error' do
        expect { subject.validate! }.to raise_error Shuttle::ConfigError, "Deploy path required" 
      end
    end
  end
end