require_relative "../db/setup"
require_relative "todo"


class TodoList

  def initialize

  end

  def start
    loop do
      @todos = Todo.all
      view_todos

      puts
      puts "What would you like to do?"
      puts "(1) Exit \n(2) Add Todo \n(3) Mark Todo As Complete \n(4) Delete Existing Todo"
      print " > "
      action = gets.chomp.to_i
      case action
      when 1 then exit
      when 2 then add_todo
      when 3 then mark_todo
      when 4 then delete_todo
      else
        puts "\a"
        puts "Not a valid choice"
      end
    end
  end

  def add_todo
    puts "What is the todo you need to do? > "
    Todo.create(entry: get_input)
  end

  def view_todos
    system('clear')
    puts "---- TODO::COMPLETED? ----"
    @todos.each do |item|
      puts "#{item.id}) #{item.entry} : #{status_display(item.completed)}"
    end

  end

  def mark_todo
    puts "which todo would you like to mark todone? > "
    Todo.where(id: get_input).update_all(completed: true)
  end

  def delete_todo
    puts "Which todo would you like to delete? > (#) "
    Todo.find(get_input).destroy
  end

  def status_display(check_status)

    if check_status == false
       "Incomplete"
    else
       "Completed"
    end

  end

  private
  def get_input
    gets.chomp
  end

  # def save!

  # end

end
