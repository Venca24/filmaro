# Filmaro

## About

Filmaro is a free software web application which shows information about films stored in Wikidata in human readable form.

## Getting started

1. Download the source code

        $ git clone https://github.com/Venca24/filmaro/

2. In the command line, install the dependencies

        $ bundle install

3. Run the application

        $ bundle exec puma

4. Go to `http://localhost:3000` in your browser.

### With Docker

1. Download the source code as above

2. In the command line, run

        $ docker build -t filmaro .

3. Run the container

        $ docker run -d -p 3000:3000 --dns 9.9.9.9 --dns 149.112.112.112 --name filmaro filmaro

4. Go to `http://localhost:3000` in your browser.

## Other notes

This program was enhanced during [Somera Esperanto-Programado](http://sep.ikso.net/) hackathon in July 2019.

## License

Filmaro is released under GNU AGPL license. You can find its full text in the `LICENSE` file.
