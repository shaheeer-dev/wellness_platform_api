class ExternalApiService
  include HTTParty

  base_uri EXTERNAL_API_BASE_URI
  headers {
    'Authorization' => "Bearer #{Rails.application.credentials.external_api_key}"
  }

  class << self
    def fetch_clients
      response = get('/clients')
      handle_response(response)
    end

    def fetch_appointments
      response = get('/appointments')
      handle_response(response)
    end

    def create_appointment(appointment_data)
      response = post('/appointments', body: appointment_data.to_json)
      handle_response(response)
    end

    def update_appointment(appointment_id, appointment_data)
      response = put("/appointments/#{appointment_id}", body: appointment_data.to_json)
      handle_response(response)
    end

    def delete_appointment(appointment_id)
      response = delete("/appointments/#{appointment_id}")
      handle_response(response)
    end

    private

    def handle_response(response)
      case response.code
      when 200..299
        { success: true, data: response.parsed_response }
      when 400..499
        { success: false, error: "Client error: #{response.message}", data: response.parsed_response }
      when 500..599
        { success: false, error: "Server error: #{response.message}", data: nil }
      else
        { success: false, error: "Unknown error: #{response.code}", data: nil }
      end
    rescue StandardError => e
      { success: false, error: "Network error: #{e.message}", data: nil }
    end
  end
end
