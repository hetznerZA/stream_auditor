# StreamAuditor

This is an IO stream auditor for the [SOAR Auditing Provider](https://github.com/hetznerZA/soar_auditing_provider).

It supports auditing to the standard error and output streams, to a file path (in append mode) or to an already open IO object.
In all cases, the stream is flushed on every audit call.

## Documentation

For documentation of the released gem, see [rubydoc.info](http://www.rubydoc.info/gems/stream_auditor).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stream_auditor'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stream_auditor

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/hetznerZA/stream_auditor).

