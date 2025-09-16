class SyncAppointmentsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting appointments sync job"
    result = DataSyncService.sync_appointments
    
    return unless result.is_a?(Hash)
    
    if result[:success]
      Rails.logger.info "Appointments sync job completed: #{result[:synced_count]} appointments synced"
      Rails.logger.warn "Appointments sync errors: #{result[:errors].join('; ')}" if result[:errors]&.any?
    else
      Rails.logger.error "Appointments sync job failed: #{result[:error]}"
    end
  end
end
