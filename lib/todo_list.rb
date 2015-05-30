require_relative "../db/setup"
require_relative "todo"


class TodoList

  def disp_header
    title = [
    "████████╗ ██████╗ ██████╗  ██████╗     ██╗     ██╗███████╗████████╗ ",
    "╚══██╔══╝██╔═══██╗██╔══██╗██╔═══██╗    ██║     ██║██╔════╝╚══██╔══╝ ",
    "   ██║   ██║   ██║██║  ██║██║   ██║    ██║     ██║███████╗   ██║    ",
    "   ██║   ██║   ██║██║  ██║██║   ██║    ██║     ██║╚════██║   ██║    ",
    "   ██║   ╚██████╔╝██████╔╝╚██████╔╝    ███████╗██║███████║   ██║    ",
    "   ╚═╝    ╚═════╝ ╚═════╝  ╚═════╝     ╚══════╝╚═╝╚══════╝   ╚═╝    ",
    "███████████████████████████████████████████████████████████████████╗",
    "╚══════════════════════════════════════════════════════════════════╝"
    ]
    system('clear')
    title.each { |line| puts center_msg(line,' ') }
  end

  def center_msg(string, pad_char)
    width = `tput cols`.chomp.to_i
    padding = width / 2 -  (string.length / 2)
    if string.length.even?
      pad_char * padding + string + pad_char * padding
    else
      pad_char * padding + string + pad_char * (padding - 1)
    end
  end

  def right

end

TodoList.new.disp_header
