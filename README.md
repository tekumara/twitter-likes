# twitter-likes

Download your twitter likes into a gdbm database using https://gist.github.com/datagrok/74a71f572493e603919e

## prereqs

Update creds.py and run `make venv`

To download favs: `make fetch`
To extract favs from the gdbm database: `make dump`

NB: because of the way the timestamps work, every now and then you'll probably want to re-download everything. See comments in [get_favs.py](get_favs.py)
