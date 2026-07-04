# Filmaro

## Pri la programo

Filmaro estas libera reta aplikaĵo, kiu montras informojn pri filmoj stokataj en Vikidatumoj en home-legebla formo.

## Kiel komenci

1. Elŝutu la fotnokodon

        $ git clone https://github.com/Venca24/filmaro/

2. En komandlinio, instalu la dependaĵojn

        $ bundle install

3. Startigu la aplikaĵon

        $ bundle exec puma

4. Iru al `http://localhost:3000` en via retumilo.

### Per Docker

1. Elŝutu la fotnokodon kiel menciite supre

2. En komandlinio uzu

        $ docker build -t filmaro .

3. Funkciigu la ujon

        $ docker run -d -p 3000:3000 --dns 9.9.9.9 --dns 149.112.112.112 --name filmaro filmaro

4. Iru al `http://localhost:3000` en via retumilo.

## Aliaj notoj

Tiu ĉi programo estis plibonigita dum [Somera Esperanto-Programado](http://sep.ikso.net/) en julio 2019.

## Permesilo

Filmaro estas eldonita sub la permesilo GNU AGPL. Vi povas trovi ĝian plenan tekston en la dosiero `LICENSE`.
