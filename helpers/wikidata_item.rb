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

require_relative 'wikidata_fetcher'

class WikidataItem
  def initialize(id)
    return unless id

    @item = WikidataFetcher.get_item(id)
  end

  def claims
    @item['claims']
  end

  def claim(id)
    claims[id.to_s]
  end

  def claim_amount(id)
    claim_amounts(id).first
  end

  def claim_amounts(id)
    tmp = claim(id)
    return [] unless tmp

    tmp.map do |value|
      value.dig('mainsnak', 'datavalue', 'value', 'amount')
    end
  end

  def claim_date(id)
    tmp = claim(id)
    tmp = tmp.first['mainsnak']['datavalue']['value']['time'] if tmp
    if tmp.match?(/\+\d{4}-00-00T/)
      return Time.strptime(tmp, '+%Y')
    elsif tmp.match?(/\+\d{4}-\d{2}-00T/)
      return Time.strptime(tmp, '+%Y-%m')
    else
      Time.strptime(tmp, '+%Y-%m-%d')
    end
  end

  def claim_id(id)
    tmp = claim_ids(id)
    return nil unless tmp

    tmp.first
  end

  def claim_ids(id)
    tmp = claim(id)
    return nil unless tmp

    tmp.map do |value|
      value.dig('mainsnak', 'datavalue', 'value', 'id')
    end
  end

  def claim_string(id)
    tmp = claim(id)
    return nil unless tmp

    tmp.map do |value|
      value['mainsnak']['datavalue']['value']['text']
    end
  end

  def descriptions
    @item['descriptions']
  end

  def id
    @item['id']
  end

  def labels
    @item['labels']
  end

  def label(lang)
    tmp = labels[lang]
    tmp ||= labels[I18n.default_locale.to_s]
    return unless tmp

    tmp['value']
  end

  def sitelinks
    @item['sitelinks']
  end

  def self.search(query, limit)
    url = \
      'https://www.wikidata.org/w/api.php?action=query&list=search&srsearch=' +
      query.tr(' ', '+') + '&srlimit=' + limit.to_s + '&srprop=size&format=json'
    Typhoeus::Config.cache = Cache.new
    json = Typhoeus.get(url).body
    data = JSON.parse(json)
    result = []
    data['query']['search'].each { |x| result.concat([x['title']]) }
    result
  end
end
