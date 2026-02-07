# Contributing to RubyTree

This document is only for modifying **RubyTree** itself. It is not required
for using the library.

## Code of Conduct

We follow the [Contributor Covenant][contributor_covenant]. By participating,
you agree to uphold these standards. To report unacceptable behavior, contact
the [maintainer](https://github.com/evolve75).

## Requirements

* [Ruby][] 3.1.x and above. RubyTree 2.2.0 is the last release that supports
  Ruby 2.7 and 3.0.

Development dependencies (not required for installing the gem):

* [Bundler][] for creating the stable build environment
* [Rake][] for building the package
* [Yard][] for the documentation
* [RSpec][] for additional Ruby Spec test files
* [awesome_bot][] for markdown link checking
* [mdl][] for markdown linting
* [RuboCop][] for linting the code

## Getting the Source

You can download the latest released source code as a tar or zip file, as
mentioned in the installation section of the README.

Alternatively, you can checkout the latest commit/revision from the Version
Control System. Note that **RubyTree**'s primary [SCM][] is [git][] and is
hosted on [github.com][rt@github].

### Using the Git Repository

The git repository is available at [github.com/evolve75/RubyTree][rt@github].

For cloning the git repository, use one of the following commands:

```bash
git clone https://github.com/evolve75/RubyTree.git  # using https
```

## Setting Up the Development Environment

**RubyTree** uses [Bundler][] to manage its dependencies. This allows for a
simplified dependency management, for both run-time as well as during build.

After checking out the source, run:

```bash
rvm use
gem install bundler
bundle install
bundle exec rake lint
bundle exec rake test:all
bundle exec rake doc:yard
bundle exec rake gem:package
```

These steps will install any missing dependencies, run the tests/specs,
generate the documentation, and finally generate the gem file.

Note that the documentation uses [Yard][], which will be downloaded and
installed automatically by [Bundler][].

## Development Workflow

* Always load the repo's `.ruby-version` and `.ruby-gemset` via `rvm use`
  before running Ruby commands.
* Run `bundle exec rake lint` and `bundle exec rake test:all` before proposing
  changes. Resolve all RuboCop offenses before committing.
* Run `bundle exec rake doc:check` when modifying markdown documentation.
* Update `CHANGELOG.md` for notable changes and API behavior changes.
* Update `README.md` when introducing new capabilities or new tree types.
* Ensure YARD documentation exists for new or modified modules, classes, and
  methods.

## Issues and Pull Requests

* Use [GitHub issues][github_issues] for bug reports, feature requests, and
  questions.
* Include reproduction steps, Ruby version, and relevant snippets or stack
  traces.
* Keep changes focused. If a change is large, discuss it in an issue first.
* Add or update tests to cover behavior changes.

## Security

If you discover a security issue, do not open a public issue. Contact the
[maintainer](https://github.com/evolve75) with details and steps to reproduce.
We will coordinate a fix and disclosure timeline.

## Running Benchmarks

You can run the bundled benchmarks with:

```bash
bundle exec rake bench
```

[Bundler]: https://bundler.io
[contributor_covenant]: https://www.contributor-covenant.org/version/2/1/
[awesome_bot]: https://github.com/dkhamsing/awesome_bot
[github_issues]: https://github.com/evolve75/RubyTree/issues
[mdl]: https://github.com/markdownlint/markdownlint
[Rake]: https://rubygems.org/gems/rake
[Ruby]: https://www.ruby-lang.org
[RSpec]: https://rspec.info/
[RuboCop]: https://rubocop.org/
[SCM]: https://en.wikipedia.org/wiki/Source_Code_Management
[Yard]: https://yardoc.org
[git]: https://git-scm.com
[rt@github]: https://github.com/evolve75/RubyTree
