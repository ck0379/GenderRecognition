#coding:utf-8
import flickrapi
import urllib
import sys

image = urllib.request.URLopener()
api_key = '768bce603275819ca6fef0e00619539f'
api_secret = '005f57dd3039df82'
flickr=flickrapi.FlickrAPI(api_key,api_secret,cache=True)
image_path = sys.argv[1]
imageDir = image_path + '/' + "male_face"

try:
    os.stat(imageDir)
except:
    os.mkdir(imageDir)

try:
    photos=flickr.walk(text='male face',extras='url_c')
except Exception as e:
    print('Error')
count = 0
for photo in photos:
    url=photo.get('url_c')
    print(imageDir + "/" + str(count)+".jpg")
    try:
        image.retrieve(url,imageDir + "/" + str(count)+".jpg")
    except Exception as e:
        print('Error, cannot download!')
    count= count+1
    #print(str(url))