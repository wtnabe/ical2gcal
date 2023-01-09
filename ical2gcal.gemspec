# frozen_string_literal: true

require_relative "lib/ical2gcal/version"

Gem::Specification.new do |spec|
  spec.name = "ical2gcal"
  spec.version = Ical2gcal::VERSION
  spec.authors = ["wtnabe"]
  spec.email = ["18510+wtnabe@userspec.noreply.github.com"]

  spec.summary = "sync ics(es) to google calendar"
  spec.description = "You can sync local and remote ics file(s) to google calendar"
  spec.homepage = "http://github.com/wtnabe/ical2gcal"
  spec.required_ruby_version = ">= 2.5.0"
  spec.licenses = ["BSD-2-Clause"]

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "ri_cal", ">= 0"
  spec.add_dependency "google-api-client", "< 0.8"
  spec.add_dependency "faraday", "< 1"
  spec.add_dependency "retriable", "< 3"
  spec.add_dependency "launchy"
end
