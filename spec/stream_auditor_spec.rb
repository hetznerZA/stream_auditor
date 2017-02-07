require 'spec_helper'

require 'support/stream_spy'
require 'tempfile'

describe StreamAuditor do

  context "when extending from AuditorAPI" do
    it 'should adhere to auditor api by not preventing exceptions' do
      expect {
        subject.configure(anything: "specified")
      }.to raise_error(ArgumentError, "Invalid configuration provided")
      expect {
        subject.set_audit_level(:something)
      }.to raise_error(ArgumentError, "Invalid audit level specified")
    end

    it 'has a method audit' do
      expect(subject.respond_to?('audit')).to eq(true)
    end

    it 'has a method configuration_is_valid?' do
      expect(subject.respond_to?('configuration_is_valid?')).to eq(true)
    end

    it 'has a method prefer_direct_call?' do
      expect(subject.respond_to?('prefer_direct_call?')).to eq(true)
    end
  end

  context "when configured by AuditorAPI" do
    it 'should accept empty configuration' do
      expect(subject.configuration_is_valid?({})).to eq(true)
    end

    it 'should cope with being passed the adaptor class name' do
      expect(subject.configuration_is_valid?("adaptor" => "AnyClassName")).to eq(true)
    end

    it 'should accept a valid io configuration' do
      expect(subject.configuration_is_valid?("stream" => $stderr)).to eq(true)
    end

    it 'should accept a valid standard stream configuration' do
      expect(subject.configuration_is_valid?("stream" => "$stderr")).to eq(true)
    end

    it 'should accept a valid path configuration' do
      expect(subject.configuration_is_valid?("stream" => "/var/log/stream_auditor.log")).to eq(true)
    end

    it 'should reject an invalid io configuration' do
      expect(subject.configuration_is_valid?("stream" => Object.new)).to eq(false)
    end

    it 'should reject an invalid path configuration' do
      expect(subject.configuration_is_valid?("stream" => "\0")).to eq(false)
    end

    it 'should reject an invalid standard stream configuration' do
      expect(subject.configuration_is_valid?("stream" => "$stdweird")).to eq(false)
    end
  end

  context "when configured to audit to an IO object" do
    let(:stream) { StreamSpy.new }
    subject { StreamAuditor.new("stream" => stream) }

    it "should submit audit to the stream with data received" do
      subject.audit("Something happened")
      expect(stream.received).to include("Something happened\n")
    end

    it "should raise StandardError if a write error occurs" do
      stream.fail_next_write("intentional write failure")
      expect { subject.audit("Something happened") }.to raise_error(StandardError, /intentional write failure/)
    end
  end

  context "when configured to audit to a file path" do
    let(:base) { Tempfile.open('stream_auditor_spec') { |io| io.path }.tap { |p| File.unlink(p) } }
    let(:path) { base }
    subject { StreamAuditor.new("stream" => path) }

    after(:each) do
      FileUtils.rm_rf(base)
    end

    it "should append audit to the file with data received" do
      File.write(path, "After time...\n")
      subject.audit("Something happened")
      expect(File.read(path)).to eql "After time...\nSomething happened\n"
    end

    it "should raise StandardError if a write error occurs" do
      FileUtils.touch(path)
      File.chmod(0444, path)
      expect { subject.audit("Something happened") }.to raise_error(StandardError, /permission denied/i)
    end

    context "when the file and parent directories are missing" do
      let(:path) { "#{base}/bar/baz" }

      it "should create the file and parent directories" do
        subject.audit("Something happened")
        expect(File.read(path)).to eql "Something happened\n"
      end

      it "should create the file with mode 0600" do
        subject.audit("Something happened")
        expect(File.stat(path).mode).to eql 0100600
      end

      it "should create parent directories with mode 0700" do
        subject.audit("Something happened")
        expect(File.stat(base).mode).to eql 040700
      end

    end
  end

  context "when configured to audit to the standard error stream" do
    subject { StreamAuditor.new("stream" => "$stderr") }

    it "should submit audit to the standard error stream with data received" do
      expect { subject.audit("Something happened") }.to output("Something happened\n").to_stderr
    end

    it "should raise StandardError if a write error occurs" do
      $stderr.close
      expect { subject.audit("Something happened") }.to raise_error(StandardError, /closed stream/)
    end
  end

  context "when configured to audit to the standard output stream" do
    subject { StreamAuditor.new("stream" => "$stdout") }

    it "should submit audit to the standard output stream with data received" do
      expect { subject.audit("Something happened") }.to output("Something happened\n").to_stdout
    end

    it "should raise StandardError if a write error occurs" do
      pending "Can't close stdout without disrupting rspec's output"
      expect { subject.audit("Something happened") }.to raise_error(StandardError, /closed stream/)
    end
  end

  context "when not configured" do

    it "should default to auditing to the standard error stream" do
      expect { subject.audit("Something happened") }.to output("Something happened\n").to_stderr
    end

  end

end
