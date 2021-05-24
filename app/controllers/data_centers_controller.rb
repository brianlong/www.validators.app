class DataCentersController < ApplicationController
  # params[:network]
  def index
    sort_by = params[:sort_by] == 'asn' ? 'asn' : 'data_center'
    @results = SortedDataCenters.call(
      sort_by: sort_by, 
      network: params[:network]
    )
  end

  # params[:network]
  # params[:key]
  def data_center
    key = params[:key].gsub('-slash-', '/')
    # sql = "
    #   SELECT *
    #   FROM validators val
    #   INNER JOIN validator_score_v1s score ON val.id = score.validator_id
    #   WHERE score.network = '#{params[:network]}'
    #   AND score.active_stake > 0
    #   AND score.ip_address IN (
    #     SELECT ip_address from ips
    #     WHERE data_center_key = '#{key}'
    #   )
    #   ORDER BY val.account
    # "
    # @validators = Validator.connection.execute(sql)
    @scores = ValidatorScoreV1.where(network: params[:network])
                              .where(data_center_key: key)
                              .where('active_stake > 0')
                              .order('active_stake desc')

    @total_stake = ValidatorScoreV1.where(network: params[:network])
                                   .where('active_stake > 0')
                                   .sum(:active_stake)
    @dc_stake = @scores.where(data_center_key: key).sum(:active_stake)
    @dc_info = Ip.where(data_center_key: key).last || Ip.new(data_center_key: key)
  end
end
