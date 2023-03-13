# frozen_string_literal: true

require 'shopify_api'
require 'dotenv'
require 'json'

Dotenv.load
Dir[File.join(__dir__, 'lib', '*.rb')].each { |file| require file }
#Dir[File.join(__dir__, 'models', '*.rb')].each { |file| require file }

# Create Promo Note Metafield for products at Shopify
class CheckRollover
  @queue = :create_checklist_csv
  #extend ParamsCreator
  #extend ShopifyThrottle

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def self.perform(params)
    puts "Starting ..."
    puts "I have #{params}"

  end

end