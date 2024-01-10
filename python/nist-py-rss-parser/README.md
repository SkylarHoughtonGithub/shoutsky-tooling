# nist-py-rss-parser
RSS parsing tool for keeping up with security vulnerabilities in the NIST database.

## Interesting Variables
```
key_words: List of key words that will be used to search the NIST RSS feed
```
## How to Use
Install Python3 and dependencies `feedparser`.

run `python rssparser.py` to initiate the script.

When the script runs, it will deposit the urls in the viewed_urls.txt file to keep track of NIST RSS feed results previously obtained. Feel free to clean this file out if the output seems lacking.

The recommendation is to use something like cron to run this every 8 days as this is the frequency the feed is updated.
