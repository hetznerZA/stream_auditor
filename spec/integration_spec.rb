require "spec_helper"


describe StreamAuditor do

  it "is a SOAR auditing provider" do
    require "soar_auditing_provider"
    require "stream_auditor"

    config = {
      "auditing" => {
        "provider" => "SoarAuditingProvider::AuditingProvider",
        "install_exit_handler" => "false", # Writes to stderr after rspec closes it.
        "direct_auditor_call" => "true",
        "auditors" => {
          "local" => {
            "adaptor" => "StreamAuditor"
          }
        }
      }
    }
    auditor = SoarAuditingProvider::AuditingProvider.new(config["auditing"])
    auditor.service_identifier = "my-service"
    expect { auditor.info("Something happened") }.to output(/^info,my-service,.+,Something happened\n/).to_stderr
  end

end
