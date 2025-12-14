# Kiel kontribui

La celo de tiu ĉi projekto estas provizi liberan fasadon al la datumbazo de Vikidatumoj por provizi al siaj uzantoj informojn pri filmoj en maniero simila al tiu de aliaj filmaj datumbazoj.

Vi estas bonvena kontribui al tiu ĉi projekto. Vi povas skribi pri problemo (issue) aŭ krei tirpeton (pull request).

## Ŝlosilaj postuloj por tiu ĉi projekto
* Devas esti eble disponigi, funkciigi kaj uzi tiun ĉi programon uzante nur liberan programaron kiel [difinita de Free Software Foundation](https://www.gnu.org/philosophy/free-sw.en.html).
* La kernaj funkcioj devas funkcii ankaŭ sen uzo de ĜavoSkripto (JavaScript) je le klienta flanko. Tio ne malebligas uzi ĜavoSkripton por aldonaj (ne kernaj) funkcioj kaj por stiligado.
* La ĉefa framo estas Sinatra kaj la ĉefa testoframo estas RSpec.
* La kodo devus esti tenata tiom facila kaj pura kiom eblas.

### Kiel aldoni novan lingvon
Antaŭ aldono de nova lingvo certiĝu, ke:
* la lingvo havas lingvokodon ISO 639-1 aŭ ISO 639-2
* la lingvo estas subtenata ĉe Vikidatumoj kaj havas pli ol 4 000 000 da eroj (vidu [Language statistics for items](https://www.wikidata.org/wiki/User:Mr._Ibrahem/Language_statistics_for_items) for example)
  * tiu ĉi nombro estas pli-malpli arbitra por certigi, ke estas granda verŝajneco trovi filmojn kun nomo en tiu lingvo per Vikidatumoj kaj tiu nombro estas malferma por diskuto

Post kiam vi certiĝis, ke la supre menciitaj kondiĉoj estas validaj, simple kopiu dosieron en la dosierujo `locales` kaj nomigu ĝin per la lingvokodo, kiu Vikidatumoj uzas por la celata lingvo. Poste traduku la ĉenojn. Specialajn paĝojn traduku rekte en iliaj ERB-ŝablonoj en la dosierujo `views`.
