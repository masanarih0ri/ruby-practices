# frozen_string_literal: true

require 'io/console'
require_relative 'ls_file'
require 'optparse'

COLUMN_COUNT = 3

class LsFileList
  def initialize(options)
    @options = options
  end

  def output
    display_text = @options['l'] ? display_long_text : display_short_text
    puts display_text
  end

  def property_max_sizes
    max_sizes = {}
    max_sizes['nlink'] = ls_files.map(&:nlink_count).max
    max_sizes['user'] = ls_files.map(&:user_name_count).max
    max_sizes['group'] = ls_files.map(&:group_name_count).max
    max_sizes['size'] = ls_files.map(&:byte_size_count).max

    max_sizes
  end

  private

  def display_long_text
    ["total #{blocks}", *ls_files.map(&:long_text)].join("\n")
  end

  def display_short_text
    short_texts = ls_files.map(&:short_text)
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
    @ls_files ||= file_paths.map { |file_path| LsFile.new(file_path, @options) }
  end

  def file_paths
    target_files = @options['a'] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    @options['r'] ? target_files.reverse : target_files
  end
end
