# Rakefile
#
# $Revision$ by $Author$
# $Name$
#
# Copyright (c) 2006, 2007 Anupam Sengupta
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
  Hoe.spec PKG_NAME do
    # The GemSpec settings
    self.rubyforge_name = PKG_NAME
    developer "Anupam Sengupta", "anupamsg@gmail.com"
    self.extra_rdoc_files           = ['README', 'COPYING', 'ChangeLog']
    self.url                        =  "http://rubytree.rubyforge.org"
    self.readme_file                = 'README'
    # Set the RDoc Options.
    self.spec_extras[:rdoc_options] = ['--main', 'README', '--line-numbers']
    self.spec_extras[:has_rdoc]     = true

    # Now the publishing settings
    self.remote_rdoc_dir            = 'rdoc'

    # Support additional package formats
    self.need_tar                   = true
    self.need_zip                   = true

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

#Rakefile,v $
# Revision 1.21  2007/07/21 05:14:43  anupamsg
# Added a VERSION constant to the Tree module,
# and using the same in the Rakefile.
#
# Revision 1.20  2007/07/21 03:24:25  anupamsg
# Minor edits to parameter names. User visible functionality does not change.
#
# Revision 1.19  2007/07/19 02:16:01  anupamsg
# Release 0.4.0 (and minor fix in Rakefile).
#
# Revision 1.18  2007/07/18 20:15:06  anupamsg
# Added two predicate methods in BinaryTreeNode to determine whether a node
# is a left or a right node.
#
# Revision 1.17  2007/07/18 07:17:34  anupamsg
# Fixed a  issue where TreeNode.ancestors was shadowing Module.ancestors. This method
# has been renamed to TreeNode.parentage.
#
# Revision 1.16  2007/07/17 05:34:03  anupamsg
# Added an optional tags Rake-task for generating the TAGS file for Emacs.
#
# Revision 1.15  2007/07/17 04:42:45  anupamsg
# Minor fixes to the Rakefile.
#
# Revision 1.14  2007/07/17 03:39:28  anupamsg
# Moved the CVS Log keyword to end of the files.
#
