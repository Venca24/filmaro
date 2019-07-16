# Filmaro - simple app to show film data stored in Wikidata
#
# Copyright (C) 2017-2019  Vaclav Zouzalik
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

require 'wikidata'

# temporarily fixes spam from hashie used in the gem
Hashie.logger = Logger.new(nil)

# class to help process the data from Wikidata for Filmaro
class WikidataHelper
  class << self
    COMMONS_FILE_URL = 'https://commons.wikimedia.org/wiki/File:'.freeze

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

      item = Wikidata::Item.find(id)
      return nil unless supported_item?(item)

      item
    end

    def get_date(item, property_id)
      tmp = item.property(property_id)
      tmp = tmp.date if tmp
      "#{tmp.day}.#{tmp.month}.#{tmp.year}" if tmp
    end

    def get_description(item)
      return nil unless item.is_a?(Wikidata::Item)

      tmp = item.descriptions[I18n.locale]
      tmp ? tmp['value'] : nil
    end

    def get_label(item, strict = false)
      return nil unless item.is_a?(Wikidata::Item)

      tmp = item.labels[I18n.locale]
      tmp = item.labels[I18n.default_locale] unless tmp || strict
      tmp ? tmp['value'] : nil
    end

    def get_media(item, property_id)
      tmp = item.property(property_id)
      return nil unless tmp

      {
        url: tmp.url,
        name: tmp.value,
        commons_url: COMMONS_FILE_URL + tmp.value.tr(' ', '_')
      }
    end

    def get_multiple(item, property_id)
      values = item.property_ids(property_id).map do |id|
        {
          id: id,
          title: get_label(Wikidata::Item.find(id), true)
        }
      end
      values.reject { |hash| hash[:title].nil? }
    end

    def get_property_label(id)
      return nil unless good_property_id?(id)

      label = I18n.t(id.to_sym)
      if label.include?('translation missing')
        label = Wikidata::Item.find(id).labels[I18n.locale]
        label ||= Wikidata::Item.find(id).labels[I18n.default_locale]
        label = label['value']
      end
      label
    end

    def get_quantity(item, property_id)
      return nil unless good_property_id?(property_id)

      tmp = item.property(property_id)
      tmp ? tmp.amount.to_i : nil
    end

    def get_single(item, property_id)
      id = item.property_id(property_id)
      result = {
        id: id,
        title: get_label(Wikidata::Item.find(id), true)
      }
      result[:title] ? result : {}
    end

    def get_single_string(item, property)
      string = item.property(property)
      string ? string.value : nil
    end

    def get_sitelink(item, project)
      return nil unless item.is_a?(Wikidata::Item) && project.is_a?(String)

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
      (symbolize(item.property_ids(:P31)) & ITEMS.keys).empty? ? false : true
    end

    private

    def initialize_property_cache
      return if @cached_property_label

      @cached_property_label = {}
      LANGS[:available_locales].keys.each do |lang|
        @cached_property_label[lang] = {}
      end
    end
  end
end
