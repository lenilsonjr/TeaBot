class TelegramWebhooksController < Telegram::Bot::UpdatesController

  before_action :check_username

  def start(data = nil, *)
    response = I18n.t('start.response')
    reply_with :message, text: response
  end

  def help(data = nil, *)
    response = I18n.t('help.response')
    reply_with :message, text: response
  end

  def todo(*todo)

    todo = todo.join(" ")
    @task = Todo.new(todo: todo, username: from['username'] )
    
    if @task.save
      delete_message(chat['id'], self.payload['message_id'])
      response = I18n.t('todo.success', username: from['username'], todo: @task.todo)
      respond_with :message, text: response
    else
      response = I18n.t('todo.error', username: from['username'])
      reply_with :message, text: response
    end
    
  end

  def complete(*todo)
    todo = todo.join(" ")

    #Check if user has given an ID
    @task = todo.to_s =~ /\A[-+]?\d*\.?\d+\z/ ? Todo.find(todo.to_i) : Todo.create(todo: todo, username: from['username'])

    if @task.update(completed: true)
      delete_message(chat['id'], self.payload['message_id'])
      response = I18n.t('complete.success', username: from['username'], todo: @task.todo)
      respond_with :message, text: response
    else
      response = I18n.t('complete.error', username: from['username'])
      reply_with :message, text: response
    end

  end

  def remove(*todo)
    todo = todo.join(" ")

    #Check if user has given an ID
    if todo.to_s =~ /\A[-+]?\d*\.?\d+\z/
      @task = Todo.find(todo.to_i)
    else
      @task = Todo.where(todo: todo, username: from['username'], deleted: false, completed: false).first
    end

    if @task.nil?
      response = I18n.t('not_found', username: from['username']) if @task.nil?
      reply_with :message, text: response
    elsif @task.update(deleted: true)
      delete_message(chat['id'], self.payload['message_id'])
      response = I18n.t('remove.success', username: from['username'], todo: @task.todo)
      respond_with :message, text: response
    else
      response = I18n.t('remove.error', username: from['username'])
      reply_with :message, text: response
    end

  end

  def todos(*tag)
    delete_message(chat['id'], self.payload['message_id'])

    if ( tag.empty? )
      @tasks = Todo.where(username: from['username'], completed: false, deleted: false)
    else
      tag = tag.join(" ")
      @tasks = Todo.where(username: from['username'], completed: false, deleted: false).where("todo LIKE '%#{tag}%'")
    end

    if @tasks.empty?

      response = I18n.t('todos.not_found', username: from['username'])

    else

      response = I18n.t('todos.headline', username: from['username'])

      @tasks.each do |todo|        
        response += I18n.t('todos.task', id: todo.id, todo: todo.todo, date: relative_date(todo.created_at.to_date))
      end

      response += I18n.t('todos.end')
    end

    respond_with :message, text: response
  end

  def done(data = nil, *)
    delete_message(chat['id'], self.payload['message_id'])

    @tasks = Todo.where(username: from['username'], completed: true, deleted: false, updated_at: (Time.now - 24.hours)..Time.now)

    if @tasks.empty?

      response = I18n.t('done.not_found', username: from['username'])

    else

      response = I18n.t('done.headline', username: from['username'], count: @tasks.count)

      @tasks.each do |todo|        
        response += I18n.t('done.task', todo: todo.todo, date: relative_date(todo.created_at.to_date))
      end

      response += I18n.t('done.end')
    end

    respond_with :message, text: response
  end

  def leaderboard(data = nil, *)
    @users = Todo.where(completed: true, deleted: false, updated_at: (Time.now - 24.hours)..Time.now).group(:username).limit(10)

    response = I18n.t('leaderboard.headline_one')

    @users.reverse.each do |user|
      count = Todo.where(completed: true, deleted: false, updated_at: (Time.now - 24.hours)..Time.now, username: user.username).count
      response += I18n.t('leaderboard.entry', username: user.username, count: count)
    end

    @users = Todo.where(completed: true, deleted: false).group(:username).limit(10)
    response += I18n.t('leaderboard.headline_two')
    @users.reverse.each do |user|
      count = Todo.where(completed: true, deleted: false, username: user.username).count
      response += I18n.t('leaderboard.entry', username: user.username, count: count)
    end

    response += I18n.t('leaderboard.end')

    reply_with :message, text: response
  end


  def undo(data = nil, *)

    @task = Todo.where(completed: true, deleted: false, updated_at: (Time.now - 24.hours)..Time.now, username: from['username']).order("updated_at DESC").limit(1).first

    if @task.nil?
      response = I18n.t('not_found', username: from['username']) if @task.nil?
      reply_with :message, text: response
    elsif @task.update(completed: false, deleted: false)
      delete_message(chat['id'], self.payload['message_id'])
      response = I18n.t('undo.success', username: from['username'], todo: @task.todo)
      respond_with :message, text: response
    else
      response = I18n.t('undo.error', username: from['username'])
      reply_with :message, text: response
    end

  end

  private

    def relative_date(date)
      if date.nil?
        "fora do contínuo espaço e tempo"
      elsif date == Time.current.to_date
        "hoje"
      elsif date == Date.yesterday
        "ontem"
      elsif date == Date.tomorrow
        "amanhã"
      elsif date && (date > Time.current.to_date - 7.days) && (date < Date.yesterday)
        l(date, format: '%A').downcase
      else
        if date.year == Date.today.year
          l(date, format: 'dia %-d de %B').downcase
        else
          l(date, format: 'dia %-d de %B de %Y').downcase
        end
      end
    end

    def delete_message(chat_id, message_id)
      begin
        bot.delete_message(chat_id: chat_id, message_id: message_id) if chat['type'] == 'supergroup'
      rescue Exception
        puts "Can't delete message"
      end
    end

    def check_username
      if from['username'].empty? || from['username'].nil?
        reply_with :message, text: I18n.t('anonymous')
        throw :halt
      end
    end

end
