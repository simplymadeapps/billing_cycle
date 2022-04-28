# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "billing_cycle/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "billing_cycle"
  s.version     = BillingCycle::VERSION
  s.authors     = ["Brian Pattison"]
  s.email       = ["brian@brianpattison.com"]
  s.homepage    = "https://github.com/simplymadeapps/billing_cycle"
  s.summary     = "Utility for calculating the next billing date for a recurring subscription."
  s.description = "Billing Cycle is a gem used to calculate the next billing date for a recurring subscription."
  s.license     = "MIT"

  s.required_ruby_version = ">= 2.7.0"

  s.metadata["homepage_uri"] = spec.homepage
  s.metadata["source_code_uri"] = spec.homepage
  s.metadata["changelog_uri"] = "https://www.github.com/simplymadeapps/billing_cycle/CHANGELOG.md"
  s.metadata["rubygems_mfa_required"] = "true"

  s.files = Dir["{lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "activesupport", ">= 6.0"
  s.add_development_dependency "appraisal"
  s.add_development_dependency "codeclimate-test-reporter"
  s.add_development_dependency "rainbow"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rubocop"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "simplecov-rcov"
end
