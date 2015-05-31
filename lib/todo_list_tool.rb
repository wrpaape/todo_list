require_relative "../db/setup"
require_relative "todo_list"


class TodoListTool
  TERM_WIDTH = `tput cols`.chomp.to_i

  def startup!
    begin
      disp_header
      puts "1) Make a New Todo List"
      puts "2) Load an Existing Todo List"
      puts "3) Delete an Existing Todo List"
      puts "4) Exit"
      print "\n> "
      input = gets.chomp.to_i

      case input
      when 1
        disp_header
        print "Enter New Todo List Title"
        print "\n> "
        new_todo(gets.chomp)
      when 2
        disp_header
        disp_existing_todos
        puts "Which Todo Would you Like to Load?"
        print "\n> "
        load_todo(gets.chomp.to_i)
      when 3
        disp_header
        disp_existing_todos
        puts "Which Todo Would you Like to Delete?"
        print "\n> "
        delete_todo(gets.chomp.to_i)
      when 4
        system('clear')
        exit
      else
        puts "Invalid Selection"
        sleep(0.5)
        startup!
      end
      rescue Interrupt
        system('clear')
        exit
    end
  end

  def new_todo(title)
    current_todo = TodoList.create(title: title)
    todo_id = current_todo.id
    disp_todo(todo_id)
    edit_options(todo_id)
  end

  def load_todo(load_id)
    disp_todo(load_id)
    edit_options(load_id)
  end

  def delete_todo(delete_id)
    disp_header
    current_todo = TodoList.find(delete_id)
    title = current_todo.title
    print "Are you sure you want to delete #{title} (y/n)? > "
    input = gets.chomp.downcase

    case input
    when "y"
      TodoList.destroy(delete_id)
      puts "RIP #{title}"
      sleep(0.5)
      startup!
    when "n"
      startup!
    else
      puts "Invalid Selection"
      sleep(0.5)
      delete_todo(delete_id)
    end
  end


  def edit_options(todo_id)
    current_todo = TodoList.find(todo_id)
    puts "1) Add a Todo"
    puts "2) Mark an Unfinished Todo as Done"
    puts "3) Edit an Existing Todo"
    puts "4) Delete an Existing Todo"
    puts "5) Return to Start Up Options"
    print "\n> "
    input = gets.chomp.to_i

    case input
    when 1
      add_todo(current_todo)
    when 2

    when 3
    when 4
    when 5
      startup!
    else
      puts "Invalid Selection"
      edit_options(todo_id)
    end
  end

  def add_todo(current_todo)
    disp_header
    disp_todo(current_todo.id)
    print "New Entry: "
    new_entry = gets.chomp
    current_todo.joined_entries_w_boolean += new_entry + "||||F+a+L+s+E****"
    current_todo.save
    load_todo(current_todo.id)
  end

  def disp_todo(todo_id)
    disp_header
    current_todo = TodoList.find(todo_id)
    title = current_todo.title
    puts "\n" + center_msg(" #{title} ", "*", TERM_WIDTH)
    puts center_msg(("¯" * title.size), " ", TERM_WIDTH)
    print center_left_msg("Finished", " ")
    puts center_left_msg("Unfinished", " ")
    print center_left_msg("¯¯¯¯¯¯¯¯", " ")
    puts center_left_msg("¯¯¯¯¯¯¯¯¯¯", " ")

    if current_todo.joined_entries_w_boolean.nil?
      puts " "
      puts center_msg("", "*", TERM_WIDTH)
      puts " "
      return
    end

    entries = get_entries_hash(current_todo)
    finished_list = entries[:finished]
    unfinished_list = entries[:unfinished]
    if finished_list.size >= unfinished_list.size
      max_lines = finished_list.size
    else
      max_lines = unfinished_list.size
    end

    entry_disp = Array.new(max_lines)
    entry_disp.map!.with_index do |line, ind|
      pad = ((ind + 1).to_s.size + 2)
      if finished_list[ind].nil? && unfinished_list[ind].nil?
        break
      elsif !(finished_list[ind].nil?) && unfinished_list[ind].nil?
        line = "#{ind + 1}) " + finished_list[ind]
      elsif finished_list[ind].nil? && !(unfinished_list[ind].nil?)
        line =  " " * (TERM_WIDTH / 2) + "#{ind + 1}) " + unfinished_list[ind]
      else
        line = "#{ind + 1}) " + finished_list[ind] + " " * ((TERM_WIDTH / 2) - pad - finished_list[ind].size) + "#{ind + 1}) " + unfinished_list[ind]
      end
    end

    entry_disp.each { |line| puts line }
    puts " "
    puts center_msg("", "*", TERM_WIDTH)
    puts " "
  end

  def disp_existing_todos
    TodoList.all.each do |todolist|
      puts todolist.id.to_s + ") #{todolist.title}"
    end
  end

  def get_entries_hash(current_todo)
    split1 = current_todo.joined_entries_w_boolean.split('****')
    entries = { finished: [], unfinished: [] }
    split1.each do |string|
      split2 = string.split('||||')
      if split2[1] == "T+r+U+e"
        entries[:finished] << split2[0]
      else
        entries[:unfinished] << split2[0]
      end
    end
    entries
  end

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
    title.each { |line| puts center_msg(line, ' ', TERM_WIDTH) }
  end

  def center_msg(string, pad_char, width)
    padding = width / 2 -  (string.length / 2)
    if string.length.even?
      pad_char * padding + string + pad_char * padding
    else
      pad_char * padding + string + pad_char * (padding - 1)
    end
  end

  def center_left_msg(string, pad_char)
    width = TERM_WIDTH / 2
    center_msg(string, pad_char, width)
  end

  def right_msg(string, pad_char)
    width = `tput cols`.chomp.to_i
    padding = width - string.length
    pad_char * padding + string
  end

end

TodoListTool.new.startup!