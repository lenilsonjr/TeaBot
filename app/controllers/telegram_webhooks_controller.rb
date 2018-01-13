class TelegramWebhooksController < Telegram::Bot::UpdatesController

  around_action :with_locale

  # Every update can have one of: message, inline_query, chosen_inline_result,
  # callback_query, etc.
  # Define method with same name to respond to this updates.
  def message(message)
    message == self.payload
  end

  def start(data = nil, *)
    response = from ? "🚧 Olá, #{from['username']}!\n👉 Use /help para ver o que eu posso fazer!" : "🚧 Olá, pessoas!\n👉 Usem /help para ver o que eu posso fazer!"
    respond_with :message, text: response
  end

  def help(data = nil, *)
    response = "🚧 👉 Use /todo para adicionar um afazer\n✅ 👉 Use /done <texto do afazer> para completar um afazer\n❌ 👉 Use /remove <texto do afazer> para deletar um afazer\n📑 👉 Use /todos para listar todos seus afazeres"
    respond_with :message, text: response
  end

  private
  
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
