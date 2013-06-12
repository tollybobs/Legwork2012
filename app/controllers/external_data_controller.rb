class ExternalDataController < ApplicationController

  require 'net/http'
  require 'uri'

  def tweetyeah

    begin
      data = Rails.cache.fetch("tweetyeah", :expires_in => 1.hour + 5.minutes) do
        client = Twitter::Client.new(
          :consumer_key => "2NMtG86kPDlsCR1LpbVGyw",
          :consumer_secret => "MnLQnhR0udNQshMgF8bAFHmipSVZ66JyZwlDhx8ug",
          :oauth_token => "17035743-RgjgZQWBknSC8zzs6KkrnQOkMf1DnEx6baFwGEFR7",
          :oauth_token_secret => "YBeyoBVwD99T5FF37gBmtLAcfomMaHZRJm0rtnOY"
        )
        client.user_timeline('legwork')
      end
      render :json => data
    rescue => detail
      Rails.cache.delete("tweetyeah")
      render :json => Rails.cache.read('tweetno')
    ensure
      Rails.cache.write('tweetno', response.body)
    end

  end
end