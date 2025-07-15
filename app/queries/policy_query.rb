class PolicyQuery
  def initialize(network: "mainnet", kind: :v2, limit: 25, query: nil, page: 1)
    @page = page.to_i
    @network = network
    @kind = kind
    @limit = [(limit || 25).to_i, 9999].min
    @query = query
    @total_count = 0
  end

  def call()
    {
      policies: policies_query,
      total_count: @total_count
    }
  end

  def identities_ids
    return [] if @query.blank?
    PolicyIdentity.where("account LIKE ?", "%#{@query}%").pluck(:policy_id).uniq
  end

  def policies_query
    policies = Policy.where(network: @network, kind: @kind)
    if @query.blank?
      @total_count = policies.count
      policies = policies.limit(@limit).offset((@page - 1) * @limit)
    else
      policies = policies.where("
      name LIKE ? OR 
      symbol LIKE ? OR
      pubkey LIKE ? OR 
      owner LIKE ? OR
      id IN (?)", "%#{@query}%", "%#{@query}%", "%#{@query}%", identities_ids)
      @total_count = policies.count
      policies = policies.limit(@limit).offset((@page - 1) * @limit)
    end
    policies
  end
end