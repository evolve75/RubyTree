# -*- mode: ruby; -*-
#
# Rakefile - This file is part of the RubyTree package.
#
# Copyright (c) 2006, 2007, 2009, 2010, 2011, 2012  Anupam Sengupta
#
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# - Redistributions of source code must retain the above copyright notice, this
#   list of conditions and the following disclaimer.
#
# - Redistributions in binary form must reproduce the above copyright notice, this
#   list of conditions and the following disclaimer in the documentation and/or
#   other materials provided with the distribution.
#
# - Neither the name of the organization nor the names of its contributors may
#   be used to endorse or promote products derived from this software without
#   specific prior written permission.
#
#   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#

require 'rubygems'
GEM_SPEC = eval(File.read("rubytree.gemspec")) # Load the gemspec.

PKG_NAME = GEM_SPEC.name
PKG_VER  = GEM_SPEC.version
GEM_NAME = "#{PKG_NAME}-#{PKG_VER}.gem"

desc "Default Task (Run the tests)"
task :default => 'test:rcov'

desc "Display the current gem version"
task :version do
  puts "Current Version: #{GEM_NAME}"
end

require 'rake/clean'
task :clean => 'gem:clobber_package'
CLEAN.include('coverage')
task :clobber => [:clean, 'doc:clobber_rdoc', 'doc:clobber_yard', 'tag:clobber_tags']

desc "Open an irb session preloaded with this library"
task :console do
  sh "irb -rubygems -r ./lib/tree.rb"
end

namespace :doc do               # ................................ Documentation

  require 'rdoc/task'
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'rdoc'
    rdoc.title    = "#{PKG_NAME}-#{PKG_VER}"
    rdoc.main     = 'README.rdoc'
    rdoc.rdoc_files.include(GEM_SPEC.extra_rdoc_files)
    rdoc.rdoc_files.include('lib/**/*.rb')
  end

  require 'yard'
  YARD::Rake::YardocTask.new do |t|
    t.files   = ['lib/**/*.rb', '-', GEM_SPEC.extra_rdoc_files]
    t.options = ['--no-private', '--embed-mixins']
  end

  desc "Remove YARD Documentation"
  task :clobber_yard do
    rm_rf 'doc'
  end
end

desc "Run the test cases"
task :test => 'test:unit'

namespace :test do              # ................................ Test related

  require 'rake/testtask'
  Rake::TestTask.new(:unit) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = false
  end

  require 'rcov/rcovtask'
  Rcov::RcovTask.new(:rcov) do |t|
    t.libs << "test"
    t.test_files = FileList['test/**/test_*.rb']
    t.verbose = true
    t.rcov_opts << '--exclude /gems/,/Library/,/usr/,spec,lib/tasks'
  end

end

namespace :tag do               # ................................ Emacs Tags
  require 'rtagstask'
  RTagsTask.new(:tags) do |rd|
    rd.vi = false
  end
end

namespace :gem do               # ................................ Gem related
  require 'rubygems/package_task'
  Gem::PackageTask.new(GEM_SPEC) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end

  desc "Push the gem into the Rubygems repository"
  task :push => :gem do
    sh "gem push pkg/#{GEM_NAME}"
  end
end
