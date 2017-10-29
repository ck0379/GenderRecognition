from icrawler.builtin import GoogleImageCrawler


def craw(path,keywords):

    google_crawler = GoogleImageCrawler(parser_threads=2, downloader_threads=4,
                                    storage={'root_dir': path})
    google_crawler.crawl(keyword= keywords, max_num=100000,
                     date_min=None, date_max=None,
                     min_size=(150,150), max_size=None)

craw('malefacedata',"man male face")
craw('femalefacedata',"woman female face")