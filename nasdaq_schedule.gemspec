# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'nasdaq_schedule/version'

Gem::Specification.new do |spec|
  spec.name          = "nasdaq_schedule"
  spec.version       = NasdaqSchedule::VERSION
  spec.authors       = ["Kamil Leczycki"]
  spec.email         = ["camol88@gmail.com"]
  spec.summary       = %q{Provide informations about NASDAQ trading schedule.}
  spec.description   = %q{Ruby gem extension for ActiveSupport::TimeWithZone. Responsible for giving detailed informations about NASDAQ stock market trading schedule.}
  spec.homepage      = "https://github.com/camol/nasdaq_schedule"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "holidays"
  spec.add_development_dependency "rspec"
end
