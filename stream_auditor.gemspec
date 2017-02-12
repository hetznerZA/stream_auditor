# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'stream_auditor_version'

Gem::Specification.new do |spec|
  spec.name          = "stream_auditor"
  spec.version       = StreamAuditorVersion::VERSION
  spec.authors       = ["Sheldon Hearn"]
  spec.email         = ["sheldonh@starjuice.net"]

  spec.summary       = %q{IO stream implementation of SOAR architecture auditing}
  spec.description   = %q{IO stream implementation of SOAR architecture auditing allowing easy publishing of events to a standard IO stream, (e.g. stderr)}
  spec.homepage      = "https://github.com/hetznerZA/stream_auditor"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "soar_auditing_provider", "~> 2.0"

  spec.add_dependency "soar_auditor_api", "~> 1.0"
end
