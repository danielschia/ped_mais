require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  describe 'POST /signup' do
    it 'returns created status' do
      post '/signup', params: { email: 'test@example.com', password: 'password123' }
      expect(response.status).to eq(201)
    end
  end
end
