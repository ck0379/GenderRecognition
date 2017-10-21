#Download images from google

from icrawler.builtin import GoogleImageCrawler
import sys
import os


image_path = sys.argv[1]
imageDir = image_path + '/' + "googleFaceFemale"

try:
    os.stat(imageDir)
except:
    os.mkdir(imageDir)
google_crawler = GoogleImageCrawler(parser_threads=2, downloader_threads=4,
                                    storage={'root_dir' : imageDir})
google_crawler.crawl(keyword= "asian female face", max_num=3000,
                     date_min=None, date_max=None,
                     min_size=(200,200), max_size=None)