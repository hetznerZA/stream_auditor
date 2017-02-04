# StreamAuditor

This is an IO stream auditor for the [SOAR Auditing Provider](https://github.com/hetznerZA/soar_auditing_provider).

It supports auditing to the standard error and output streams, to a file path (in append mode) or to an already open IO object.
In all cases, the stream is flushed on every audit call.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stream_auditor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stream_auditor

## Usage

Configuration of the SOAR auditing provider is still chunky. The `queue_worker` config is not required for the stream auditor, but
the auditing provider insists on it. So for now:

```ruby
# Log to stderr
config = {
  "auditing" => {
    "provider" => "SoarAuditingProvider::AuditingProvider",
    "level" => "debug",
    "install_exit_handler" => "true",
    "direct_auditor_call" => "true",
    "queue_worker" => {
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
SoarAuditingProvider::AuditingProvider.new(config["auditing"])

# Log to stdout
config = {
  "auditing" => {
    "provider" => "SoarAuditingProvider::AuditingProvider",
    "level" => "debug",
    "install_exit_handler" => "true",
    "direct_auditor_call" => "true",
    "queue_worker" => {
      "queue_size" => 1,
      "back_off_attempts" => 1
    },
    "auditors" => {
      "local" => {
        "adaptor" => "StreamAuditor",
        "stream" => "$stdout"
      }
    }
  }
}
SoarAuditingProvider::AuditingProvider.new(config["auditing"])

# Log to file in append mode
config = {
  "auditing" => {
    "provider" => "SoarAuditingProvider::AuditingProvider",
    "level" => "debug",
    "install_exit_handler" => "true",
    "direct_auditor_call" => "true",
    "queue_worker" => {
      "queue_size" => 1,
      "back_off_attempts" => 1
    },
    "auditors" => {
      "local" => {
        "adaptor" => "StreamAuditor",
        "stream" => "/var/log/application.log"
      }
    }
  }
}
SoarAuditingProvider::AuditingProvider.new(config["auditing"])

# Log to IO object
config = {
  "auditing" => {
    "provider" => "SoarAuditingProvider::AuditingProvider",
    "level" => "debug",
    "install_exit_handler" => "true",
    "direct_auditor_call" => "true",
    "queue_worker" => {
      "queue_size" => 1,
      "back_off_attempts" => 1
    },
    "auditors" => {
      "local" => {
        "adaptor" => "StreamAuditor",
        "stream" => File.open("/var/log/application.log", "a")
      }
    }
  }
}
SoarAuditingProvider::AuditingProvider.new(config["auditing"])
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/hetznerZA/stream_auditor).

