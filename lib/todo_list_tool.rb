require 'net/http'
require 'json'
require 'uri'
require_relative "../db/setup"
require_relative "todo_list"


class TodoListTool
  TITLE = "Rails Server Todo List"
  def startup!
    begin
      disp_header
      puts "1) Load Your Rails Server Todo List"
      puts "2) Exit"
      print "\n> "
      input = gets.chomp.to_i
      case input
      when 1
        disp_header
        disp_list_summary
        loop do
          disp_header
          disp_list_summary
          puts "Load This Todo List (y/n)?"
          print "\n> "
          input = gets.chomp.downcase
          startup! if input == "n"
          break if input == "y"
          puts "Invalid Selection"
          sleep(0.5)
        end
        load_todo_list
      when 2
        system('clear')
        disp_pig
        exit
      else
        puts "Invalid Selection"
        sleep(0.5)
        startup!
      end
      rescue Interrupt
        system('clear')
        disp_pig
        exit
    end
  end

  def load_todo_list
    disp_todo_list
    disp_edit_options
  end

  def disp_edit_options
    puts "1) Add a Todo"
    puts "2) Mark an Unfinished Todo as Done"
    puts "3) Edit an Existing Todo"
    puts "4) Delete an Existing Todo"
    puts "5) Return to Start Up Options"
    print "\n> "
    input = gets.chomp.to_i

    case input
    when 1
      add_todo
    when 2
      mark_todo
    when 3
      edit_todo
    when 4
      delete_todo
    when 5
      startup!
    else
      puts "Invalid Selection"
      sleep(0.5)
      load_todo_list
    end
  end

  def add_todo
    disp_todo_list
    uri = URI('http://localhost:3000/todos')
    todos_json = Net::HTTP.get(uri)
    todo_list = JSON.parse(todos_json)
    print "New Entry: "
    new_entry = gets.chomp

    Net::HTTP.post_form(uri, 'q' => 'ruby', 'body' => new_entry)

    load_todo_list
  end

  def mark_todo
    uri = URI('http://localhost:3000/todos')
    todos_json = Net::HTTP.get(uri)
    todo_list = JSON.parse(todos_json)
    if todo_list.size == 0
      puts "No Todos to Mark"
      sleep (0.5)
      load_todo_list
    end

    disp_todo_list
    puts "Which Unfinished Todo Would you Like to Mark?"
    print "\n> "
    input = gets.chomp.to_i
    marked_body = @incompleted_bodies[input - 1]
    marked_todo_id = ""
    if marked_body == ""
      @null_body_todos.each do |null_body_todo|
        marked_todo_id = null_body_todo["id"].to_s if null_body_todo["completed"] == false
      end
    else
      uri = URI("http://localhost:3000/todos?completed=false&body=#{marked_body}")
      todo_json = Net::HTTP.get(uri)
      marked_todo = JSON.parse(todo_json)
      marked_todo_id = marked_todo["id"].to_s
   end

    puts "/todos/#{marked_todo_id}"

    url = "http://localhost:3000/"
    uri = URI.parse(url)
    params = {completed: "true"}

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new("/todos/#{marked_todo_id}")
    request.set_form_data(params)
    http.request(request)

    load_todo_list
  end

  def edit_todo
    uri = URI('http://localhost:3000/todos')
    todos_json = Net::HTTP.get(uri)
    todo_list = JSON.parse(todos_json)
    if todo_list.size == 0
      puts "No Todos to Edit"
      sleep (0.5)
      load_todo_list
    end

    disp_todo_list
    puts "Is the Todo you Want to Edit Finished (f) or Unfinished (u) ?"
    print "\n> "
    input = gets.chomp.downcase

    case input
    when "f"
      puts "Which Finished Todo Would you Like to Edit?"
      print "\n> "
      input = gets.chomp.to_i

      edited_body = @completed_bodies[input - 1]
      edited_todo_id = ""
      if edited_body == ""
        @null_body_todos.each do |null_body_todo|
          edited_todo_id = null_body_todo["id"].to_s if null_body_todo["completed"] == true
        end
      else
        uri = URI("http://localhost:3000/todos?completed=true&body=#{edited_body}")
        todo_json = Net::HTTP.get(uri)
        edited_todo = JSON.parse(todo_json)
        edited_todo_id = edited_todo["id"].to_s
      end
    when "u"
      puts "Which Unfinished Todo Would you Like to Edit?"
      print "\n> "
      input = gets.chomp.to_i

      edited_body = @incompleted_bodies[input - 1]
      edited_todo_id = ""
      if edited_body == ""
        @null_body_todos.each do |null_body_todo|
          edited_todo_id = null_body_todo["id"].to_s if null_body_todo["completed"] == false
        end
      else
        uri = URI("http://localhost:3000/todos?completed=false&body=#{edited_body}")
        todo_json = Net::HTTP.get(uri)
        edited_todo = JSON.parse(todo_json)
        edited_todo_id = edited_todo["id"].to_s
      end
    else
      puts "Invalid Selection"
      sleep(0.5)
      load_todo_list
    end

    print "New Entry: "
    new_entry = gets.chomp

    url = "http://localhost:3000/"
    uri = URI.parse(url)
    params = {body: new_entry}

    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Put.new("/todos/#{edited_todo_id}")
    request.set_form_data(params)
    http.request(request)

    load_todo_list
  end

  def delete_todo
    uri = URI('http://localhost:3000/todos')
    todos_json = Net::HTTP.get(uri)
    todo_list = JSON.parse(todos_json)
    if todo_list.size == 0
      puts "No Todos to Delete"
      sleep (0.5)
      load_todo_list
    end

    disp_todo_list
    puts "Is the Todo you Want to Delete Finished (f) or Unfinished (u) ?"
    print "\n> "
    input = gets.chomp.downcase

    case input
    when "f"
      puts "Which Finished Todo Would you Like to Delete?"
      print "\n> "
      input = gets.chomp.to_i

      deleted_body = @completed_bodies[input - 1]
      deleted_todo_id = ""
      if deleted_body == ""
        @null_body_todos.each do |null_body_todo|
          deleted_todo_id = null_body_todo["id"].to_s if null_body_todo["completed"] == true
        end
      else
        uri = URI("http://localhost:3000/todos?completed=true&body=#{deleted_body}")
        todo_json = Net::HTTP.get(uri)
        deleted_todo = JSON.parse(todo_json)
        deleted_todo_id = deleted_todo["id"].to_s
      end
    when "u"
      puts "Which Unfinished Todo Would you Like to Delete?"
      print "\n> "
      input = gets.chomp.to_i

      deleted_body = @incompleted_bodies[input - 1]
      deleted_todo_id = ""
      if deleted_body == ""
        @null_body_todos.each do |null_body_todo|
          deleted_todo_id = null_body_todo["id"].to_s if null_body_todo["completed"] == false
        end
      else
        uri = URI("http://localhost:3000/todos?completed=false&body=#{deleted_body}")
        todo_json = Net::HTTP.get(uri)
        deleted_todo = JSON.parse(todo_json)
        deleted_todo_id = deleted_todo["id"].to_s
      end
    else
      puts "Invalid Selection"
      sleep(0.5)
      load_todo_list
    end

    uri = URI("http://localhost:3000/todos/#{deleted_todo_id}")
    http = Net::HTTP.new(uri.host, uri.port)
    req = Net::HTTP::Delete.new(uri.path)
    res = http.request(req)

    load_todo_list
  end

  def disp_todo_list
    disp_header
    uri = URI('http://localhost:3000/todos')
    todos_json = Net::HTTP.get(uri)
    todo_list = JSON.parse(todos_json)
    @completed_bodies = []
    @incompleted_bodies = []
    @null_body_todos = []
    todo_list.each do |todo|
      @null_body_todos << todo if todo["body"].nil? || todo["body"] == ""
      todo["completed"] ? @completed_bodies << todo["body"].to_s : @incompleted_bodies << todo["body"].to_s
    end

    if @completed_bodies.size >= @incompleted_bodies.size
      max_lines = @completed_bodies.size
    else
      max_lines = @incompleted_bodies.size
    end

    entry_disp = Array.new(max_lines)
    entry_disp.map!.with_index do |line, ind|
      pad = ((ind + 1).to_s.size + 2)
      if (ind + 1) > @incompleted_bodies.size
        line = "#{ind + 1}) " + @completed_bodies[ind]
      elsif (ind + 1) > @completed_bodies.size
        line = " " * (`tput cols`.chomp.to_i / 2) + "#{ind + 1}) " + @incompleted_bodies[ind]
      else
        line = "#{ind + 1}) " + @completed_bodies[ind] + " " * ((`tput cols`.chomp.to_i / 2) - pad - @completed_bodies[ind].size) + "#{ind + 1}) " + @incompleted_bodies[ind]
      end
    end

    puts "\n"
    puts center_msg("", "*", `tput cols`.chomp.to_i)
    puts center_msg(TITLE, " ", `tput cols`.chomp.to_i)
    puts center_msg(("¯" * TITLE.size), " ", `tput cols`.chomp.to_i)
    print center_left_msg("Finished", " ")
    puts center_left_msg("Unfinished", " ")
    print center_left_msg("¯¯¯¯¯¯¯¯", " ")
    puts center_left_msg("¯¯¯¯¯¯¯¯¯¯", " ")
    entry_disp.each { |line| puts line }
    puts " "
    puts center_msg("", "*", `tput cols`.chomp.to_i)
    puts " "
  end

  def disp_list_summary
    uri = URI('http://localhost:3000/todos')
    todos_json = Net::HTTP.get(uri)
    todos_ruby = JSON.parse(todos_json)
    create_array = []
    update_array = []
    todos_ruby.each do |todo|
      create_array << DateTime.iso8601(todo["created_at"])
      update_array << DateTime.iso8601(todo["updated_at"])
    end
    first_created = create_array.min.strftime("%m/%d/%Y at %I:%M%p")
    last_updated = update_array.max.strftime("%m/%d/%Y at %I:%M%p")

    line_size = ("  · last updated on: " + last_updated).size + 1
    puts center_msg("", "¯", line_size)
    puts TITLE
    puts "  · created on:      " + first_created
    puts "  · last updated on: " + last_updated
    puts " "
    puts center_msg("", "¯", line_size)
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
    title.each { |line| puts center_msg(line, ' ', `tput cols`.chomp.to_i) }
    puts " "
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
    width = `tput cols`.chomp.to_i / 2
    center_msg(string, pad_char, width)
  end

  def disp_pig
    pad_front = "M" * (`tput cols`.chomp.to_i - "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMmdhhhmMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM".size)
    pad_back = "M" * 0
    while pad_front.size > 0
      pig =
"""
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMmdhhhmMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMmhyo/:---/yMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMMMMMMMMNhs/:--------/osMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMMMMMMdo:------------:yNMMMMMMNmdhyysyhNMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMMMMd+:------------:/ohNNdhso/:::-:+oymMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMMh/:----------:oyhhys+:::--:+syhhhyyyhMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMy:---------/sdhs+::----:+yddys/::/oydNMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMM/--------+hds/:----:+shhy+::--oyhhhmMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMs------/dd+:-----/sdyo/:------:/+shNMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMNo:---+Ny:-----:ydo:--------ohdmNMMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMMMmhyyNh:------ys:----------//+sNMMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMMMNmhsMs-------:---------osyyyhddmMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMhdNMmdhys+/:--dy-----------------+yNh::-::+ymMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMhNMMm//dm/--------:/-------------+ossyhh+-------:smMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMmdy+mh-:hs--------------------::/ohMy/:-----------/hMMMMMNNMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMm:--/+--::--------------------/oosss+--------------:hMMMMNMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMm+---------------------------------------------------:NMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMNy/:h+--------------------------------------------------dMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMNds/--:+:-----------------------------------------------:y+mMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}Mdymh:-------o+:---------------------------------------------/ymNMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}Mmh/h:---::/+dNh:----------------------------------------------:+shmNNMMMMMMMMMM#{pad_back}
#{pad_front}MMNhhhyhhhhys+/+:::::::--------------------------:o::--------------://smMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMdhhyyyhhhdhhhhhys/:/s+-------:+----------:oddhysoo+++///::::::-:yNMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMNNho/:::/sddo:----::sms------::/+shmMMMMMMMMMMMMMNNmddhyoomMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMmyo+/sdmdhyo:----:/ohNh+:::/+sydmMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMh+--::ohds/-::::+shmMMMMNNNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMM++shmMh/-:oydmNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMhohNMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
#{pad_front}MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM#{pad_back}
"""
      puts pig
      pad_front.chop!
      pad_back += "M"
      sleep(0.005)
      system('clear')
    end
  end
end

TodoListTool.new.startup!
