# frozen_string_literal: true

require 'optparse'
require_relative 'ls_file'

COLUMN_COUNT = 3

class Ls
  def initialize(options)
    @options = options
  end

  def output
    text = @options['l'] ? display_long_text : display_short_text
    puts text
  end

  private

  def long_text(ls_file, max_sizes)
    [
      adjust_text_margin(ls_file.file_mode, 2),
      adjust_text_margin(ls_file.nlink, 1).rjust(max_sizes['nlink']),
      adjust_text_margin(ls_file.user_name, 2).ljust(max_sizes['user']),
      adjust_text_margin(ls_file.group_name, 2).ljust(max_sizes['group']),
      adjust_text_margin(ls_file.byte_size, 1).rjust(max_sizes['size'] + 1),
      adjust_text_margin(ls_file.file_date, 1),
      adjust_text_margin(ls_file.file_name, 0)
    ].join
  end

  def short_text(ls_file)
    adjust_text_margin(ls_file.file_name, 2)
  end

  def adjust_text_margin(property, right_margin)
    property.to_s + (' ' * right_margin)
  end

  def property_max_sizes
    max_sizes = {}
    max_sizes['nlink'] = ls_files.map { |lf| lf.nlink.to_s.size }.max
    max_sizes['user'] = ls_files.map { |lf| lf.user_name.size }.max
    max_sizes['group'] = ls_files.map { |lf| lf.group_name.size }.max
    max_sizes['size'] = ls_files.map { |lf| lf.byte_size.to_s.size }.max

    max_sizes
  end

  def display_long_text
    max_sizes = property_max_sizes
    ["total #{blocks}", *ls_files.map { |ls_file| long_text(ls_file, max_sizes)}].join("\n")
  end

  def display_short_text
    short_texts = ls_files.map { |ls_file| short_text(ls_file) }
    file_count_per_column = (ls_files.size.to_f / COLUMN_COUNT).ceil

    divided_files = short_texts.each_slice(file_count_per_column).to_a

    last_column = divided_files[-1]
    (file_count_per_column - last_column.size).times do
      last_column.push('')
    end

    formatted_files = []
    divided_files.each do |column|
      max_str_count = column.max_by(&:size).size
      formatted_files << column.map { |v| v.ljust(max_str_count) }
    end
    transposed_files = formatted_files.transpose
    transposed_files.map(&:join).join("\n")
  end

  def blocks
    ls_files.sum(&:blocks)
  end

  def ls_files
    @ls_files ||= file_paths.map { |file_path| LsFile.new(file_path) }
  end

  def file_paths
    target_files = @options['a'] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    @options['r'] ? target_files.reverse : target_files
  end
end

ls = Ls.new(ARGV.getopts('alr'))
ls.output
