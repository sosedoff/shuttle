require "spec_helper"

describe Shuttle::Task do
  let(:config) { double(tasks: tasks) }
  let(:deploy) { double(config: config) }
  let(:task)   { described_class.new(deploy, "foo") }

  before do
    allow(task).to receive(:execute)
  end

  describe "#run" do
    context "when task does not exist" do
      let(:tasks) { Hashr.new }

      before do
        allow(deploy).to receive(:error) { raise Shuttle::DeployError }
      end

      it "triggers deployment error" do
        expect { task.run }.to raise_error Shuttle::DeployError
      end
    end

    context "when task does not have commands" do
      let(:tasks) { Hashr.new(foo: []) }

      before do
        task.run
      end

      it "does not execute any commands" do
        expect(task).to have_received(:execute).exactly(0).times
      end
    end

    context "when task has commands" do
      let(:tasks) { Hashr.new(foo: ["cmd1", "cmd2"]) }

      before do
        task.run
      end

      it "executes all commands" do
        expect(task).to have_received(:execute).with("foo", "cmd1", false)
        expect(task).to have_received(:execute).with("foo", "cmd2", false)
      end
    end
  end
end