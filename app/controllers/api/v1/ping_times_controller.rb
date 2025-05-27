module Api
  module V1
      class PingTimesController < BaseController
        def ping_times
          limit = [(ping_time_params[:limit] || 1000).to_i, 9999].min
          render json: PingTime.where(network: ping_time_params[:network])
                               .order('created_at desc')
                               .limit(limit).to_json, status: 200
        rescue ActionController::ParameterMissing
          render json: { 'status' => 'Parameter Missing' }, status: 400
        rescue StandardError => e
          Appsignal.send_error(e)
          render json: { 'status' => e.message }, status: 500
        end

        def ping_time_stats
          limit = [(ping_time_params[:limit] || 100).to_i, 9999].min

          render json: PingTimeStat.where(network: ping_time_params[:network])
                                   .order('created_at desc')
                                   .limit(limit).to_json, status: 200
        end

        def collector
          params[:payload] = params[:payload]&.to_json
          @collector = ::Collector.new(
            collector_params.merge(
              user_id: User.where(api_token: request.headers['Token']).first.id
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

        def ping_time_params
          params.permit(
            :network,
            :limit
          )
        end
      end
  end
end
