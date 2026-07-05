# Filmaro - simple app to show film data stored in Wikidata
#
# Copyright (C) 2017-2026  Vaclav Zouzalik
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

require_relative 'wikidata_fetcher'

# This class provides an interface for interacting with items from Wikidata
# using the Wikidata API. It encapsulates functionalities such as fetching
# item details, retrieving claims and their associated data (like amounts,
# dates, strings), descriptions, labels in various languages, and site links.
# Additionally, it offers a search functionality to find titles based
# on queries.
class WikidataItem
  # Initializes a new WikidataItem object.
  #
  # @param id [String] The unique identifier of the Wikidata item.
  def initialize(id)
    return unless id

    @item = WikidataFetcher.get_item(id)
  end

  # Retrieves all claims associated with the Wikidata item.
  #
  # @return [Hash] A hash where keys are claim property IDs and values
  #   are arrays of claim objects.
  def claims
    @item['claims']
  end

  # Fetches claims for a specific claim ID within the item.
  #
  # @param id [String] The claim property ID.
  # @return [Array, nil] An array of claim objects, or `nil` if no claims exist for the given ID.
  def claim(id)
    claims[id.to_s]
  end

  # Retrieves the first amount from claims for a specified claim ID.
  #
  # @param id [String] The claim property ID.
  # @return [String, nil] A string representing the amount if available; otherwise, `nil`.
  def claim_amount(id)
    claim_amounts(id).first
  end

  # Fetches all amounts from claims for a specified claim ID.
  #
  # @param id [String] The claim property ID.
  # @return [Array<String>] An array of strings representing the amounts associated with the given claim ID. Returns an empty array if no claims are found.
  def claim_amounts(id)
    tmp = claim(id)
    return [] unless tmp

    tmp.map do |value|
      value.dig('mainsnak', 'datavalue', 'value', 'amount')
    end
  end

  # Extracts and returns the date from claims for a specific claim ID, formatted appropriately based on precision.
  #
  # @param id [String] The claim property ID.
  # @return [Time, nil] A `Time` object representing the first valid date found; otherwise, `nil`.
  def claim_date(id)
    tmp = claim(id)
    tmp = tmp&.first&.dig('mainsnak', 'datavalue', 'value', 'time')
    return nil unless tmp

    if tmp.match?(/\+\d{4}-00-00T/)
      Time.strptime(tmp, '+%Y')
    elsif tmp.match?(/\+\d{4}-\d{2}-00T/)
      Time.strptime(tmp, '+%Y-%m')
    else
      Time.strptime(tmp, '+%Y-%m-%d')
    end
  end

  # Fetches the first item identifier (ID) from claims for a specified claim ID.
  #
  # @param id [String] The claim property ID.
  # @return [String, nil] A string representing an item ID if available; otherwise, `nil`.
  def claim_id(id)
    tmp = claim_ids(id)
    return nil unless tmp

    tmp.first
  end

  # Retrieves all item IDs from claims for a specific claim ID.
  #
  # @param id [String] The claim property ID.
  # @return [Array<String>, nil] An array of strings representing the item IDs associated with the given claim ID. Returns `nil` if no claims are found.
  def claim_ids(id)
    tmp = claim(id)
    return nil unless tmp

    tmp.map do |value|
      value.dig('mainsnak', 'datavalue', 'value', 'id')
    end
  end

  # Extracts and returns strings from claims for a specified claim ID, considering monolingual text values.
  #
  # @param id [String] The claim property ID.
  # @return [Array<String>, nil] An array of strings representing the textual data associated with the given claim ID. Returns `nil` if no claims are found.
  def claim_string(id)
    tmp = claim(id)
    return nil unless tmp

    tmp.map do |value|
      if value['mainsnak']['datavalue']['type'] == 'monolingualtext'
        value['mainsnak']['datavalue']['value']['text']
      else
        value['mainsnak']['datavalue']['value']
      end
    end
  end

  # Retrieves all descriptions for the Wikidata item in different languages.
  #
  # @return [Hash] A hash where keys are language codes and values are description texts.
  def descriptions
    @item['descriptions']
  end

  # Returns the unique identifier of the Wikidata item.
  #
  # @return [String] The ID of the Wikidata item.
  def id
    @item['id']
  end

  # Retrieves all labels for the Wikidata item across various languages.
  #
  # @return [Hash] A hash where keys are language codes and values are label strings.
  def labels
    @item['labels']
  end

  # Fetches the label in a specified language, falling back to the default locale if not available.
  #
  # @param lang [String] The language code for the desired label.
  # @return [String, nil] A string representing the label in the requested language or `nil` if unavailable.
  def label(lang)
    tmp = labels[lang]
    tmp ||= labels[I18n.default_locale.to_s]
    tmp ||= labels['mul']
    return unless tmp

    tmp['value']
  end

  # Retrieves all site links associated with the Wikidata item.
  #
  # @return [Hash] A hash where keys are site names and values are site link data.
  def sitelinks
    @item['sitelinks']
  end

  # Searches for Wikidata items based on a query string.
  #
  # @param query [String] The search term.
  # @param limit [Integer] The maximum number of results to return.
  # @return [Array<String>] An array of titles matching the search query.
  def self.search(query, limit)
    url = \
      'https://www.wikidata.org/w/api.php?action=query&list=search&srsearch=' \
      "#{CGI.escape(query)}&srlimit=#{limit}&srprop=size&format=json"
    result = []
    Typhoeus::Config.cache = Cache.new
    response = Typhoeus.get(url)
    if response.success?
      data = JSON.parse(response.body)
      data['query']['search'].each { |x| result.concat([x['title']]) }
    end
    result
  end
end
