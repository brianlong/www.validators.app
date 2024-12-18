module Api
  module V1
      class PingTimesController < BaseController
        def ping_times
          limit = params[:limit] || 1000
          render json: PingTime.where(network: params[:network])
                               .order('created_at desc')
                               .limit(limit).to_json, status: 200
        rescue ActionController::ParameterMissing
          render json: { 'status' => 'Parameter Missing' }, status: 400
        rescue StandardError => e
          Appsignal.send_error(e)
          render json: { 'status' => e.message }, status: 500
        end

        def collector
          @collector = ::Collector.new(
            collector_params.merge(
              user_id: User.where(api_token: request.headers['Token']).first.id,
              ip_address: request.remote_ip
            )
          )
          if @collector.save
            CollectorWorker.perform_async({"collector_id" => @collector.id})
            render json: { 'status' => 'Accepted' }, status: 202
          else
            render json: { 'status' => 'Bad Request' }, status: 400
          end
        rescue StandardError => e
          Appsignal.send_error(e)
          render json: { 'status' => e.message }, status: 500
        end

        private

        def collector_params
          params.permit(
            :payload_type,
            :payload_version,
            :payload
          )
        end
      end
  end
end