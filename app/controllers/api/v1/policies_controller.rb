module Api
  module V1
    class PoliciesController < BaseController
      def index
        result = PolicyQuery.new(
          network: policy_params[:network] || 'mainnet',
          kind: :v2,
          limit: policy_params[:limit],
          query: policy_params[:query],
          page: policy_params[:page] || 1
        ).call

        response = {
          policies: result[:policies].map { |policy|
            strategy_humanized = policy.strategy ? 'Allow' : 'Deny'
            policy.to_builder.attributes!.merge!("strategy"=>strategy_humanized)
          },
          total_count: result[:total_count]
        }

        render json: response, status: 200
      rescue ActionController::ParameterMissing
        render json: { 'status' => 'Parameter Missing' }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { 'status' => e.message }, status: 500
      end

      def show
        limit = [(policy_params[:limit] || 25).to_i, 9999].min
        page = (policy_params[:page] || 1).to_i

        policy = Policy.find_by(pubkey: params[:pubkey], network: policy_params[:network])

        total_validators = policy&.validators
        validators = policy&.validators&.limit(limit)&.offset((page - 1) * limit)
        total_other_identities = policy&.non_validators
        other_identities = policy&.non_validators&.limit(limit)&.offset((page - 1) * limit)
        
        if policy
          policy_data = policy.to_builder.attributes!
          policy_data['strategy'] = policy.strategy ? 'Allow' : 'Deny'
          policy_data['validators'] = validators.map(&:account) if validators
          policy_data['total_validators'] = total_validators.count if total_validators
          policy_data['other_identities'] = other_identities.map(&:account) if other_identities
          policy_data['total_other_identities'] = total_other_identities.count if total_other_identities

          render json: policy_data.to_json, status: 200
        else
          render json: { 'status' => 'Policy not found' }, status: 404
        end
      rescue ActionController::ParameterMissing
        render json: { 'status' => 'Parameter Missing' }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { 'status' => e.message }, status: 500
      end

      private

      def policy_params
        params.permit(
          :network,
          :limit,
          :query,
          :page
        )
      end

    end
  end
end
