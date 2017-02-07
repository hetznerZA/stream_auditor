require "stream_auditor/version"
require "soar_auditor_api/auditor_api"
require "fileutils"

##
# An IO stream (or file) implementation of {http://www.rubydoc.info/gems/soar_auditor_api/SoarAuditorApi/AuditorAPI SoarAuditorApi::AuditorAPI}
#
# This implementation supports auditing to:
#
# * an already open +IO+ object (or anything that implements +IO#<<+ and +IO#flush+),
# * the standard error stream ($stderr),
# * the standard output stream ($stdout), or
# * a file.
#
# Developers should not need to work directly with this class. Instead, they should configure it through the
# {http://www.rubydoc.info/gems/soar_auditing_provider/SoarAuditingProvider/AuditingProvider SOAR auditing provider}.
#
# @example Log to file
#
#  require "soar_auditing_provider"
#  require "stream_auditor"
#
#  config = {
#    "auditing" => {
#      "provider" => "SoarAuditingProvider::AuditingProvider",
#      "level" => "debug",
#      "direct_auditor_call" => "true",
#      "auditors" => {
#        "local" => {
#          "adaptor" => "StreamAuditor",
#          "stream" => "/var/log/application.log"
#        }
#      }
#    }
#  }
#
#  auditor = SoarAuditingProvider::AuditingProvider.new(config["auditing"])
#  auditor.info("Auditor initialized")
#
class StreamAuditor < SoarAuditorApi::AuditorAPI

  ##
  # Write data to the configured stream
  #
  # The stream is immediately flushed after the data is written.
  #
  # @param [Object] data
  #   the +String+ (or +Object+ with +to_s+ method) to write.
  #   If the string is not newline-terminated, a newline is added.
  #
  def audit(data)
    stream << data.to_s.chomp + "\n"
    stream.flush
  end

  ##
  # Apply the configuration supplied to {http://www.rubydoc.info/gems/soar_auditor_api/SoarAuditorApi/AuditorAPI#initialize-instance_method initialize}
  #
  # @param [Hash] configuration
  #   This method accepts +nil+ or a +Hash+, but the auditor API only calls
  #   this method when the configuration is not +nil+.
  #
  #   The configuration may contain the following +String+ keys:
  #
  #   * +adaptor+ - ignored (for compatibility with the SOAR auditing provider
  #   * +stream+  - the stream to audit to, one of:
  #
  #     * an +IO+ object (or anything that implements +IO#<<+ and +IO#flush+)
  #     * the string +$stderr+ for the standard error stream
  #     * the string +$stdout+ for the standard output stream
  #     * the string path to a file
  #
  #   If the +stream+ key is ommitted, the default is +$stderr+.
  #
  #   When the stream is the path to a file:
  #
  #   * any missing intermediate directories will be created (mode 0700),
  #   * the file will be created if missing (mode 0600),
  #   * the file is opened in append mode.
  #
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

  ##
  # Validates the configuration
  #
  # @param [Hash] configuration
  #   the configuration to validate
  #
  # @return [true] if the configuration is valid
  # @return [false] if the configuration is invalid
  #
  # @see #configure
  #
  def configuration_is_valid?(configuration)
    return false unless (configuration.keys - ["adaptor", "stream"]).empty?

    s = configuration["stream"]
    want_default_stream?(s) or want_stderr_stream?(s) or want_stdout_stream?(s) or want_io_stream?(s) or want_path_stream?(s)
  end

  ##
  # Hint direct auditor call preference to SOAR Auditor API
  #
  # @return [true] always
  #
  def prefer_direct_call?
    true
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
