# How to contribute

The goal of this project is to provide a free/libre frontend to the Wikidata database to provide its users information about films in a way similar to the other film databases.

You are open to contribute to this project. You can fill an issue or create a pull request.

## Key requirements for this project
* It must be possible to deploy, run and use this program using free/libre software only as [defined by Free Software Foundation](https://www.gnu.org/philosophy/free-sw.en.html).
* The core functionality must work without using JavaScript at client's side. This doesn't rule out the possibility to use JavaScript for additional (not core) functionalities and styling.
* The main framework is Sinatra and the main testing framework is RSpec.
* The code should be kept as simple and clean as possible.

### How to add a new language
Before adding new language make sure that:
* the language has got ISO 639-1 or ISO 639-2 language code
* the language is supported on Wikidata and has got more than 4.000.000 labels (see [Language statistics for items](https://www.wikidata.org/wiki/User:Mr._Ibrahem/Language_statistics_for_items) for example)
  * this amount is more or less arbitrary to make sure there is high probability to find films with names in that language via Wikidata and it is open to discussion

After you are sure the above mentioned conditions are met just copy a file in the `locales` folder and name it with the language code which Wikidata uses for that language. Then translate the strings. Special pages translate directly in their ERB templates in the `views` folder.
