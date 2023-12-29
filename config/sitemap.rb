host = if Rails.env.production?
         "https://www.validators.app"
       elsif Rails.env.stage?
         "https://stage.validators.app"
       else
         "http://localhost:3000"
       end

SitemapGenerator::Sitemap.default_host = host
sitemap_url = "#{host}/sitemap.xml.gz"

SitemapGenerator::Sitemap.search_engines = {
  google: "http://www.google.com/webmasters/tools/ping?sitemap=#{sitemap_url}",
  bing: "https://www.bing.com/ping?sitemap=#{sitemap_url}"
}

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
    add(data_center_path(key: dc.data_center_key.gsub('/', '-slash-')),
        lastmod: dc.updated_at,
        changefreq: 'daily')
  end

  Validator.active.find_each do |v|
    add(validator_path(v.account, network: v.network),
        lastmod: v.updated_at,
        changefreq: 'hourly')
  end

  VoteAccount.active.includes(:validator).find_each do |va|
    add(validator_vote_account_path(vote_account: va.account, account: va.validator.account),
        lastmod: va.updated_at,
        changefreq: 'hourly')
  end

  add '/data-centers', changefreq: 'daily'
  add '/validators', changefreq: 'hourly'
  add '/trent-mode', changefreq: 'daily'
  add '/sol-prices', changefreq: 'daily'
  add '/stake-pools', changefreq: 'daily'
  add '/commission-changes', changefreq: 'hourly'
  add '/authorities_changes', changefreq: 'hourly'
  add '/stake-explorer', changefreq: 'daily'
  add '/ping-thing', changefreq: 'hourly'
  add '/log-deep-dives', changefreq: 'yearly'
  add '/log-deep-dives/slot-72677728', changefreq: 'yearly'
  add '/contact-us', changefreq: 'yearly'
  add '/api-documentation', changefreq: 'monthly'
  add '/cookie-policy', changefreq: 'yearly'
  add '/faq', changefreq: 'monthly'
  add '/privacy-policy-california', changefreq: 'yearly'
  add '/privacy-policy', changefreq: 'yearly'
  add '/terms-of-use', changefreq: 'yearly'
  add '/users/sign_in', changefreq: 'yearly'
  add '/users/sign_out', changefreq: 'yearly'
  add '/users/password/new', changefreq: 'yearly'
  add '/users/sign_up', changefreq: 'yearly'
  add '/users/confirmation/new', changefreq: 'yearly'
  add '/users/unlock/new', changefreq: 'yearly'
end
