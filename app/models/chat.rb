class Chat 
    include ActiveModel::Model  #set agar model di rails bisa jalan sesuai kebutuhan
    attr_reader :room_id, :message, :message_type, :sender #set atribut model untuk menampung response data chat

    def initialize(room_id, message, message_type, sender)
        @room_id = room_id
        @message = message
        @message_type = message_type
        @sender = sender
    end    
end
