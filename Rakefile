require 'dotenv'
#require 'active_record'
require 'shopify_api'
#require 'sinatra/activerecord/rake'

require_relative 'checklist'

#require 'active_record/railties/databases.rake'

Dotenv.load


namespace :pull_shopify do
    desc 'Pull down the prospective rollover month collection and products, metafields etc'
    task :get_next_month_collection, :email do |t, args|
        email = args['email']
        Checklist::ShopifyGetter.new.shopify_get_all_resources(email)
    end

end
