require 'spec_helper'

describe Shuttle::CLI do
  describe '#initialize' do
    it 'assigns current path' do
      Dir.stub(:pwd).and_return('/home/user')
      cli = Shuttle::CLI.new
      expect(cli.path).to eq '/home/user'
    end

    it 'assigns specified path' do
      cli = Shuttle::CLI.new('/foo/bar')
      expect(cli.path).to eq '/foo/bar'
    end

    it 'assigns default options' do
      cli = Shuttle::CLI.new
      expect(cli.options).to be_a Hash
      expect(cli.options).not_to be_empty
    end
  end

  describe '#default_options' do
    let(:opts) { Shuttle::CLI.new.default_options }

    it 'returns a hash with default options' do
      expect(opts).to be_a Hash
      expect(opts[:path]).to eq nil
      expect(opts[:target]).to eq 'production'
      expect(opts[:log]).to eq false
    end
  end

  describe '#parse_command' do
    let(:cli) { Shuttle::CLI.new }

    context 'with no arguments' do
      before do
        ARGV.stub(:size).and_return(0)
        cli.should_receive(:terminate).with("Command required")
      end

      it 'terminates execution with message' do
        cli.parse_command
      end
    end

    context 'with 1 argument' do
      before do
        ARGV = %w(deploy)
      end

      it 'sets command' do
        cli.parse_command
        expect(cli.command).to eq 'deploy'
      end
    end

    context 'with 2 arguments' do
      before do
        ARGV = %w(staging deploy)
        cli.parse_command
      end

      it 'assigns deployment target' do
        expect(cli.options[:target]).to eq 'staging'
      end

      it 'assigns command' do
        expect(cli.command).to eq 'deploy'
      end
    end

    context 'with too many arguments' do
      before do
        ARGV.stub(:size).and_return(3)
        cli.should_receive(:terminate).with("Maximum of 2 arguments allowed")
      end

      it 'terminates execution with message' do
        cli.parse_command
      end
    end
  end
end