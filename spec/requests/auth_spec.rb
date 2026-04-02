require 'swagger_helper'

RSpec.describe 'Auth API', type: :request do
  path '/signup' do
    post('Creates a new user') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email },
          password: { type: :string, format: :password }
        },
        required: ['email', 'password']
      }

      response(201, 'successful') do
        let(:user) { { email: 'test@example.com', password: 'password123' } }
        run_test!
      end

      response(422, 'unprocessable entity') do
        let(:user) { { email: '', password: '' } }
        run_test!
      end
    end
  end

  path '/login' do
    post('Authenticates user') do
      tags 'Authentication'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email },
          password: { type: :string, format: :password }
        },
        required: ['email', 'password']
      }

      response(200, 'successful') do
        let(:credentials) { { email: 'test@example.com', password: 'password123' } }
        
        before do |example|
          User.create!(email: 'test@example.com', password: 'password123', password_confirmation: 'password123')
          submit_request(example.metadata)
        end
        
        run_test!
      end

      response(401, 'unauthorized') do
        let(:credentials) { { email: 'wrong@example.com', password: 'wrong' } }
        run_test!
      end
    end
  end
end
