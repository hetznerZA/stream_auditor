require "spec_helper"


describe StreamAuditor do

  it "is a SOAR auditing provider" do
    require "soar_auditing_provider"
    require "stream_auditor"

    config = {
      "auditing" => {
        "provider" => "SoarAuditingProvider::AuditingProvider",
        "level" => "debug",
        "install_exit_handler" => "false", # Writes to stderr after rspec closes it.
        "direct_auditor_call" => "true",   # Should obviate queue worker, but currently doesn't.
        "queue_worker" => {                # Minimal queue worker config to pass validation.
          "queue_size" => 1,
          "back_off_attempts" => 1
        },
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
