require "soar_auditor_api/auditor_api"
require "stream_auditor_version"

class StreamAuditor < SoarAuditorApi::AuditorAPI
  VERSION = StreamAuditorVersion::VERSION
end
