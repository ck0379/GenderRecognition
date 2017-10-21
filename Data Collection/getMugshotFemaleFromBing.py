#Download images from google

from icrawler.builtin import GoogleImageCrawler
from icrawler.builtin import BingImageCrawler
import sys
import os


image_path = sys.argv[1]
imageDir = image_path + '/' + "bingMugshotFemale1"

try:
    os.stat(imageDir)
except:
    os.mkdir(imageDir)
"""google_crawler = GoogleImageCrawler(parser_threads=2, downloader_threads=4,
                                    storage={'root_dir' : imageDir})
google_crawler.crawl(keyword= "mugshot female", max_num=1000,
                     date_min=None, date_max=None,
                     min_size=(200,200), max_size=None)
"""
bing_crawler = BingImageCrawler(parser_threads=2, downloader_threads=4,
                                    storage={'root_dir' : imageDir})
bing_crawler.crawl(keyword= "mugshot female", max_num=1000,
                     min_size=(200,200), max_size=None)