require 'rails_helper'

RSpec.describe 'Auth API', type: :request do
  describe 'POST /signup' do
    it 'creates a new user' do
      post '/signup', params: { email: 'test@example.com', password: 'password123' }
      expect(response).to have_http_status(:created)
    end
  end

  describe 'POST /login' do
    it 'returns a token with valid credentials' do
      # Create user first
      User.create!(email: 'login@example.com', password: 'password123', password_confirmation: 'password123')
      
      post '/login', params: { email: 'login@example.com', password: 'password123' }
      expect(response).to have_http_status(:ok)
      expect(JSON.parse(response.body)).to have_key('token')
    end
  end
end
