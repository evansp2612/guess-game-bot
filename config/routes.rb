# @authors: Iskandar Suhaimi
# @email: hello@iskandarsuhaimi.com 

Rails.application.routes.draw do
  post '/' => 'chat_controller#run', as: "receive_webhooks"
end
