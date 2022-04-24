# frozen_string_literal: true

require 'optparse'
require_relative 'ls_file_list'

file_list = LsFileList.new(ARGV.getopts('alr'))
file_list.output
