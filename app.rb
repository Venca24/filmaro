# Filmaro - simple app to show film data stored in Wikidata
#
# Copyright (C) 2017-2020  Vaclav Zouzalik
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

require 'sinatra'
require 'sinatra/cookies'

require './helpers/wikidata_helper'

def set_locale
  if params[:lang]
    I18n.locale = params[:lang]
    cookies[:lang] = I18n.locale
  else
    I18n.locale = cookies[:lang]
  end
rescue I18n::InvalidLocale
  I18n.locale = I18n.default_locale
end

def symbolize(array)
  array.map(&:to_sym)
end

get '/' do
  set_locale
  @title = I18n.t :main_page_title
  erb :index, layout: :layout
end

get '/about' do
  set_locale
  @title = I18n.t :about_page_title
  erb :about, layout: :layout
end

get '/copyright' do
  set_locale
  @title = I18n.t :copyright_page_title
  erb :copyright, layout: :layout
end

get '/item/:id' do
  set_locale
  @title = I18n.t :item_page_title
  @item = WikidataHelper.get_item(params['id'])
  @name = WikidataHelper.get_label(@item)
  @title = "#{@name} - #{I18n.t :filmaro}" if @name

  return erb :item_bad, layout: :layout unless @item

  @template = (symbolize(@item.claim_ids(:P31)) & ITEMS.keys).first
  @template = ITEMS[@template]

  @original_title = WikidataHelper.get_single_string(@item, :P1476)

  if @template == :film
    @video = WikidataHelper.get_media(@item, 'P10')
    @previous = WikidataHelper.get_single(@item, 'P155')
    @next = WikidataHelper.get_single(@item, 'P156')
  end

  @image = WikidataHelper.get_media(@item, 'P18')

  @links = {
    wikipedia: WikidataHelper.get_sitelink(@item, 'wiki'),
    wikiquote: WikidataHelper.get_sitelink(@item, 'wikiquote'),
    official: WikidataHelper.get_single_string(@item, :P856)
  }
  commons_category = WikidataHelper.get_single_string(@item, :P373)
  if commons_category
    @links[:commons_category] = 'https://commons.wikimedia.org/wiki/' \
      "Category:#{commons_category}"
  end

  erb :item, layout: :layout
end

get '/license' do
  set_locale
  @title = I18n.t :license_page_title
  erb :license, layout: :layout
end

get '/opensearch' do
  content_type 'text/xml'
  url = "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  File.read('./views/opensearch.xml').gsub(':url:', url)
end

get '/search' do
  set_locale
  @title = I18n.t :search_page_title

  @results = []
  tmp = WikidataItem.search("#{params[:q]}|film", 30)
  tmp.each do |item|
    tmp2 = WikidataItem.new(item)
    next unless WikidataHelper.supported_item?(tmp2)

    @results << {
      id: item,
      title: WikidataHelper.get_label(tmp2) || item
    }
  end

  # redirect if there is just one result
  redirect to("/item/#{@results.first[:id]}") if @results.size == 1

  erb :search, layout: :layout
end
