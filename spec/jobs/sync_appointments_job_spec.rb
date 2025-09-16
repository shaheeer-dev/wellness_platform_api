require 'rails_helper'

RSpec.describe SyncAppointmentsJob, type: :job do
  describe '#perform' do
    let(:job) { described_class.new }

    describe 'successful synchronization' do
      let(:successful_result) do
        {
          success: true,
          synced_count: 5,
          errors: []
        }
      end

      before do
        allow(DataSyncService).to receive(:sync_appointments).and_return(successful_result)
      end

      it 'delegates appointment synchronization to DataSyncService' do
        expect(DataSyncService).to receive(:sync_appointments)
        job.perform
      end

      it 'completes successfully when DataSyncService succeeds' do
        expect { job.perform }.not_to raise_error
      end
    end

    describe 'failed synchronization' do
      let(:failed_result) do
        {
          success: false,
          error: 'External API unavailable'
        }
      end

      before do
        allow(DataSyncService).to receive(:sync_appointments).and_return(failed_result)
      end

      it 'handles DataSyncService failure gracefully' do
        expect { job.perform }.not_to raise_error
      end

      it 'still calls DataSyncService even when it fails' do
        expect(DataSyncService).to receive(:sync_appointments)
        job.perform
      end
    end

    describe 'job configuration and inheritance' do
      it 'inherits from ApplicationJob' do
        expect(described_class.superclass).to eq(ApplicationJob)
      end

      it 'is configured to run on the default queue' do
        expect(described_class.new.queue_name).to eq('default')
      end
    end

    describe 'error handling' do
      context 'when DataSyncService raises an exception' do
        before do
          allow(DataSyncService).to receive(:sync_appointments).and_raise(StandardError, 'Database connection failed')
        end

        it 'allows the exception to propagate for job retry mechanisms' do
          expect { job.perform }.to raise_error(StandardError, 'Database connection failed')
        end
      end

      context 'when DataSyncService returns unexpected result format' do
        before do
          allow(DataSyncService).to receive(:sync_appointments).and_return(nil)
        end

        it 'handles nil result without crashing' do
          expect { job.perform }.not_to raise_error
        end
      end
    end
  end
end
