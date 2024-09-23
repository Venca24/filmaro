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

require 'active_support/core_ext/hash'
require 'i18n'
require 'rack/protection'
require 'yaml'

require './app'

# config
config = YAML.load(
  File.read(File.join(File.dirname(__FILE__), 'config', 'config.yml'))
)
config.each do |key, value|
  Object.const_set(key, value.deep_symbolize_keys)
end

# XSS input protection
use Rack::Protection::EscapedParams

# Internationalization
locale_path = File.join(File.dirname(__FILE__), 'locales', '*.yml').to_s
I18n.load_path += Dir[locale_path]
I18n.config.available_locales = LANGS[:available_locales].keys
I18n.default_locale = LANGS[:default_locale]

run Sinatra::Application
