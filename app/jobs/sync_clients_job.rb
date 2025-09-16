class SyncClientsJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info "Starting clients sync job"
    result = DataSyncService.sync_clients
    
    return unless result.is_a?(Hash)
    
    if result[:success]
      Rails.logger.info "Clients sync job completed: #{result[:synced_count]} clients synced"
      Rails.logger.warn "Clients sync errors: #{result[:errors].join('; ')}" if result[:errors]&.any?
    else
      Rails.logger.error "Clients sync job failed: #{result[:error]}"
    end
  end
end
