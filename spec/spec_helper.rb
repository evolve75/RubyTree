#!/usr/bin/env ruby
#
# spec_helper.rb
#
# Author:  Anupam Sengupta
# Time-stamp: <2022-06-22 13:54:00 anupam>
#
# Copyright (C) 2015, 2022 Anupam Sengupta <anupamsg@gmail.com>
#
# frozen_string_literal: true

require 'tree'

if ENV['COVERAGE']
  begin
    require 'simplecov'
    require 'simplecov-lcov'

    base_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))

    SimpleCov::Formatter::LcovFormatter.config do |cfg|
      cfg.report_with_single_file = true
      cfg.lcov_file_name = 'lcov.info'
      cfg.single_report_path = "#{base_dir}/coverage/lcov.info"
    end

    SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
      [
        SimpleCov::Formatter::HTMLFormatter,
        SimpleCov::Formatter::LcovFormatter
      ]
    )

    SimpleCov.start do
      add_filter '/test'
      add_filter '/spec'
      enable_coverage :branch
    end
  rescue LoadError => e
    puts "Could not load simplecov; continuing without code coverage #{e.cause}"
  end
end
