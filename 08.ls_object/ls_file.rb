require 'etc'
require 'date'

class LsFile
  FILE_TYPE = {
    '01' => 'p',
    '02' => 'c',
    '04' => 'd',
    '06' => 'b',
    '10' => '-',
    '12' => 'l',
    '14' => 's'
  }.freeze

  FILE_ACCESS_RIGHTS = {
    '0' => '---',
    '1' => '--x',
    '2' => '-w-',
    '3' => '-wx',
    '4' => 'r--',
    '5' => 'r-x',
    '6' => 'rw-',
    '7' => 'rwx'
  }.freeze

  PREVIOUS_YEAR_DISPLAY_MONTH = 6

  def initialize(file_path)
    @file = File.open(file_path)
    @stat = @file.stat
  end

  def long_text
    data = LsFileList.property_max_sizes
    # これはmapでFileListから呼び出される想定なので、ここで余白の調整が必要
    # TODO rjustとかljustを使って右詰、左詰をする
    [
      adjust_view(file_mode, 2), 
      adjust_view(file_nlink, 1),
      adjust_view(file_user, 2),
      adjust_view(file_group, 2),
      adjust_view(file_size, 1),
      adjust_view(file_date, 1),
      adjust_view(file_name, 0)
    ].join
  end

  def short_text
    "#{file_name}"
  end

  def blocks
    @stat.blocks
  end

  def file_nlink_count
    file_nlink.size
  end

  def file_user_count
    file_user.size
  end

  def file_group_count
    file_group.size
  end

  def file_size_count
    file_size.size
  end

  private

  def adjust_view(property, right_padding)
    property + (" " * right_padding)
  end

  def file_mode
    mode = @stat.mode.to_s(8)
    mode = mode[0] == '1' ? mode : format('%06d', mode).to_s
    file_type = FILE_TYPE[mode.slice(0, 2)]
    file_access_right_user = FILE_ACCESS_RIGHTS[mode.slice(3)]
    file_access_right_group = FILE_ACCESS_RIGHTS[mode.slice(4)]
    file_access_right_other = FILE_ACCESS_RIGHTS[mode.slice(5)]
    "#{file_type}#{file_access_right_user}#{file_access_right_group}#{file_access_right_other}"
  end

  def file_nlink
    @stat.nlink.to_s
  end

  def file_user
    Etc.getpwuid(@stat.uid).name
  end

  def file_group
    Etc.getgrgid(@stat.gid).name
  end

  def file_size
    @stat.size.to_s
  end

  def file_date
    mtime = @stat.mtime
    today = Date.today

    if mtime.to_date <= today.prev_month(PREVIOUS_YEAR_DISPLAY_MONTH)
      "#{mtime.month} #{mtime.day} #{mtime.year}"
    else
      "#{mtime.month.to_s.rjust(2, ' ')} #{mtime.day.to_s.rjust(2, ' ')} #{mtime.hour.to_s.rjust(2, '0')}:#{mtime.min.to_s.rjust(2, '0')}"
    end
  end

  def file_name
    @file.path
  end
end
