require 'rails_helper'

RSpec.describe 'API::V1::Clients', type: :request do
  describe 'GET /api/v1/clients' do
    let!(:clients) { create_list(:client, 3) }

    it 'returns all clients' do
      get '/api/v1/clients'
      
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).to be_an(Array)
      expect(json_response['data'].length).to eq(3)
      expect(json_response['meta']).to include('current_page', 'per_page', 'total_pages', 'total_count')
    end

    it 'returns clients with search filter' do
      client = create(:client, name: 'John Doe')
      
      get '/api/v1/clients', params: { search: 'John' }
      
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(1)
      expect(json_response['data'][0]['attributes']['name']).to eq('John Doe')
    end

    it 'supports pagination' do
      create_list(:client, 25)
      
      get '/api/v1/clients', params: { per_page: 10, page: 2 }
      
      expect(response).to have_http_status(:ok)
      expect(json_response['meta']['current_page']).to eq(2)
      expect(json_response['meta']['per_page']).to eq(10)
    end
  end

  describe 'GET /api/v1/clients/:id' do
    let(:client) { create(:client) }
    
    context 'when client exists' do
      it 'returns the client' do
        get "/api/v1/clients/#{client.id}"
        
        expect(response).to have_http_status(:ok)
        expect(json_response['data']['id']).to eq(client.id.to_s)
        expect(json_response['data']['attributes']['name']).to eq(client.name)
      end
    end
    
    context 'when client does not exist' do
      it 'returns not found' do
        get '/api/v1/clients/999999'
        
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']['type']).to eq('not_found')
      end
    end
  end

  describe 'POST /api/v1/clients' do
    let(:valid_params) do
      {
        client: {
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '+1-555-123-4567'
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a new client' do
        expect {
          post '/api/v1/clients', params: valid_params
        }.to change(Client, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['name']).to eq('Jane Smith')
        expect(json_response['message']).to eq('Client created successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        invalid_params = { client: { name: '', email: 'invalid' } }
        
        post '/api/v1/clients', params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']['type']).to eq('validation_error')
        expect(json_response['error']['details']).to be_present
      end
    end

    context 'with duplicate email' do
      let!(:existing_client) { create(:client, email: 'jane@example.com') }
      
      it 'returns validation error' do
        post '/api/v1/clients', params: valid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']['message']).to include('Email has already been taken')
      end
    end
  end

  describe 'PATCH /api/v1/clients/:id' do
    let(:client) { create(:client) }
    
    context 'with valid parameters' do
      it 'updates the client' do
        patch "/api/v1/clients/#{client.id}", params: {
          client: { name: 'Updated Name' }
        }
        
        expect(response).to have_http_status(:ok)
        expect(json_response['data']['attributes']['name']).to eq('Updated Name')
        expect(json_response['message']).to eq('Client updated successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        patch "/api/v1/clients/#{client.id}", params: {
          client: { email: 'invalid' }
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']['type']).to eq('validation_error')
      end
    end
  end

  describe 'DELETE /api/v1/clients/:id' do
    let(:client) { create(:client) }
    
    it 'deletes the client' do
      delete "/api/v1/clients/#{client.id}"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['message']).to eq('Client deleted successfully')
      expect(Client.find_by(id: client.id)).to be_nil
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
