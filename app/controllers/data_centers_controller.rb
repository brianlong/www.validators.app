class DataCentersController < ApplicationController

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

    @display = show_params[:display].blank? ? "all" : show_params[:display]
    @filter_by = show_params[:filter_by].blank? || @display != "all" ? [] : show_params[:filter_by]

    # throw @display

    data_centers = DataCenter.where(data_center_key: key)
    @validators = Validator.joins(:validator_score_v1, :data_center)
                           .where("data_centers.id IN (?) AND validator_score_v1s.network = ? AND validator_score_v1s.active_stake > ?", data_centers.ids, show_params[:network], 0)
                           .find_by_type(@display)
                           .filtered_by(@filter_by)
                           .order("validator_score_v1s.active_stake desc")

    @dc_stake = @validators.sum(:active_stake)          
    @validators = @validators.page(params[:page]).per(@per)
    @batch = Batch.last_scored(params[:network])
    @population = @validators.total_count
    @total_stake = ValidatorScoreV1.by_network_with_active_stake(params[:network]).sum(:active_stake)
    @dc_info = data_centers.first || DataCenter.new(data_center_key: key)
  end

  private

  def index_params
    params.permit(:network, :sort_by)
  end

  def show_params
    params.permit(:network, :page, :key, :display, filter_by: [])
  end
end
