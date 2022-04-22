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
    @options['l'] ? long_text : short_text
  end

  def property_max_sizes
    max_sizes = {}
    max_sizes['file_nlink'] = files.map(&:file_nlink_count).max
    max_sizes['file_user'] = files.map(&:file_user_count).max
    max_sizes['file_group'] = files.map(&:file_group_count).max
    max_sizes['file_size'] = files.map(&:file_size_count).max

    max_sizes
  end

  private

  def long_text
    [total, *files.map(&:long_text)].join("\n")
  end

  def short_text
    short_text_files = files.map(&:short_text)
    file_count_per_column = file_count_per_column(short_text_files)

    divided_files = short_text_files.each_slice(file_count_per_column).to_a

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

  def total
    "total #{blocks}"
  end

  def blocks
    files.sum(&:blocks)
  end

  def files
    @files ||= file_paths.map { |file_path| LsFile.new(file_path, @options) }
  end

  def file_paths
    target_files = @options['a'] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    @options['r'] ? target_files.reverse : target_files
  end

  def file_count_per_column(files)
    (files.size.to_f / COLUMN_COUNT).ceil
  end
end
