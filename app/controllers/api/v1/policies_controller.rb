module Api
  module V1
    class PoliciesController < BaseController
      def index
        limit = [(policy_params[:limit] || 1000).to_i, 9999].min
        policies = Policy.where(network: policy_params[:network])
                           .order('created_at desc')
                           .limit(limit)

        render json: policies.map{ |policy| policy.to_builder.attributes! }, status: 200
      rescue ActionController::ParameterMissing
        render json: { 'status' => 'Parameter Missing' }, status: 400
      rescue StandardError => e
        Appsignal.send_error(e)
        render json: { 'status' => e.message }, status: 500
      end

      def show
        policy = Policy.find_by(pubkey: params[:pubkey], network: policy_params[:network])
        validators = policy&.validators
        other_identities = policy&.non_validators

        if policy
          policy_data = policy.to_builder.attributes!
          policy_data['validators'] = validators.map(&:account) if validators
          policy_data['other_identities'] = other_identities.map(&:account) if other_identities

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
          :limit
        )
      end

    end
  end
end