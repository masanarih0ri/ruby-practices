# frozen_string_literal: true

require 'etc'
require 'date'

class LsFile
  FILE_TYPES = {
    '01' => 'p',
    '02' => 'c',
    '04' => 'd',
    '06' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }.freeze

  FILE_ACCESS_PERMISSIONS = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  YEAR_DISPLAY_MONTH = 6

  def initialize(file_path, options)
    @file = File.new(file_path)
    @stat = @file.stat
    @file_list = LsFileList.new(options)
  end

  def long_text
    max_sizes = @file_list.property_max_sizes
    [
      adjust_text_margin(file_mode, 2),
      adjust_text_margin(nlink, 1).rjust(max_sizes['nlink']),
      adjust_text_margin(user_name, 2).ljust(max_sizes['user']),
      adjust_text_margin(group_name, 2).ljust(max_sizes['group']),
      adjust_text_margin(byte_size, 1).rjust(max_sizes['size'] + 1),
      adjust_text_margin(file_date, 1),
      adjust_text_margin(file_name, 0)
    ].join
  end

  def short_text
    adjust_text_margin(file_name, 2)
  end

  def blocks
    @stat.blocks
  end

  def nlink_count
    nlink.size
  end

  def user_name_count
    user_name.size
  end

  def group_name_count
    group_name.size
  end

  def byte_size_count
    byte_size.size
  end

  private

  def adjust_text_margin(property, right_margin)
    property + (' ' * right_margin)
  end

  def file_mode
    mode = @stat.mode.to_s(8)
    mode = mode[0] == '1' ? mode : format('%06d', mode).to_s
    type = FILE_TYPES[mode.slice(0, 2)]
    access_permission_user = FILE_ACCESS_PERMISSIONS[mode.slice(3)]
    access_permission_group = FILE_ACCESS_PERMISSIONS[mode.slice(4)]
    access_permission_other = FILE_ACCESS_PERMISSIONS[mode.slice(5)]
    "#{type}#{access_permission_user}#{access_permission_group}#{access_permission_other}"
  end

  def nlink
    @stat.nlink.to_s
  end

  def user_name
    Etc.getpwuid(@stat.uid).name
  end

  def group_name
    Etc.getgrgid(@stat.gid).name
  end

  def byte_size
    @stat.size.to_s
  end

  def file_date
    mtime = @stat.mtime
    today = Date.today

    if mtime.to_date <= today.prev_month(YEAR_DISPLAY_MONTH)
      mtime.strftime('%_m %e  %Y')
    else
      mtime.strftime('%_m %e %H:%M')
    end
  end

  def file_name
    @file.path
  end
end
