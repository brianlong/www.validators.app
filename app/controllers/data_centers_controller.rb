class DataCentersController < ApplicationController

  # before_action :set_default_filters, only: :data_center
  # index_params[:network]
  # index_params[:sort_by]
  def index
    @sort_by = index_params[:sort_by] == 'asn' ? 'asn' : 'data_center'
    @results = SortedDataCenters.new(
      sort_by: @sort_by, 
      network: params[:network]
    ).call

    if @sort_by == 'asn'
      @asn_stat = AsnStat.where(network: params[:network])
    end
  end

  # params[:network]
  # params[:key]
  def data_center
    key = show_params[:key].gsub('-slash-', '/')

    @per = 25

    default_filters = {
      "delinquent": true,
      "inactive": true,
      "private": true
    }

    @filters = show_params[:filter_by]&.to_h || default_filters
    
    data_centers = DataCenter.where(data_center_key: key)
    @validators = Validator.joins(:validator_score_v1, :data_center)
                           .where("data_centers.id IN (?) AND validator_score_v1s.network = ? AND validator_score_v1s.active_stake > ?", data_centers.ids, show_params[:network], 0)
                           .filtered_by(@filters)
                           .order("validator_score_v1s.active_stake desc")

    if params[:show_private]
      @validators = @validators.with_private(show: params[:show_private])
    end

    @dc_stake = @validators.sum(:active_stake)          
    @validators = @validators.page(params[:page]).per(@per)
    @batch = Batch.last_scored(params[:network])
    @population = @validators.total_count
    @total_stake = ValidatorScoreV1.by_network_with_active_stake(params[:network]).sum(:active_stake)
    @dc_info = data_centers.first || DataCenter.new(data_center_key: key)
  end

  private

  def set_default_filters

  end

  def index_params
    params.permit(:network, :sort_by)
  end

  def show_params
    if params[:filter_by]
      params.permit(:network, :page, :key, params.require(:filter_by)&.permit!)
    else
      params.permit(:network, :page, :key)
    end
  end
end
