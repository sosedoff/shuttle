require 'spec_helper'

describe Shuttle::Target do
  let(:target) { Shuttle::Target.new(attributes) }

  describe '#connection' do
    let(:attributes) do
      { :host => 'host.com', :user => 'user', :password => 'password' }
    end

    it 'returns a new ssh session connection' do
      expect(target.connection).to be_a Net::SSH::Session
    end
  end

  describe '#validate!' do
    context 'with valid attributes' do
      let(:attributes) do
        {:host => 'host.com', :user => 'user', :deploy_to => '/home'}
      end

      it 'does not raise errors' do
        expect { target.validate! }.not_to raise_error
      end
    end

    context 'with incomplete attributes' do
      let(:attributes) do
        {:host => 'host.com', :user => 'user'}
      end

      it 'raises error' do
        expect { target.validate! }.to raise_error Shuttle::ConfigError, "Deploy path required" 
      end
    end
  end
end