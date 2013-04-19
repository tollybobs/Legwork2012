class ExternalDataController < ApplicationController
  
  require 'net/http'
  require 'uri'

  def tweetyeah

    begin
      data = Rails.cache.fetch("tweetyeah", :expires_in => 1.hour + 5.minutes) do
        uri = URI.parse("https://api.twitter.com/1/statuses/user_timeline/Legwork.json?&trim_user=true&count=100&exclude_replies=true&callback=?")
        http = Net::HTTP.new(uri.host, uri.port)
        http.use_ssl = true
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)
        Rails.cache.write('tweetno', response.body)
        response.body
      end
      render :json => JSON.parse(data)
    rescue => detail
      Rails.cache.delete("tweetyeah")
      render :json => JSON.parse(Rails.cache.read('tweetno'))
    end

  end
end