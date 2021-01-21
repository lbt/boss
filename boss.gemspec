# -*- encoding: utf-8 -*-
# stub: boss 0.9.2 ruby lib

Gem::Specification.new do |s|
  s.name = "boss"
  s.version = "0.9.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]

  s.authors = ["David Greaves and other Jolla sailors"]
  s.date = "2019-12-28"
  s.description = "BOSS packaging gem"
  s.email = "david.greaves@jolla.com"
  s.files = [
    "bin/boss",
    "bin/boss_check_pdef",
    "bin/boss_clean_errors",
    "bin/boss_clean_processes",
    "lib/boss.rb",
    "lib/boss/config.rb",
    "lib/boss/participant.rb",
    "lib/boss/receiver.rb",
    "lib/boss/registrar.rb",
    "lib/boss/store.rb",
    "lib/boss/viewer.rb",
    "lib/boss/worker.rb",
  ]
  s.executables = s.files.grep(%r{^bin/}) { |f| File.basename(f) }
  s.homepage = "http://wiki.sailfishos.org/"
  s.licenses = ["GPLv2"]
  s.rubygems_version = "2.7.6.2"
  s.summary = "BOSS"

  s.installed_by_version = "2.7.6.2" if s.respond_to? :installed_by_version
end
