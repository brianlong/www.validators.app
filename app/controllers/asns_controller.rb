class AsnsController < ApplicationController
  def show
    @data_centers = Ip.where(traits_autonomous_system_number: asn_params[:asn])
                     .pluck(:data_center_key)

    render file: "#{Rails.root}/public/404.html", status: 404 if @data_centers.empty?

    @scores = ValidatorScoreV1.where(network: asn_params[:network])
                              .where('active_stake > 0')
                              .where(data_center_key: @data_centers)

    @asn_stake = @scores.sum(:active_stake)

    @total_stake = ValidatorScoreV1.where(network: asn_params[:network])
                                   .where('active_stake > 0')
                                   .sum(:active_stake)
  end

  private

  def asn_params
    params.permit :asn, :network
  end
end
