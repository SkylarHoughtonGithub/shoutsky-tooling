#!/usr/bin/env python3
#Started first draft on 6/31/2019 by Skylar Houghton (SWH)

import feedparser

feedparser._HTMLSanitizer.acceptable_elements.update(['iframe'])
key_words = ['keyword1', 'keyword2']

# get the urls we have seen prior
f = open('viewed_urls.txt', 'r')
urls = f.readlines()
urls = [url.rstrip() for url in urls]
f.close()

#Check if in_str contains a keyword from the key_words list
def contains_wanted(in_str):
    for wrd in key_words:
        if wrd.lower() in in_str:
            return True
    return False

#Check if the NIST result has been found before in the viewed_urls file. Helps to remove duplicate entries
def url_is_new(urlstr):
    if urlstr in urls:
        return False
    else:
        return True

#Enumerating vulnerability list
feed = feedparser.parse('https://nvd.nist.gov/feeds/xml/cve/misc/nvd-rss.xml')
for key in feed["entries"]:
    title = key['title']
    url = key['links'][0]['href']
    description  = key['description']

#formats and send to stdout the specified exploit list with useful information
    if contains_wanted(title.lower()) and contains_wanted(description.lower()) and url_is_new(url):
        print('{} - {} - {}\n'.format(title, url, description))

#appends reoccurring rss feeds in the viewed_urls file to combat duplications on future scans
        with open('viewed_urls.txt', 'a') as f:
            f.write('{}\n'.format(title,url))
