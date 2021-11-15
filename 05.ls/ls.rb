# frozen_string_literal: true

COLUMN_COUNT = 3.0
CURRENT_DIRECTORY_FILES = Dir.glob('*')

def calc_file_count_per_column(files, column_count)
  (files.size / column_count).ceil
end

def build_display_column
  column_count = 3.0
  current_directory_files = Dir.glob('*')

  file_count_per_column = calc_file_count_per_column(current_directory_files, column_count)
  devided_file_list = []
  current_directory_files.each_slice(file_count_per_column) { |file| devided_file_list << file }

  adjusted_file_list = []
  devided_file_list.each do |column|
    max_str_count = column.max_by(&:size).size
    adjusted_file_list << column.map { |v| v.ljust(max_str_count + 2) }
  end

  last_column = adjusted_file_list.last
  if last_column.size != file_count_per_column
    empty_column_data_size = file_count_per_column - last_column.size
    count = 0
    while last_column.size < empty_column_data_size
      last_column << ''
      count += 1
    end
  end

  adjusted_file_list.transpose
end

def display_files
  build_display_column.each do |list|
    list.each do |value|
      suffix = "\n"
      if value == list.last
        print "#{value}#{suffix}"
      else
        print value
      end
    end
  end
end

display_files
