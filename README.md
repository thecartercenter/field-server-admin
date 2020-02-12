# Field Server Panel

## Dependencies

* [Borg backup](https://borgbackup.readthedocs.io)

## Development

Get a USB stick and format and mount it. Need not be big. This is your backup partition.

Make a source directory either in the project directory at `/source` (recommended for development, that folder is gitignored) or elsewhere. Put some random files in it.

Grant passwordless sudo access for the ngrok wrapper script, e.g.

    deploy ALL=(ALL) NOPASSWD: /path/to/field-server-panel/scripts/runngrok

Setup config with:

    cp config.yml.example config.yml

and edit to replace placeholders.

Run

    ruby app.rb

and visit http://localhost:4567/

## Production

Similar to above, but setup Passenger or other app server to serve Rack app.
