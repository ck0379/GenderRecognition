
import os
import shutil


for (dirpath, dirnames, filenames) in os.walk("/Users/zhen/Desktop/project_images"):
    for filename in filenames:
        if not filename.endswith('.jpg'):
            print(filename)
            os.remove(dirpath + '/' + filename)
    for dirname in dirnames:
        if dirname.startswith('0'):
            shutil.rmtree(dirpath + '/' + dirname)
