require 'spec_helper'

describe Shuttle::CLI do
  let(:cli) { Shuttle::CLI.new }

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
    let(:opts) { cli.default_options }

    it 'returns a hash with default options' do
      expect(opts).to be_a Hash
      expect(opts[:path]).to eq nil
      expect(opts[:target]).to eq 'production'
      expect(opts[:log]).to eq false
    end
  end

  describe '#parse_command' do
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

  describe '#try_config' do
    it 'does not change path if file does not exist' do
      File.stub(:exists?).and_return(false)

      expect(cli.try_config('foo/bar')).to eq false
      expect(cli.options[:path]).to eq nil
    end

    it 'changes config path if file exists' do
      File.stub(:exists?).with('foo/bar').and_return(true)

      expect(cli.try_config('foo/bar')).to eq true
      expect(cli.options[:path]).to eq 'foo/bar'
    end
  end

  describe '#find_config' do
    let(:path) { "/tmp" }
    let(:cli)  { Shuttle::CLI.new(path) }

    it 'searches for ./shuttle.yml file' do
      File.should_receive(:exists?).with("/tmp/shuttle.yml").and_return(true)
      cli.find_config
      expect(cli.options[:path]).to eq "/tmp/shuttle.yml"
    end

    it 'searches for ./config/deploy.yml file' do
      File.should_receive(:exists?).with("/tmp/shuttle.yml").and_return(false)
      File.should_receive(:exists?).with("/tmp/config/deploy.yml").and_return(true)

      cli.find_config
      expect(cli.options[:path]).to eq "/tmp/config/deploy.yml"
    end

    it 'searches for ./config/deploy/production.yml' do
      File.should_receive(:exists?).with("/tmp/shuttle.yml").and_return(false)
      File.should_receive(:exists?).with("/tmp/config/deploy.yml").and_return(false)
      File.should_receive(:exists?).with("/tmp/config/deploy/production.yml").and_return(true)

      cli.find_config
      expect(cli.options[:path]).to eq "/tmp/config/deploy/production.yml"
    end

    it 'searches foe ~/.shuttle/NAME.yml' do
      ENV['HOME'] = "/tmp"
      File.should_receive(:exists?).with("/tmp/shuttle.yml").and_return(false)
      File.should_receive(:exists?).with("/tmp/config/deploy.yml").and_return(false)
      File.should_receive(:exists?).with("/tmp/config/deploy/production.yml").and_return(false)
      File.should_receive(:exists?).with("/tmp/.shuttle/shuttle.yml").and_return(true)
      
      cli.find_config
      expect(cli.options[:path]).to eq '/tmp/.shuttle/shuttle.yml'
    end

    it 'terminates if no config files found' do
      ENV['HOME'] = "/tmp"
      File.should_receive(:exists?).with("/tmp/shuttle.yml").and_return(false)
      File.should_receive(:exists?).with("/tmp/config/deploy.yml").and_return(false)
      File.should_receive(:exists?).with("/tmp/config/deploy/production.yml").and_return(false)
      File.should_receive(:exists?).with("/tmp/.shuttle/shuttle.yml").and_return(false)

      expect { cli.find_config }.to raise_error SystemExit
    end
  end
end