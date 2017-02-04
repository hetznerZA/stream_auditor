require "stream_auditor/version"
require "soar_auditor_api/auditor_api"
require "fileutils"

class StreamAuditor < SoarAuditorApi::AuditorAPI

  MODES = {
    "io" => {
      validator: ->(v) { v.respond_to?(:<<) },
      constructor: ->(v) { v },
    },
    "path" => {
      validator: ->(v) { File.expand_path(v) rescue false },
      constructor: ->(v) { creative_open(v) },
    },
    "standard_stream" => {
      validator: ->(v) { ["stderr", "stdout"].include?(v) },
      constructor: ->(v) { standard_stream(v) },
    }
  }

  MODE_VALIDATORS = MODES.inject({}) { |modes, (mode, config)| modes.tap { |m| m[mode] = config[:validator] } }
  VALID_CONFIGURATION_KEYS = MODES.keys + ["adaptor"]

  def audit(data)
    stream << data.to_s.chomp + "\n"
    stream.flush
  end

  def configure(configuration = nil)
    super
    @stream = if configuration["io"]
                configuration["io"]
              elsif configuration["standard_stream"]
                standard_stream(configuration["standard_stream"])
              elsif configuration["path"]
                creative_open_file(configuration["path"])
              end
  end

  def configuration_is_valid?(configuration)
    configuration.keys.all? { |key| VALID_CONFIGURATION_KEYS.include?(key) } and
      MODE_VALIDATORS.all? { |mode, validator| configuration[mode].nil? or validator.call(configuration[mode]) }
  end

  private

  # Used to defer reference to standard streams until after instantiation
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

  def stream
    @stream || $stderr
  end

end
