
require 'optparse'
require_relative 'ls_file_list'

class Ls
  # lsコマンドを実行するためのクラス
  def initialize(argv)
    @file_list = LsFileList.new(argv.getopts('alr'))
  end
  
  def execute
    puts @file_list.output
  end
end

# puts ARGV.getopts('alr')
Ls.new(ARGV).execute