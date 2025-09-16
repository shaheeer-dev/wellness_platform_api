require 'rails_helper'

RSpec.describe 'API::V1::Appointments', type: :request do
  let(:client) { create(:client) }
  
  describe 'GET /api/v1/appointments' do
    let!(:scheduled_appointment) { create(:appointment, client: client, status: 'scheduled', scheduled_at: 1.day.from_now) }
    let!(:completed_appointment) { create(:appointment, client: client, status: 'completed', scheduled_at: 1.day.ago) }
    let!(:cancelled_appointment) { create(:appointment, client: client, status: 'cancelled', scheduled_at: 2.days.ago) }

    it 'returns all appointments' do
      get '/api/v1/appointments'
      
      expect(response).to have_http_status(:ok)
      expect(json_response['data']).to be_an(Array)
      expect(json_response['data'].length).to eq(3)
      expect(json_response['meta']).to include('current_page', 'per_page', 'total_pages', 'total_count')
    end

    it 'filters appointments by status' do
      get '/api/v1/appointments', params: { status: 'scheduled' }
      
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(1)
      expect(json_response['data'][0]['attributes']['status']).to eq('scheduled')
    end

    it 'returns only upcoming appointments' do
      get '/api/v1/appointments', params: { upcoming: 'true' }
      
      expect(response).to have_http_status(:ok)
      expect(json_response['data'].length).to eq(1)
      expect(json_response['data'][0]['attributes']['is_upcoming']).to be(true)
    end

    it 'supports pagination' do
      create_list(:appointment, 25, client: client)
      
      get '/api/v1/appointments', params: { per_page: 10, page: 2 }
      
      expect(response).to have_http_status(:ok)
      expect(json_response['meta']['current_page']).to eq(2)
      expect(json_response['meta']['per_page']).to eq(10)
    end
  end

  describe 'GET /api/v1/appointments/:id' do
    let(:appointment) { create(:appointment, client: client) }
    
    context 'when appointment exists' do
      it 'returns the appointment' do
        get "/api/v1/appointments/#{appointment.id}"
        
        expect(response).to have_http_status(:ok)
        expect(json_response['data']['id']).to eq(appointment.id.to_s)
        expect(json_response['data']['attributes']['appointment_type']).to eq(appointment.appointment_type)
      end
    end
    
    context 'when appointment does not exist' do
      it 'returns not found' do
        get '/api/v1/appointments/999999'
        
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']['type']).to eq('not_found')
      end
    end
  end

  describe 'POST /api/v1/clients/:client_id/appointments' do
    let(:valid_params) do
      {
        appointment: {
          appointment_type: 'Consultation',
          scheduled_at: 1.week.from_now,
          notes: 'Initial consultation appointment'
        }
      }
    end

    context 'with valid parameters' do
      before do
        stub_request(:post, "#{EXTERNAL_API_BASE_URI}/appointments")
          .to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'creates a new appointment' do
        expect {
          post "/api/v1/clients/#{client.id}/appointments", params: valid_params
        }.to change(Appointment, :count).by(1)
        
        expect(response).to have_http_status(:created)
        expect(json_response['data']['attributes']['appointment_type']).to eq('Consultation')
        expect(json_response['message']).to eq('Appointment created successfully')
      end

      it 'assigns the appointment to the correct client' do
        post "/api/v1/clients/#{client.id}/appointments", params: valid_params
        
        created_appointment = Appointment.last
        expect(created_appointment.client).to eq(client)
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        invalid_params = { appointment: { appointment_type: '', scheduled_at: nil } }
        
        post "/api/v1/clients/#{client.id}/appointments", params: invalid_params
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']['type']).to eq('validation_error')
        expect(json_response['error']['details']).to be_present
      end
    end

    context 'with non-existent client' do
      it 'returns not found' do
        post "/api/v1/clients/999999/appointments", params: valid_params
        
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']['type']).to eq('not_found')
      end
    end
  end

  describe 'PATCH /api/v1/appointments/:id' do
    let(:appointment) { create(:appointment, client: client, status: 'scheduled') }
    
    context 'with valid parameters' do
      before do
        stub_request(:put, /#{EXTERNAL_API_BASE_URI}\/appointments/)
          .to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
      end

      it 'updates the appointment' do
        patch "/api/v1/appointments/#{appointment.id}", params: {
          appointment: { status: 'completed', notes: 'Appointment completed successfully' }
        }
        
        expect(response).to have_http_status(:ok)
        expect(json_response['data']['attributes']['status']).to eq('completed')
        expect(json_response['data']['attributes']['notes']).to eq('Appointment completed successfully')
        expect(json_response['message']).to eq('Appointment updated successfully')
      end
    end

    context 'with invalid parameters' do
      it 'returns validation errors' do
        patch "/api/v1/appointments/#{appointment.id}", params: {
          appointment: { status: 'invalid_status' }
        }
        
        expect(response).to have_http_status(:unprocessable_entity)
        expect(json_response['error']['type']).to eq('validation_error')
      end
    end
  end

  describe 'DELETE /api/v1/appointments/:id' do
    let(:appointment) { create(:appointment, client: client) }
    
    before do
      stub_request(:delete, /#{EXTERNAL_API_BASE_URI}\/appointments/)
        .to_return(status: 200, body: { success: true }.to_json, headers: { 'Content-Type' => 'application/json' })
    end
    
    it 'deletes the appointment' do
      delete "/api/v1/appointments/#{appointment.id}"
      
      expect(response).to have_http_status(:ok)
      expect(json_response['message']).to eq('Appointment cancelled successfully')
      expect(Appointment.find_by(id: appointment.id)).to be_nil
    end

    context 'with non-existent appointment' do
      it 'returns not found' do
        delete '/api/v1/appointments/999999'
        
        expect(response).to have_http_status(:not_found)
        expect(json_response['error']['type']).to eq('not_found')
      end
    end
  end

  private

  def json_response
    JSON.parse(response.body)
  end
end
