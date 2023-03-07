# frozen_string_literal: true

module StakePoolsHelper

  def stake_pool_logo_urls(stake_pools)
    stake_pools.map { |stake_pool| logo_url[stake_pool] }
  end

  private

  def logo_url
    {
      "Socean" => "socean-logo.svg",
      "Marinade" => "marinade-logo.svg",
      "Jpool" => "jpool-logo.svg",
      "Lido" => "lido-logo.svg",
      "DAOPool" => "daopool-logo.png",
      "Eversol" => "eversol-logo.svg",
      "BlazeStake" => "blazestake-logo.png",
      "Jito" => "jito-logo.svg"
    }
  end
end
