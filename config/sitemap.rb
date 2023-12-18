SitemapGenerator::Sitemap.default_host = if Rails.env.production?
                                           "https://www.validators.app"
                                         elsif Rails.env.stage?
                                           "https://stage.validators.app"
                                         else
                                           "http://www.example.com"
                                         end

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  #   Article.find_each do |article|
  #     add article_path(article), :lastmod => article.updated_at
  #   end

  DataCenter.find_each do |dc|
    add data_center_path(dc.data_center_key), lastmod: dc.updated_at
  end

  Validator.find_each do |v|
    add File.join('validators', v.network, v.account), lastmod: v.updated_at
    add validator_path(v.account, network: v.network), lastmod: v.updated_at
  end

  VoteAccount.includes(:validator).find_each do |va|
    add validator_vote_account_path(vote_account: va.account, account: va.validator.account), lastmod: va.updated_at
  end

  ExplorerStakeAccount.find_each do |esa|
    add explorer_stake_account_path(esa.stake_pubkey), lastmod: esa.updated_at
  end

  add '/data-centers', changefreq: 'daily'
  add '/validators', changefreq: 'daily'
  add '/trent-mode', changefreq: 'daily'
  add '/sol-prices', changefreq: 'daily'
  add '/stake-pools', changefreq: 'daily'
  add '/commission-changes', changefreq: 'daily'
  add '/authorities_changes', changefreq: 'hourly'
  add '/stake-explorer', changefreq: 'daily'
  add '/ping-thing', changefreq: 'daily'
  add '/log-deep-dives'
  add '/log-deep-dives/slot-72677728'
  add '/users/sign_in'
  add '/users/sign_out'
  add '/users/password/new'
  add '/users/sign_up'
  add '/users/confirmation/new'
  add '/users/unlock/new'
  add '/contact-us'
  add '/stake-boss'
  add '/api-documentation'
  add '/cookie-policy'
  add '/faq'
  add '/privacy-policy-california'
  add '/privacy-policy'
  add '/sample-chart'
  add '/terms-of-use'
end
