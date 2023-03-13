# frozen_string_literal: true

# helper.rb
require 'date'
require 'erb'
include ERB::Util

# PromoNotes < Sinatra::Base
module Sinatra
  module RolloverChecklist
    # Marika Promo Notes Helpers
    module Helpers



    def sanitize_params(params)
        sanitized_params = nil
        puts '----SANITIZER----'
        puts params.class
        puts params.inspect
        if params.is_a?(Hash)
          sanitized_params = {}
          params.each do |key, value|
            sanitized_params[key] = html_escape(value)
          end
        else
          sanitized_params = []
          params.each do |parameter|
            parameter.each do |key, value|
              sanitized_params << { parameter[key].to_s => html_escape(value) }
            end
          end
        end

        sanitized_params
    end

    end #end Helpers
  end #end RolloverChecklist

end