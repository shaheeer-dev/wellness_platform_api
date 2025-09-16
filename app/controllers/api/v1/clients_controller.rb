class Api::V1::ClientsController < ApplicationController
  before_action :set_client, only: [:show, :update, :destroy]

  def index
    clients_query = Client.includes(:appointments).order(:name)

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      clients_query = clients_query.where(
        'name ILIKE ? OR email ILIKE ? OR phone ILIKE ?',
        search_term, search_term, search_term
      )
    end

    pagy, clients = pagy(clients_query, items: params[:per_page] || 20)

    render json: {
      data: ClientSerializer.new(clients, { include: [:appointments] }).serializable_hash[:data],
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
      data: ClientSerializer.new(@client, { include: [:appointments] }).serializable_hash[:data]
    }
  end

  def create
    @client = Client.new(client_params.merge(external_id: SecureRandom.uuid))

    if @client.save
      render json: {
        data: ClientSerializer.new(@client).serializable_hash[:data],
        message: 'Client created successfully'
      }, status: :created
    else
      render json: {
        error: {
          type: 'validation_error',
          message: @client.errors.full_messages.to_sentence,
          details: @client.errors.as_json
        }
      }, status: :unprocessable_entity
    end
  end

  def update
    if @client.update(client_params)
      render json: {
        data: ClientSerializer.new(@client).serializable_hash[:data],
        message: 'Client updated successfully'
      }
    else
      render json: {
        error: {
          type: 'validation_error',
          message: @client.errors.full_messages.to_sentence,
          details: @client.errors.as_json
        }
      }, status: :unprocessable_entity
    end
  end

  def destroy
    @client.destroy
    render json: { message: 'Client deleted successfully' }, status: :ok
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:name, :email, :phone)
  end
end
