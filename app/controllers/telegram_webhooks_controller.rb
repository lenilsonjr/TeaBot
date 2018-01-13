class TelegramWebhooksController < Telegram::Bot::UpdatesController

  around_action :with_locale

  def start(data = nil, *)
    response = from ? "🚧 Olá, #{from['username']}!\n👉 Use /help para ver o que eu posso fazer!" : "🚧 Olá, pessoas!\n👉 Usem /help para ver o que eu posso fazer!"
    respond_with :message, text: response
  end

  def help(data = nil, *)
    response = "🚧 👉 Use /todo para adicionar um afazer\n✅ 👉 Use /done <texto do afazer> ou /done <id do afazer> para completar um afazer\n❌ 👉 Use /remove <texto do afazer> para deletar um afazer\n📑 👉 Use /todos para listar todos seus afazeres"
    respond_with :message, text: response
  end

  def todo(*todo)
    respond_with :message, text: "🕵️ Olá, fulano misterioso. Crie um user antes de usar o bot" if from['username'].empty?

    todo = todo.join(" ")
    @task = Todo.new(todo: todo, username: from['username'] )
    
    if @task.save
      response = "🚧 '#{todo}' adicionado para @#{from['username']}! Do it! 🚀"
    else
      response  = "😱 Estou com mal funcionamento e não consegui adicionar o afazer, @#{from['username']}! Chame um humano."
    end
      
    respond_with :message, text: response
  end

  def done(*todo)
    respond_with :message, text: "🕵️ Olá, fulano misterioso. Crie um user antes de usar o bot" if from['username'].empty?

    todo = todo.join(" ")

    if todo.to_s =~ /\A[-+]?\d*\.?\d+\z/
      @task = Todo.where(id: todo, username: from['username'], deleted: false, completed: false)
    else
      @task = Todo.where(todo: todo, username: from['username'], deleted: false, completed: false)
    end

    if @task.empty?
      response  = "👉 Afazer não encontrado, @#{from['username']}! 😱"
    else
      @task = @task.first
      if @task.update(completed: true)
        response  = "✅ @#{from['username']} completou #{@task.todo}! Keep Rocking! 🚀\n\n👉 Use /todos para ver os pendentes."    
      else
        response  = "😱 Estou com mal funcionamento e não consegui completar o afazer, @#{from['username']}! Chame um humano."
      end
    end

    respond_with :message, text: response
  end

  def remove(*todo)
    respond_with :message, text: "🕵️ Olá, fulano misterioso. Crie um user antes de usar o bot" if from['username'].empty?

    todo = todo.join(" ")

    if todo.to_s =~ /\A[-+]?\d*\.?\d+\z/
      @task = Todo.where(id: todo, username: from['username'], deleted: false, completed: false)
    else
      @task = Todo.where(todo: todo, username: from['username'], deleted: false, completed: false)
    end

    if @task.empty?
      response  = "👉 Afazer não encontrado, @#{from['username']}! 😱"
    else
      @task = @task.first
      if @task.update(deleted: true)
        response  = "✅ @#{from['username']} removeu #{@task.todo}.\n\n👉 Use /todos para ver os pendentes."    
      else
        response  = "😱 Estou com mal funcionamento e não consegui remover o afazer, @#{from['username']}! Chame um humano."
      end
    end

    respond_with :message, text: response
  end

  def todos(data = nil, *)
    respond_with :message, text: "🕵️ Olá, fulano misterioso. Crie um user antes de usar o bot" if from['username'].empty?

    @tasks = Todo.where(username: from['username'], completed: false, deleted: false)

    if @tasks.empty?

      response = "⚠️ Você não tem nenhum afazer, @#{from['username']}!\n\nDeixe de ser vagabundo e adicione um usando /todo <afazer> 🚧"

    else

      response  = "👉 Esses são seus afazeres, @#{from['username']}:\n\n"

      @tasks.each do |todo|
        response += "🚧 #{todo.id } - #{todo.todo}, adicionado #{relative_date(todo.created_at.to_date)}\n"
      end

      response += "\nGo do it! 🚀"
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
