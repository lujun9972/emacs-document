import sys
import datetime
import json
from newspaper import Article
url = sys.argv[1]

article = Article(url, keep_article_html=True, memoize_articles=False, follow_meta_refresh=True, request_timeout=15, fetch_images=False)
article.download()
article.parse()

authors = ';'.join(article.authors)
title = article.title
date = article.publish_date
if date:
    date = date.strftime('%Y%m%d')

html_content = article.article_html
content = article.text

data = {"title": title,
        "date_published": date,
        "content": html_content,
        "author": authors}

print(json.dumps(data))
