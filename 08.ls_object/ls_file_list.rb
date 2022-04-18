require_relative 'ls_file'
require 'optparse'

class LsFileList
  def initialize(options)
    @options = options
  end

  def output
    @options['l'] ? long_text : short_text
  end

  def self.property_max_sizes
    max_sizes = {}
    max_sizes['file_nlink'] = files.map { |file| file.file_nlink_count }.max
    max_sizes['file_user'] = files.map { |file| file.file_user_count }.max
    max_sizes['file_group'] = files.map { |file| file.file_group_count }.max
    max_sizes['file_size'] = files.map { |file| file.file_size_count }.max

    max_sizes
  end

  private

  def long_text
    # LsFile側の処理が未完成(long_textを呼び出したときにrjustとljustが出来てない)
    [total, *files.map(&:long_text)].join("\n")
  end

  def short_text
    # 未完成
    files.map(&:inspect)
  end

  def total
    "total #{blocks}"
  end

  def blocks
    files.sum(&:blocks)
  end

  def files
    @files ||= file_paths.map { |file_path| LsFile.new(file_path) }
  end

  def file_paths
    target_files = @options['a'] ? Dir.glob('*', File::FNM_DOTMATCH) : Dir.glob('*')
    @options['r'] ? target_files.reverse : target_files
  end
end
