json.extract! question_list, :id, :question, :answer, :enabled, :created_at, :updated_at
json.url question_list_url(question_list, format: :json)
