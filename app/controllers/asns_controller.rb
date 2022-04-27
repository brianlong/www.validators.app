class AsnsController < ApplicationController
  def show
    network = asn_params[:network]

    @data_centers = DataCenter.joins(:validator_score_v1s)
                              .where(traits_autonomous_system_number: asn_params[:asn])
                              .where("validator_score_v1s.network = ? AND validator_score_v1s.active_stake > ?", network, 0)
                              .pluck(:id, :data_center_key)
                              .uniq

    data_center_ids = @data_centers.map { |dc| dc[0] }
    @data_center_keys = @data_centers.map { |dc| dc[1] }.uniq

    render file: "#{Rails.root}/public/404.html", layout: nil, status: 404 if @data_centers.empty?

    @per = 25

    @scores = ValidatorScoreV1.joins(:data_center)
                              .where("data_centers.id IN (?)", data_center_ids)
                              .by_network_with_active_stake(network)
                              .filtered_by(asn_params[:filter_by]&.to_sym)
    if params[:show_private]
      @scores = @scores.with_private(show: params[:show_private])
    end
    
    @asn_stake = @scores.sum(:active_stake)

    @scores = @scores.page(asn_params[:page])
                     .per(@per)

    @validators = @scores.includes(:validator).map(&:validator).compact

    @batch = Batch.last_scored(network)

    @population = @scores.total_count

    @total_stake = ValidatorScoreV1.joins(:data_center)    
                                   .by_network_with_active_stake(network)
                                   .where("data_centers.id IN (?)", data_center_ids)
                                   .sum(:active_stake)
  end

  private

  def asn_params
    params.permit :asn, :network, :filter_by, :page
  end
end
