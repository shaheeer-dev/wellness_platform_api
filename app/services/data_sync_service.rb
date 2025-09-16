class DataSyncService
  def self.sync_clients
    new.sync_clients
  end

  def self.sync_appointments
    new.sync_appointments
  end

  def sync_clients
    response = ExternalApiService.fetch_clients

    unless response[:success]
      Rails.logger.error "Failed to fetch clients: #{response[:error]}"
      return { success: false, error: response[:error] }
    end

    clients_data = JSON.parse(response[:data])
    synced_count = 0
    errors = []

    clients_data.each do |client_data|
      begin
        client = Client.find_or_initialize_by(external_id: client_data['id'])
        client.assign_attributes(
          name: client_data['name'],
          email: client_data['email'],
          phone: client_data['phone']
        )

        if client.save
          synced_count += 1
        else
          errors << "Client #{client_data['id']}: #{client.errors.full_messages.join(', ')}"
        end
      rescue StandardError => e
        errors << "Client #{client_data['id']}: #{e.message}"
      end
    end

    Rails.logger.info "Synced #{synced_count} clients"
    Rails.logger.error "Sync errors: #{errors.join('; ')}" if errors.any?

    { success: true, synced_count: synced_count, errors: errors }
  end

  def sync_appointments
    response = ExternalApiService.fetch_appointments

    unless response[:success]
      Rails.logger.error "Failed to fetch appointments: #{response[:error]}"
      return { success: false, error: response[:error] }
    end

    appointments_data = JSON.parse(response[:data])
    synced_count = 0
    errors = []

    appointments_data.each do |appointment_data|
      begin
        # Find client first
        client = Client.find_by(external_id: appointment_data['client_id'])
        unless client
          errors << "Appointment #{appointment_data['id']}: Client not found"
          next
        end

        appointment = Appointment.find_or_initialize_by(external_id: appointment_data['id'])
        appointment.assign_attributes(
          client: client,
          appointment_type: appointment_data['appointment_type'] || 'Consultation',
          scheduled_at: DateTime.parse(appointment_data['time'] || appointment_data['scheduled_at']),
          status: appointment_data['status'] || 'scheduled',
          notes: appointment_data['notes']
        )

        if appointment.save
          synced_count += 1
        else
          errors << "Appointment #{appointment_data['id']}: #{appointment.errors.full_messages.join(', ')}"
        end
      rescue StandardError => e
        errors << "Appointment #{appointment_data['id']}: #{e.message}"
      end
    end

    Rails.logger.info "Synced #{synced_count} appointments"
    Rails.logger.error "Sync errors: #{errors.join('; ')}" if errors.any?

    { success: true, synced_count: synced_count, errors: errors }
  end
end
