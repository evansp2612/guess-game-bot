# Guess Game bot in ChatAja

## Requirements

* [Ruby](https://www.ruby-lang.org/en/)
* [Ruby on Rails](https://rubyonrails.org/)
* [Bundler](https://bundler.io/bundle_install.html)
* [ngrok](https://ngrok.com/)
* [ChatAja!](https://download.chataja.co.id/)
* ChatAja bot (you can create it with Chatbot Builder in `Jelajah` menu)

## How to run

* Clone this repository and install dependencies `Gemfile`

```bash
$ git clone https://github.com/evansp2612/guess-game-bot.git
$ cd guess-game-bot
$ bundle install
```

* Go to `Jelajah` menu in ChatAja
* Start chat with `Chatbot Builder`
* Create bot

* Run webhook server

```bash
$ rake db:create db:migrate
$ rails server
```

* Tunneling your webhook server

```bash
$ ngrok http 3000
```

* Register your webhook url with ngrok https url from CLI, then input it to `Chatbot Builder`
* Enjoy!