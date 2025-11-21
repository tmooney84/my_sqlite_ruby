#require "./my_sqlite_request.rb"
require "readline"

class MySqliteRequestCli
  def parse(buf)
    p buf
  end

  def run!
    while buf = Readline.readline("> ", true)
      instance_of_request = parse(buf)
      instance_of_request
    end
  end
end

msqcli = MySqliteRequestCli.new
msqcli.run!
