
class ApiShopify
    
    def initialize(shop_name)
        @store_url = "https://#{shop_name}.myshopify.com/admin/api/#{ENV['API_VERSION']}/"
        @token = ENV["#{shop_name}_api_token"]
        @new_header = {"X-Shopify-Access-Token" => @token}
        @change_header = {"Content-Type" => "application/json",
        "X-Shopify-Access-Token" => @token }
    
      end
    
      def store_url
        return @store_url
      end
    
      def get_header
        return @new_header
      end
    
      def get_change_header
        return @change_header
      end
    
      def self.determine_sleep(header)
        # puts "received header #{header}"
        # puts header.inspect
        parts_of_header = header.split("/")
        # puts parts_of_header.inspect
        numerator = parts_of_header[0].to_i
        denominator = parts_of_header[1].to_f
        percentage_used = (numerator/denominator)*100
        puts "percentage_used = #{percentage_used}"
        if percentage_used > 65.0
          puts "sleeping 10 secs"
          sleep 10
    
        else
          puts "not sleeping"
        end
        
    
      end





end