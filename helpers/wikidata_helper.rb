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

# frozen_string_literal: true

require_relative 'wikidata_item'

# class to help process the data from Wikidata for Filmaro
class WikidataHelper
  class << self
    COMMONS_FILE_URL = 'https://commons.wikimedia.org/wiki/File:'

    def cached_property_label(id)
      initialize_property_cache

      label = @cached_property_label.dig(I18n.locale, id)
      if label
        # delete the cached value in order to keep them updating
        # but not all at the same time
        @cached_property_label[I18n.locale].delete(id) if rand(60) == 1
      else
        label = get_property_label(id)
        @cached_property_label[I18n.locale][id] = label
      end
      label
    end

    def get_item(id)
      return nil unless good_id?(id)

      item = WikidataItem.new(id)
      return nil unless supported_item?(item)

      item
    end

    def get_date(item, property_id)
      tmp = item.claim_date(property_id)
      "#{tmp.day}.#{tmp.month}.#{tmp.year}" if tmp
    end

    def get_description(item)
      return nil unless item.is_a?(WikidataItem)

      tmp = item.descriptions[I18n.locale.to_s]
      tmp ? tmp['value'] : nil
    end

    def get_label(item)
      return nil unless item.is_a?(WikidataItem)

      item.label(I18n.locale)
    end

    def get_media(item, property_id)
      tmp = item.claim(property_id)
      return nil unless tmp

      tmp = tmp.first
      return nil unless tmp['mainsnak']['datatype'] == 'commonsMedia'

      name = tmp['mainsnak']['datavalue']['value']
      {
        url: get_commons_file_by_name(name),
        name: name,
        commons_url: COMMONS_FILE_URL + name.tr(' ', '_')
      }
    end

    def get_multiple(item, property_id)
      tmp = item.claim_ids(property_id)
      return [] unless tmp

      values = tmp.map do |id|
        {
          id: id,
          title: get_item_label(id)
        }
      end
      values.reject { |hash| hash[:title].nil? }
    end

    def get_property_label(id)
      return nil unless good_property_id?(id)

      label = I18n.t(id.to_sym)
      if label.match?(/translation missing/i)
        label = WikidataFetcher.get_labels(
          id, "#{I18n.locale}|#{I18n.default_locale}"
        )
        label = label[I18n.locale.to_s] || label[I18n.default_locale.to_s]
        label = label['value']
      end
      label
    end

    def get_item_label(id)
      return nil unless good_id?(id)

      label = WikidataFetcher.get_labels(
        id, "#{I18n.locale}|#{I18n.default_locale}"
      )
      label = label[I18n.locale.to_s] || label[I18n.default_locale.to_s]
      label ? label['value'] : id
    end

    def get_quantity(item, property_id)
      return nil unless good_property_id?(property_id)

      item.claim_amount(property_id)&.to_i
    end

    def get_single(item, property_id)
      id = item.claim_id(property_id)
      return {} unless id

      result = {
        id: id,
        title: get_item_label(id)
      }
      result[:title] ? result : {}
    end

    def get_single_string(item, property)
      item.claim_string(property)&.first
    end

    def get_sitelink(item, project)
      return nil unless item.is_a?(WikidataItem) && project.is_a?(String)

      sitelinks = item.sitelinks
      page = sitelinks["#{I18n.locale}#{project}"]
      project = 'wikipedia' if project == 'wiki'
      "https://#{I18n.locale}.#{project}.org/wiki/#{page['title']}" \
        if page && page['title']
    end

    def good_id?(id)
      id.is_a?(String) && id =~ /Q\d+/ ? true : false
    end

    def good_property_id?(id)
      id.is_a?(String) && id =~ /P\d+/ ? true : false
    end

    def supported_item?(item)
      instance_of = item.claim_ids(:P31)
      return false unless instance_of

      (symbolize(instance_of) & ITEMS.keys).empty? ? false : true
    end

    private

    def initialize_property_cache
      return if @cached_property_label

      @cached_property_label = {}
      LANGS[:available_locales].each_key do |lang|
        @cached_property_label[lang] = {}
      end
    end

    def get_commons_file_by_name(name)
      url = \
        'https://commons.wikimedia.org/w/api.php?action=query&titles=File:' \
        "#{CGI.escape(name)}&prop=imageinfo&iiprop=url&format=json"

      json = Typhoeus.get(url).body
      json = JSON.parse(json)
      json = json['query']['pages'].first
      json[1]['imageinfo'][0]['url']
    end
  end
end
