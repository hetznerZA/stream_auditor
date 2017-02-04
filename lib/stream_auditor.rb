require "stream_auditor/version"
require "soar_auditor_api/auditor_api"
require "fileutils"

class StreamAuditor < SoarAuditorApi::AuditorAPI

  def audit(data)
    stream << data.to_s.chomp + "\n"
    stream.flush
  end

  def configure(configuration = nil)
    super
    if configuration
      s = configuration["stream"]
      @stream = if want_stdout_stream?(s) then $stdout
                elsif want_stderr_stream?(s) then $stderr
                elsif want_io_stream?(s) then s
                elsif want_path_stream?(s) then creative_open_file(s)
                end
    end
  end

  def configuration_is_valid?(configuration)
    return false unless (configuration.keys - ["adaptor", "stream"]).empty?

    s = configuration["stream"]
    want_default_stream?(s) or want_stderr_stream?(s) or want_stdout_stream?(s) or want_io_stream?(s) or want_path_stream?(s)
  end

  private

  def creative_open_file(path)
    FileUtils.mkdir_p(File.expand_path("..", path), mode: 0700)
    File.open(path, "a", 0600)
  end

  def stream
    @stream || $stderr
  end

  def want_default_stream?(s)
    s.nil?
  end

  def want_io_stream?(s)
    s.respond_to?(:<<) and s.respond_to?(:flush)
  end

  def want_path_stream?(s)
    s.respond_to?(:start_with?) and (!s.start_with?("$")) and !!(File.expand_path(s) rescue false)
  end

  def want_stderr_stream?(s)
    s == "$stderr"
  end

  def want_stdout_stream?(s)
    s == "$stdout"
  end

end
