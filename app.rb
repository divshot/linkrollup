require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/config_file'
require 'buffer'

config_file 'config/env.yml'

helpers do
  def updateLink(updateText)
    linkUrl = updateText.scan(/(https?:\/\/([-\w\.]+)+(:\d+)?(\/([\w\/_\.]*(\?\S+)?)?)?)/)
    unless linkUrl.empty?
      link = updateText.sub(linkUrl[0][0], '').gsub(/(?:^|\s)(#\S+)/, '').strip
      "<li><a href='#{linkUrl[0][0]}'>#{link}</a></li>"
    else
      link = updateText.gsub(/(?:^|\s)(#\S+)/, '').strip
      "<li>#{link}</li>"
    end
  end
end

get '/' do
  buffer = Buffer::Client.new settings.BUFFER_ACCESS_TOKEN
  profiles = buffer.get 'profiles'
  @updates = buffer.api :get, "profiles/#{profiles[0]['id']}/updates/sent.json?since=#{8.days.ago.to_i}&count=100"
  @updates['updates'].sort! { |a,b| a['due_at'] <=> b['due_at'] }

  erb :list, :trim => '-'
end