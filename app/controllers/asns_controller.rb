class AsnsController < ApplicationController
  def show
    @data_centers = Ip.where(traits_autonomous_system_number: asn_params[:asn])
                     .pluck(:data_center_key).uniq

    render file: "#{Rails.root}/public/404.html", status: 404 if @data_centers.empty?

    @per = 25

    @scores = ValidatorScoreV1.includes(:validator)
                              .by_network_with_active_stake(asn_params[:network])
                              .by_data_centers(@data_centers)
                              .page(params[:page])
                              .per(@per)
    @validators = @scores.map(&:validator).compact

    @batch = Batch.last_scored(params[:network])

    @total_stake = ValidatorScoreV1.by_network_with_active_stake(asn_params[:network])
                                   .by_data_centers(@data_centers)
                                   .sum(:active_stake)
    @asn_stake = @scores.sum(:active_stake)
  end

  private

  def asn_params
    params.permit :asn, :network
  end
end
