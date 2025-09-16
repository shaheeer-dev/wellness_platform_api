class Api::V1::AppointmentsController < ApplicationController
  before_action :set_appointment, only: [:show, :update, :destroy]
  before_action :set_client, only: [:create]

  def index
    appointments_query = Appointment.includes(:client)

    if params[:status].present?
      appointments_query = appointments_query.where(status: params[:status])
    end

    if params[:upcoming] == 'true'
      appointments_query = appointments_query.where('scheduled_at > ?', Time.current)
                                           .where(status: 'scheduled')
    end

    appointments_query = appointments_query.order(:scheduled_at)

    pagy, appointments = pagy(appointments_query, items: params[:per_page] || 20)

    render json: {
      data: AppointmentSerializer.new(appointments, { include: [:client] }).serializable_hash[:data],
      meta: {
        current_page: pagy.page,
        per_page: pagy.items,
        total_pages: pagy.pages,
        total_count: pagy.count
      }
    }
  end

  def show
    render json: {
      data: AppointmentSerializer.new(@appointment, { include: [:client] }).serializable_hash[:data]
    }
  end

  def create
    external_id = SecureRandom.uuid

    @appointment = @client.appointments.build(appointment_params.merge(external_id: external_id))

    if @appointment.save
      sync_with_external_api

      render json: {
        data: AppointmentSerializer.new(@appointment, { include: [:client] }).serializable_hash[:data],
        message: 'Appointment created successfully'
      }, status: :created
    else
      render json: {
        error: {
          type: 'validation_error',
          message: @appointment.errors.full_messages.to_sentence,
          details: @appointment.errors.as_json
        }
      }, status: :unprocessable_entity
    end
  end

  def update
    if @appointment.update(appointment_params)
      sync_with_external_api('update')

      render json: {
        data: AppointmentSerializer.new(@appointment, { include: [:client] }).serializable_hash[:data],
        message: 'Appointment updated successfully'
      }
    else
      render json: {
        error: {
          type: 'validation_error',
          message: @appointment.errors.full_messages.to_sentence,
          details: @appointment.errors.as_json
        }
      }, status: :unprocessable_entity
    end
  end

  def destroy
    begin
      @appointment.cancel!(params[:cancellation_reason])

      external_sync_result = sync_with_external_api('cancel')

      message = if external_sync_result && external_sync_result[:success]
                  'Appointment cancelled successfully'
                else
                  'Appointment cancelled locally, but external API sync failed'
                end

      render json: {
        data: AppointmentSerializer.new(@appointment, { include: [:client] }).serializable_hash[:data],
        message: message
      }
    rescue StandardError => e
      render json: {
        error: {
          type: 'cancellation_error',
          message: "Failed to cancel appointment: #{e.message}"
        }
      }, status: :unprocessable_entity
    end
  end

  private

  def set_appointment
    @appointment = Appointment.find(params[:id])
  end

  def set_client
    if params[:client_id]
      @client = Client.find(params[:client_id])
    else
      render_error('Client ID is required', :bad_request)
    end
  end

  def appointment_params
    params.require(:appointment).permit(:appointment_type, :scheduled_at, :status, :notes, :cancellation_reason)
  end

  def sync_with_external_api(action = 'create')
    appointment_data = {
      id: @appointment.external_id,
      client_id: @appointment.client.external_id,
      appointment_type: @appointment.appointment_type,
      scheduled_at: @appointment.scheduled_at.iso8601,
      status: @appointment.status,
      notes: @appointment.notes
    }

    external_response = case action
                       when 'create'
                         ExternalApiService.create_appointment(appointment_data)
                       when 'update'
                         ExternalApiService.update_appointment(@appointment.external_id, appointment_data)
                       when 'cancel'
                         ExternalApiService.delete_appointment(@appointment.external_id)
                       end

    unless external_response[:success]
      Rails.logger.warn "Failed to sync appointment with external API: #{external_response[:error]}"
    end

    external_response
  rescue StandardError => e
    Rails.logger.error "Error syncing with external API: #{e.message}"
    { success: false, error: e.message }
  end
end
