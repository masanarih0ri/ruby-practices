# frozen_string_literal: true

require 'optparse'
require_relative 'ls_file_list'

class Ls
  def initialize(argv)
    @file_list = LsFileList.new(argv.getopts('alr'))
  end

  def execute
    print "#{@file_list.output}\n"
  end
end

Ls.new(ARGV).execute
