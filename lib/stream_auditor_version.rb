##
# Provide the gem version in a module.
#
# This works around bundler install failing because the StreamAuditor
# class definition depends on a gem that is not yet installed.
#
module StreamAuditorVersion
  VERSION = "1.2.1"
end
