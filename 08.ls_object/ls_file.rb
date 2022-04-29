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

  def initialize(file_path)
    @file = File.new(file_path)
    @stat = @file.stat
  end

  def blocks
    @stat.blocks
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
    @stat.nlink
  end

  def user_name
    Etc.getpwuid(@stat.uid).name
  end

  def group_name
    Etc.getgrgid(@stat.gid).name
  end

  def byte_size
    @stat.size
  end

  def mtime
    @stat.mtime
  end

  def file_name
    @file.path
  end
end
