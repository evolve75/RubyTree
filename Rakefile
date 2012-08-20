# -*- mode: ruby; -*-
#
# Rakefile - This file is part of the RubyTree package.
#
# $Revision$ by $Author$ on $Date$
#
# Copyright (c) 2006, 2007, 2009, 2010  Anupam Sengupta
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

PKG_NAME        = "rubytree"

# Default is to create a rubygem.
desc "Default Task (create the gem)"
task :default => :gem

# Use Hoe to define the rake tasks.
begin
  require 'hoe'
  Hoe.plugin :yard

  Hoe.spec PKG_NAME do
    # The GemSpec settings
    self.rubyforge_name = PKG_NAME
    developer "Anupam Sengupta", "anupamsg@gmail.com"

    self.urls                       =  ["http://rubytree.rubyforge.org"]
    self.readme_file                = 'README'

    # Set the Yard Options
    extra_docs                      = ["COPYING", "API-CHANGES"]
    extra_docs.each { |file| self.yard_files << file }
    self.yard_options = ["--files", extra_docs.join(",") ]

    # Now the publishing settings
    self.remote_rdoc_dir            = 'rdoc'

    # Support additional package formats
    self.need_tar                   = true
    self.need_zip                   = true

    # Post installation message
    self.post_install_message       = <<MSGEND
========================================================================

 Thank you for installing #{PKG_NAME}.

 Note that the TreeNode#siblings method has changed in 0.8.3.
 it now returns an empty array for the root node.

              WARNING: SIGNIFICANT API CHANGE in 0.8.0 !
              ------------------------------------------

 Please note that as of 0.8.0 the CamelCase method names are DEPRECATED.

 The new method names follow the ruby_convention (separated by '_').

 The old CamelCase methods still work (a warning will be displayed),
 but may go away in the future.

 Details of the API changes are documented in the API-CHANGES file.

========================================================================
MSGEND

    # Code Metrics ...
    self.flay_threshold             = timebomb 1200, 100 # Default is 1200, 100
    self.flog_threshold             = timebomb 1200, 100 # Default is 1200, 100
  end

rescue LoadError                # If Hoe is not found ...
  $stderr.puts <<-END
  ERROR!!! You do not seem to have Hoe installed!

  The Hoe gem is required for running the rake tasks for building the rubytree gem.

  You can download Hoe as a Rubygem by running as root (or sudo):

    $ gem install hoe

  More details can be found at http://seattlerb.rubyforge.org/hoe/Hoe.html

  END
end


# The following tasks are loaded independently of Hoe
# ===================================================

# Optional TAGS Task.
# Needs http://rubyforge.org/projects/rtagstask/
begin
  require 'rtagstask'
  RTagsTask.new do |rd|
    rd.vi = false
  end
rescue LoadError
  $stderr.puts <<-END
  ERROR!!! You need to have the rtagstask (https://rubyforge.org/projects/rtagstask/) for generating the TAGS file.

  You can install the rtags gem by running the following command as root (or sudo):

    $ gem install rtagstask

  END
end

begin
  require 'reek/rake/task'
  Reek::Rake::Task.new do |t|
    t.verbose = false
    t.source_files = 'lib/**/*.rb'
  end
rescue LoadError
  $stderr.puts <<-END
  ERROR!!! You need to have reek (http://github.com/kevinrutherford/reek) for detecing the code smell.

  You can install the reek gem by running the following command as root (or sudo):

    $ gem install reek

  END

end
