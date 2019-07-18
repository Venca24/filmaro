require 'json'
require 'typhoeus'

class Cache
  def initialize
    @memory = {}
  end

  def get(request)
    @memory[request]
  end

  def set(request, response)
    @memory[request] = response
  end
end

class WikidataFetcher
  class << self
    def get_labels(id, lang)
      url = 'https://www.wikidata.org/w/api.php?action=wbgetentities&ids=' +
            id + '&languages=' + lang + '&props=labels&format=json'
      Typhoeus::Config.cache ||= Cache.new
      data = Typhoeus.get(url).body
      item = JSON.parse(data)
      (item['entities'][id]['labels'] unless item['entities'].nil?)
    end

    def get_item(id)
      url = 'https://www.wikidata.org/wiki/Special:EntityData/' + id + '.json'
      Typhoeus::Config.cache ||= Cache.new
      data = Typhoeus.get(url).body
      item = JSON.parse(data)
      item['entities'][id]
    end
  end
end
