# TeaBot

TeaBot is a todo-list manager for Telegram.
You can use it directly or add it to a group chat.

![@teatodo_bot in action](https://i.imgur.com/Wd7A8Uv.jpg)

# Using it
Just send a message to [@teatodo_bot](https://t.me/teatodo_bot) on Telegram to use it.
If you're adding it to a supergroup don't forget to make the bot admin, otherwise it will broke (by design, bot's current version deletes command messages, eg. /todo or /complete, and only shows the command output, keeping the chat clean).

# Running up your own bot

```
git clone git@github.com:lenilsonjr/TeaBot.git
cd TeaBot
cp config/secrets-example.yml config/secrets.yml && cp config/database-example.yml config/database.yml
bundle install
```
Don't forget to setup your bot credentials on `secrets.yml`:
```
development:
  secret_key_base: <generate a new one using rake secret>
  telegram:
    bot:
      token: <telegram bot token>
      username: <bot username>
```
You can talk to [@BotFather](https://t.me/BotFather) on Telegram and he'll create bots and access tokens for you.

Set up your mySQL credentials in `config/database.yml` and then use rake to create the database
```
rake db:create
rake db:schema:load
```
You're ready to go! You can use [bot poller](https://github.com/telegram-bot-rb/telegram-bot) while in development to test your bot.
```
rake telegram:bot:poller
```

# Deploying a new bot

This project uses Capistrano for deployment.
```
cp config/deploy-example.rb config/deploy.rb && cp config/deploy/production-example.rb config/deploy/production.rb
```
Edit each of these files to match your deploy info.

You should create a `database.yml`, a `secrets.yml` and a `production.rb` in your server's Capistrano shared folder structure. Don't forget to edit `production.rb:27` to match your API's domain.

Also, don't forget to edit your `Capfile` to match your stack.

After configuring everything, just type `cap production deploy` and the bot will be deployed. This [guide](https://www.phusionpassenger.com/library/deploy/apache/automating_app_updates/ruby/) may help you.

# Future Improvements

- Internationalize bot (currently it only speaks portuguese)
- Create tests

# Contributing

You know the business. Just fork the repo and send a PR with your fix or new feature.
I made this bot in a hurry, so the code certainly can be improved. Feel free to help!
