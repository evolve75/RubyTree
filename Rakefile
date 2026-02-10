# -*- mode: ruby; -*-
#
# Rakefile - This file is part of the RubyTree package.
#
# Copyright (c) 2006-2026  Anupam Sengupta
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright notice,
#   this list of conditions and the following disclaimer in the documentation
#   and/or other materials provided with the distribution.
#
# - Neither the name of the organization nor the names of its contributors may
#   be used to endorse or promote products derived from this software without
#   specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
#
# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'rubygems/package_task'

GEM_SPEC = Bundler.load_gemspec(File.join(__dir__, 'rubytree.gemspec'))

PKG_NAME = GEM_SPEC.name
PKG_VER  = GEM_SPEC.version
GEM_NAME = "#{PKG_NAME}-#{PKG_VER}.gem".freeze
MARKDOWN_FILES = Dir['**/*.md'].reject do |path|
  path.start_with?('vendor/', 'pkg/')
end.sort

desc 'Default Task (Run the tests)'
task default: 'test:all'

desc 'Display the current gem version'
task :version do
  puts "Current Version: #{GEM_NAME}"
end

# ................................ Gem metadata
desc 'Validate gemspec metadata and required fields'
task :gemspec do
  GEM_SPEC.validate
  puts 'Gemspec is valid.'
end

# ................................ Linting
desc 'Run lint checks'
task lint: %i[gemspec rubocop]

# ................................ Security checks
desc 'Run security checks (bundler-audit, semgrep)'
task :security do
  sh('bundle', 'exec', 'bundler-audit', 'check', '--update')

  semgrep_available = system('command -v semgrep >/dev/null 2>&1')
  unless semgrep_available
    warn 'WARN: semgrep not found; skipping semgrep security scan.'
    return
  end

  env = {}
  default_cert = '/etc/ssl/cert.pem'
  env['SSL_CERT_FILE'] = default_cert if ENV['SSL_CERT_FILE'].nil? && File.exist?(default_cert)

  sh(env, 'semgrep', '--config', 'p/r2c-security-audit', '--config', 'p/ruby', 'lib')
end

# ................................ Release checks
desc 'Run release checks (lint, tests, docs, package)'
task 'release:check' => %i[lint test:all doc:yard gem:package]

require 'rake/clean'
desc 'Remove all generated files.'
task clean: 'gem:clobber_package'
CLEAN.include('coverage')
task clobber: [:clean, 'doc:clobber_rdoc', 'doc:clobber_yard']

desc 'Open an irb session preloaded with this library'
task :console do
  sh 'irb -rubygems -r ./lib/tree.rb'
end

namespace :doc do # ................................ Documentation
  begin
    require 'rdoc/task'
    Rake::RDocTask.new do |rdoc|
      rdoc.rdoc_dir = 'rdoc'
      rdoc.title    = "RubyTree Documentation: #{PKG_NAME}-#{PKG_VER}"
      rdoc.main     = 'README.md'
      rdoc.rdoc_files.include(GEM_SPEC.extra_rdoc_files)
      rdoc.rdoc_files.include('./lib/**/*.rb')
    end
  rescue LoadError
    # Oh well.
  end

  begin
    require 'yard'
    YARD::Rake::YardocTask.new do |t|
      t.files   = ['lib/**/*.rb', '-', GEM_SPEC.extra_rdoc_files]
      t.options = %w[--no-private --embed-mixins]
    end
  rescue LoadError
    # Oh well.
  end

  desc 'Remove YARD Documentation'
  task :clobber_yard do
    rm_rf 'doc'
  end

  desc 'Run markdown lint checks'
  task :lint do
    sh('mdl', '--config', '.mdlrc', *MARKDOWN_FILES)
  end

  desc 'Validate http(s) links in markdown files'
  task :links do
    sh('awesome_bot', *MARKDOWN_FILES, '--allow-redirect', '--allow-dupe')
  end

  desc 'Run markdown lint and link checks'
  task check: %i[lint links]
end

desc 'Run the unit tests'
task test: %w[test:unit]

# ................................ Test related
namespace :test do
  desc 'Run all the tests'
  task all: %w[test:unit test:spec test:examples]

  require 'rake/testtask'
  Rake::TestTask.new(:unit) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = false
  end

  # ................................ rspec tests
  begin
    require 'rspec/core/rake_task'

    RSpec::Core::RakeTask.new(:spec) do |t|
      t.fail_on_error = false
      t.rspec_opts = ['--color', '--format doc']
    end
  rescue LoadError
    # Cannot load rspec.
  end

  desc 'Run the examples'
  Rake::TestTask.new(:examples) do |example|
    example.libs << 'lib' << 'examples'
    example.pattern = 'examples/**/example_*.rb'
    example.verbose = true
    example.warning = false
  end

  desc 'Run the code coverage'
  task :coverage do
    ruby 'test/run_test.rb'
  end
end

# ................................ Benchmarks
desc 'Run benchmarks'
task :bench do
  ruby 'test/benchmark_tree.rb'
end

# ................................ Emacs Tags
namespace :tag do
  require 'rtagstask'
  RTagsTask.new(:tags) do |rd|
    rd.vi = false
    CLEAN.include('TAGS')
  end
rescue LoadError
  # Oh well. Can't have everything.
end

# ................................ Gem related
require 'bundler/gem_helper'
Bundler::GemHelper.install_tasks

Gem::PackageTask.new(GEM_SPEC) do |pkg|
  pkg.package_dir = 'pkg'
  pkg.need_tar = true
  pkg.need_zip = true
end

namespace :gem do
  desc 'Build the gem package (alias of package)'
  task package: :package
  desc 'Remove built gem package artifacts (alias of clobber_package)'
  task clobber_package: :clobber_package
end

# ................................ Ruby linting
begin
  require 'rubocop/rake_task'

  RuboCop::RakeTask.new(:rubocop) do |t|
    t.options = ['--display-cop-names']
  end
rescue LoadError
  # RuboCop not available.
end
