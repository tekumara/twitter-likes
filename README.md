# twitter-likes

Download your twitter likes using an enhanced version of https://gist.github.com/datagrok/74a71f572493e603919e

## prereqs

* Install python 3
* Install gdbm: `brew install gdbm`
* Create an application at [apps.twitter.com](https://apps.twitter.com)
* Create `creds.py` with the following from your application

```
username = "datagrok"
consumer_key = "..."
consumer_secret = "..."
access_token = "..."
access_token_secret = "..."
```

* `make venv` to create the virtual env

## commands

`make fetch` downloads favs to favs.db and favs.ndjson  
`make dump` extract favs from favs.db to stdout  
`make` to show all options
