#!/usr/bin/python3 -u
"""
Copyright 2015 Michael F. Lamb <http://datagrok.org>
License: AGPLv3+

ugly one-off script that uses tweepy to dump all favorites (aka "likes")
into a dbm database file and json text file, because the twitter-provided data export does
not include them, because their users are not their customers, instead
they are the product they sell to advertisers.

re-running it will update the existing database file.

warning warning: this script doesn't use since_id and max_id parameters in
an attempt to retrieve only favs unseen since the last run, because
sequential ids are not assigned to favs, they're assigned to the
original statuses. this means that if you fav a status that is older
than your most recently fav'd status, we won't notice it!

warning: the twitter api docs caution that "there are limits to the
number of tweets which can be accessed through the API." sooo if you're
a longtime twitter user, maybe some of your favs might be completely
irrecoverable? i dunno.  🔥 the max number of likes I've been able to
retrieve at a time is 3170. 🔥

to use, create an "application" at apps.twitter.com. put the credentials
it gives you into a creds.py file:

username = "datagrok"
consumer_key = "..."
consumer_secret = "..."
access_token = "..."
access_token_secret = "..."

TODO: abstract the storage mechanism to easily swap out dbm for
maildir-like structure, nosql database, whatever

TODO: retrieve all related tweets (in_reply_to_status_id,
quoted_status_id)

TODO: build a local database of tweets from twitter's export and various
retrieval scripts like this one, with local copies of all tweets
necessary to reconstruct conversations I've faved, rt'd, or participated
in.

"""
import tweepy
import dbm
import json
import time

import creds  # you must create creds.py


def get_api():
    auth = tweepy.OAuthHandler(creds.consumer_key, creds.consumer_secret)
    auth.set_access_token(creds.access_token, creds.access_token_secret)
    return tweepy.API(auth, wait_on_rate_limit=True, wait_on_rate_limit_notify=True)


def main():
    api = get_api()
    count = 0
    with dbm.open('favs.db', 'c') as db, open('favs.ndjson', 'at', buffering=1) as jsonfile:
        for status in tweepy.Cursor(api.favorites, creds.username,
                                    count=200, include_entities=True, tweet_mode='extended').items():
            count = count + 1
            print(count)
            status_id = str(status.id)
            status_json = json.dumps(status._json)
            if status_id not in db:
                db[status_id] = status_json
                jsonfile.write(status_json + "\n")
            else:
                print(status_id + " exists in db")

            # twitter rate-limits us to 15 requests / 15 minutes, so
            # space this out a bit to avoid a super-long sleep at the
            # end which could lose the connection.
            time.sleep(60 * 15 / (15 * 200))
        print('Done.')


if __name__ == '__main__':
    main()
