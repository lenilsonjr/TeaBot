class TelegramWebhooksController < Telegram::Bot::UpdatesController

  around_action :with_locale

  def start(data = nil, *)
    response = from ? "🚧 Olá, #{from['username']}!\n👉 Use /help para ver o que eu posso fazer!" : "🚧 Olá, pessoas!\n👉 Usem /help para ver o que eu posso fazer!"
    reply_with :message, text: response
  end

  def help(data = nil, *)
    response = "🚧 👉 Use /todo para adicionar um afazer\n✅ 👉 Use /complete <texto do afazer> ou /complete <id do afazer> para completar um afazer\n❌ 👉 Use /remove <texto do afazer> para deletar um afazer\n📑 👉 Use /todos para listar todos seus afazeres\n⏰ 👉 Use /done para ver o que você fez nas últimas 24hrs\n🏎️ 👉 Use /leaderboard para ver os topzeras que mais fazem coisas"
    reply_with :message, text: response
  end

  def todo(*todo)
    reply_with :message, text: "🕵️ Olá, fulano misterioso. Crie um user antes de usar o bot" if from['username'].empty?

    todo = todo.join(" ")
    @task = Todo.new(todo: todo, username: from['username'] )
    
    if @task.save
      bot.delete_message(chat_id: chat['id'], message_id: self.payload['message_id']) if chat['type'] == 'supergroup'
      response = "🚧 '#{todo}' adicionado para @#{from['username']}! Do it! 🚀"
    else
      response  = "😱 Estou com mal funcionamento e não consegui adicionar o afazer, @#{from['username']}! Chame um humano."
      reply_with :message, text: response
    end
      
    respond_with :message, text: response
  end

  def complete(*todo)
    reply_with :message, text: "🕵️ Olá, fulano misterioso. Crie um user antes de usar o bot" if from['username'].empty?

    todo = todo.join(" ")

    #Check if user has given an ID
    if todo.to_s =~ /\A[-+]?\d*\.?\d+\z/
      @task = Todo.where(username: from['username'], completed: false, deleted: false)[todo.to_i - 1]
    else
      @task = Todo.where(todo: todo, username: from['username'], deleted: false, completed: false).first
    end

    if @task.nil?
      response = "👉 Afazer não encontrado, @#{from['username']}! 😱" if @task.nil?
      reply_with :message, text: response
    elsif @task.update(completed: true)
      bot.delete_message(chat_id: chat['id'], message_id: self.payload['message_id']) if chat['type'] == 'supergroup'
      response  = "✅ @#{from['username']} completou #{@task.todo}! Keep Rocking! 🚀\n\n👉 Use /todos para ver os pendentes."    
    else
      response  = "😱 Estou com mal funcionamento e não consegui completar o afazer, @#{from['username']}! Chame um humano."
      reply_with :message, text: response
    end

    respond_with :message, text: response
  end

  def remove(*todo)
    reply_with :message, text: "🕵️ Olá, fulano misterioso. Crie um user antes de usar o bot" if from['username'].empty?

    todo = todo.join(" ")

    #Check if user has given an ID
    if todo.to_s =~ /\A[-+]?\d*\.?\d+\z/
      @task = Todo.where(username: from['username'], completed: false, deleted: false)[todo.to_i - 1]
    else
      @task = Todo.where(todo: todo, username: from['username'], deleted: false, completed: false).first
    end

    if @task.nil?
      response = "👉 Afazer não encontrado, @#{from['username']}! 😱" if @task.nil?
      reply_with :message, text: response
    elsif @task.update(deleted: true)
      bot.delete_message(chat_id: chat['id'], message_id: self.payload['message_id']) if chat['type'] == 'supergroup'
      response  = "✅ @#{from['username']} removeu #{@task.todo}.\n\n👉 Use /todos para ver os pendentes."    
    else
      response  = "😱 Estou com mal funcionamento e não consegui remmover o afazer, @#{from['username']}! Chame um humano."
      reply_with :message, text: response
    end

    respond_with :message, text: response
  end

  def todos(data = nil, *)
    reply_with :message, text: "🕵️ Olá, fulano misterioso. Crie um user antes de usar o bot" if from['username'].empty?
    bot.delete_message(chat_id: chat['id'], message_id: self.payload['message_id']) if chat['type'] == 'supergroup'

    @tasks = Todo.where(username: from['username'], completed: false, deleted: false)

    if @tasks.empty?

      response = "⚠️ Você não tem nenhum afazer, @#{from['username']}!\n\nDeixe de ser vagabundo e adicione um usando /todo <afazer> 🚧"

    else

      response  = "👉 Esses são seus afazeres, @#{from['username']}:\n\n"

      i = 1
      @tasks.each do |todo|        
        response += "🚧 #{i} - #{todo.todo}, adicionado #{relative_date(todo.created_at.to_date)}.\n"
        i = i + 1
      end

      response += "\nGo do it! 🚀"
    end

    respond_with :message, text: response
  end

  def done(data = nil, *)
    reply_with :message, text: "🕵️ Olá, fulano misterioso. Crie um user antes de usar o bot" if from['username'].empty?
    bot.delete_message(chat_id: chat['id'], message_id: self.payload['message_id']) if chat['type'] == 'supergroup'

    @tasks = Todo.where(username: from['username'], completed: true, deleted: false, updated_at: (Time.now - 24.hours)..Time.now)

    if @tasks.empty?

      response = "⚠️ Você não fez nada nas últimas 24hrs, @#{from['username']}!\n\nDeixe de ser vagabundo e use /todos para ver seus afazeres 🚧"

    else

      response  = "👉 Você completou #{@tasks.count} afazeres nas últimas 24hrs, @#{from['username']}:\n\n"

      @tasks.each do |todo|        
        response += "✅ #{todo.todo}, adicionado #{relative_date(todo.created_at.to_date)}.\n"
      end

      response += "\nKeep Rocking! 🚀"
    end

    respond_with :message, text: response
  end

  def leaderboard(data = nil, *)
    bot.delete_message(chat_id: chat['id'], message_id: self.payload['message_id']) if chat['type'] == 'supergroup'
    @users = Todo.where(completed: true, deleted: false, updated_at: (Time.now - 24.hours)..Time.now).group(:username).limit(10)

    response = "🚧 Quem mais fez coisas nas últimas 24 horas:\n"
    @users.reverse.each do |user|
      count = Todo.where(completed: true, deleted: false, updated_at: (Time.now - 24.hours)..Time.now, username: user.username).count
      response += "👷 #{user.username} - #{count} afazeres\n"
    end

    @users = Todo.where(completed: true, deleted: false).group(:username).limit(10)
    response += "\n\n🚧 Quem mais fez coisas desde sempre:\n"
    @users.reverse.each do |user|
      count = Todo.where(completed: true, deleted: false, username: user.username).count
      response += "👷 #{user.username} - #{count} afazeres\n"
    end

    response += "\nKeep Rocking! 🚀"

    respond_with :message, text: response
  end


  def undo(data = nil, *)
    reply_with :message, text: "🕵️ Olá, fulano misterioso. Crie um user antes de usar o bot" if from['username'].empty?

    @task = Todo.where(completed: true, deleted: false, updated_at: (Time.now - 24.hours)..Time.now, username: from['username']).order("updated_at DESC").limit(1).first

    if @task.nil?
      response = "👉 Afazer não encontrado, @#{from['username']}! 😱" if @task.nil?
      reply_with :message, text: response
    elsif @task.update(completed: false, deleted: false)
      bot.delete_message(chat_id: chat['id'], message_id: self.payload['message_id']) if chat['type'] == 'supergroup'
      response  = "✅ @#{from['username']} desfez #{@task.todo}!\n\n👉 Use /todos para ver os pendentes."    
    else
      response  = "😱 Estou com mal funcionamento e não consegui desfazer o afazer, @#{from['username']}! Chame um humano."
      reply_with :message, text: response
    end

    respond_with :message, text: response
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

    def with_locale(&block)
      I18n.with_locale(locale_for_update, &block)
    end
  
    def locale_for_update
      if from
        # locale for user
      elsif chat
        # locale for chat
      end
    end

end
