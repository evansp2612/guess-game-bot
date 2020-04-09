require 'unirest' #panggil depedensi unirest

class ChatControllerController < ApplicationController
    skip_before_action :verify_authenticity_token #skip verify token rails
    attr_accessor :apiResponse, :access_token, :apiurl, :headers, :room_id #set-get atribut controller

    #inisiasi nilai atribut
    def initialize()
        @headers = { 
            'Content-Type' => 'application/json'
        }
    end    

    #ambil dan tampung response data dari webhook
    def getResponse
        if request.headers['Content-Type'] == 'application/json'
            self.apiResponse = JSON.parse(request.body.read)
        else
            #application/x-www-form-urlencoded
            self.apiResponse = params.as_json
        end

        #siapkan log untuk memastikan data terambil
        File.open('log-comment.txt','w') do |f|
            f.write(JSON.pretty_generate(self.apiResponse))
        end    
    end

    #contoh penggunaan api post-comment untuk jenis button
    def replyCommandButton(text, buttons)
        payload = {
            'text' => text,
            'buttons' => []
        }
        buttons.each do |b|
            payload["buttons"].push(
                {
                    'label' => b,
                        'type' => 'postback',
                        'payload' => {
                            'url' => '#',
                            'method' => 'get',
                            'payload' => 'null'
                        }
                }
            )
        end
        replay = { 
            'access_token' => self.access_token,
            'topic_id' => self.room_id,
            'type' => 'buttons',
            'payload' => payload.to_json
        }
        post_comment = Unirest.post(self.apiurl+'post_comment', headers: self.headers, parameters: replay)
    end
    
    #contoh penggunaan api post-comment untuk jenis text
    def replyCommandText(text)
        replay = {
            'access_token' => self.access_token,
            'topic_id' => self.room_id,
            'type' => 'text',
            'comment' => text
        }
        post_comment = Unirest.post(self.apiurl+'post_comment', headers: self.headers, parameters: replay)
    end

    #fungsi untuk jalankan bot
    def run
        self.getResponse 
        chat = Chat.new(
            self.apiResponse['chat_room']['qiscus_room_id'],
            self.apiResponse['message']['text'],
            self.apiResponse['message']['type'],
            self.apiResponse['from']['fullname']
        )
        @room_id = chat.room_id
        @access_token = params['token']
        uri = URI.parse(params['api_base_url'])
        uri.scheme = "https"
        @apiurl = uri.to_s+'/api/v1/chat/conversations/'

        if CurrentRound.where(room: self.room_id).first.nil?
            if chat.message == '/mulai'
                self.replyCommandText("Please wait....")
                q = QuestionList.where(enabled: true).order(Arel.sql('RANDOM()')).first
                q.answer.each do |a|
                    CurrentRound.create(question: q[:question], answer: a, room: self.room_id)
                end
                send_question
            end
        else
            if chat.message == "/leaderboard"
                if Leaderboard.where(room: self.room_id).first.nil?
                    self.replyCommandText("Jawab yang bener dulu")
                else
                    send_leaderboard([])
                end
            elsif chat.message == "/next"
                if CurrentRound.where(name: nil, room: self.room_id).first
                    self.replyCommandText("Jawab semuanya dulu")
                else
                    self.replyCommandText("Please wait....")
                    question = CurrentRound.where(room: self.room_id).first.question
                    CurrentRound.where(room: self.room_id).delete_all
                    q = QuestionList.where(enabled: true).where.not(question: question).order(Arel.sql('RANDOM()')).first
                    q.answer.each do |a|
                        CurrentRound.create(question: q[:question], answer: a, room: self.room_id)
                    end
                    send_question
                end
            elsif chat.message == "/stop"
                send_leaderboard(["/mulai"])
                CurrentRound.where(room: self.room_id).delete_all
                Leaderboard.where(room: self.room_id).delete_all
            else
                answer = CurrentRound.where(name: nil, room: self.room_id).where("lower(answer) = ?", chat.message.downcase).first
                if answer
                    answer.update(name: chat.sender)
                    leaderboard = Leaderboard.where(user_id: self.apiResponse['from']['id'], room: self.room_id).first
                    unless leaderboard
                        leaderboard = Leaderboard.create(user_id: self.apiResponse['from']['id'], name: chat.sender, room: self.room_id)
                    end
                    leaderboard.increment!(:point)
                    send_question
                    unless CurrentRound.where(name: nil, room: self.room_id).first
                        send_leaderboard(["/next", "/stop"])
                    end
                end
            end
        end
        
        # #cek pesan dari chat tidak kosong & cari chat yang mengandung '/' untuk menjalankan command bot
        # find_slash = chat.message.scan('/')
        # if chat.message != nil && find_slash[0] == '/'
        #     #ambil nilai text setelah karakter '/'
        #     command = chat.message.split('/')
        #     if command[1] != nil
        #         case command[1]
        #             when '/mulai'
        #                 self.replyCommandLocation(chat.room_id)
        #             when 'carousel'
        #                 self.replyCommandCarousel(chat.room_id)
        #             when 'button'
        #                 self.replyCommandButton(chat.sender, chat.room_id)
        #             when 'card'
        #                 self.replyCommandCard(chat.room_id)
        #             else
        #                 self.replyCommandText(chat.sender, chat.message_type, chat.room_id)
        #         end
        #     else
        #         self.replyCommandText(chat.sender, chat.message_type, chat.room_id)
        #     end
        # end
    end

    private def send_question
        current_round = CurrentRound.all.order(id: :asc)
        text = current_round[0][:question]
        i = 1
        current_round.each do |c|
            name = ""
            answer = ""
            if c[:name]
                answer = c[:answer]
                name = c[:name]
            end
            text = text+"\n"+i.to_s+". "+answer+" - "+name
            i += 1
        end
        self.replyCommandText(text)
    end

    private def send_leaderboard(buttons)
        leaderboard = Leaderboard.where(room: self.room_id).order(point: :desc)
        text = "Score\n\n"
        i = 1
        leaderboard.each do |l|
            text = text+i.to_s+". "+l[:name]+" - "+l[:point].to_s+"\n"
            i += 1
        end
        if buttons.empty?
            self.replyCommandText(text)
        else
            self.replyCommandButton(text, buttons)
        end
    end
end
