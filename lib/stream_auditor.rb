require "stream_auditor/version"
require "soar_auditor_api/auditor_api"
require "fileutils"

class StreamAuditor < SoarAuditorApi::AuditorAPI

  DEFAULT_CONFIGURATION = {
    "standard_stream" => "stderr"
  }

  MODE_VALIDATORS = {
    "io" => ->(v) { v.respond_to?(:<<) },
    "path" => ->(v) { File.expand_path(v) rescue false },
    "standard_stream" => ->(v) { ["stderr", "stdout"].include?(v) }
  }
  MODES = MODE_VALIDATORS.keys

  def initialize(configuration = nil)
    configuration = cleanup_configuration(configuration)
    super
  end

  def audit(data)
    @stream << data.to_s.chomp + "\n"
    @stream.flush
  end

  def configure(configuration = nil)
    configuration = cleanup_configuration(configuration)
    super
    @stream = nil
    @stream = configuration["io"] if configuration["io"]
    @stream = standard_stream(configuration["standard_stream"]) if configuration["standard_stream"]
    @stream = creative_open_file(configuration["path"]) if configuration["path"]
  end

  def configuration_is_valid?(configuration)
    configuration = cleanup_configuration(configuration)

    1 == configuration.keys.size and
      1 == configuration.keys.count { |key| MODES.include?(key) } and
      MODE_VALIDATORS.all? { |mode, validator| configuration[mode].nil? or validator.call(configuration[mode]) }
  end

  private

  # XXX Fight the auditor API
  #
  # The auditor API:
  #
  # * doesn't run the configure method at all for nil configuration,
  # * validates non-nil configuration, and
  # * receives and passes through the "adaptor" configuration key from the SOAR auditing provider.
  #
  def cleanup_configuration(configuration)
    configuration = (configuration || {}).reject { |k, v| k == "adaptor" }

    if configuration.empty?
      DEFAULT_CONFIGURATION
    else
      configuration
    end
  end

  # XXX Fight rspec
  #
  # From the rspec-expectations documentation:
  #
  #     Note: to_stdout and to_stderr work by temporarily replacing $stdout or $stderr,
  #     so they're not able to intercept stream output that explicitly uses STDOUT/STDERR
  #     or that uses a reference to $stdout/$stderr that was stored before the matcher was used.
  #
  def standard_stream(stream_name)
    case stream_name
    when "stderr"
      $stderr
    when "stdout"
      $stdout
    else
      raise ArgumentError, "unknown stream name #{stream_name.inspect}"
    end
  end

  def creative_open_file(path)
    FileUtils.mkdir_p(File.expand_path("..", path), mode: 0700)
    File.open(path, "a")
  end

end
