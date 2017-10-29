import cv2
import numpy as np
import os.path
import os
import random

male_input_path = '/home/ubuntu/facereg/malefacedata/'
female_input_path = '/home/ubuntu/facereg/femalefacedata/'
male_output_path = '/home/ubuntu/facereg/mtrimdata/'
female_output_path = '/home/ubuntu/facereg/fmtrimdata/'

faceCascade = cv2.CascadeClassifier('/usr/local/share/OpenCV/haarcascades/haarcascade_frontalface_default.xml')

def facedect(input_path,output_path,mark):

  train_data_path = '/home/ubuntu/facereg/data.txt'
  test_data_path = '/home/ubuntu/facereg/tdata.txt'

  with open(train_data_path,"a") as f, open(test_data_path,"a") as g:


      image_num = sum([len(x) for _, _, x in os.walk(os.path.dirname(input_path))])

      print image_num

      face_dec_num = 0

      for i in range(image_num):
        print(input_path+("%06d") % i+'.jpg')
        if os.path.isfile(input_path+("%06d") % i+'.jpg'):
          try:
              img = cv2.imread(input_path+("%06d") % i+'.jpg',1)
              gray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
              faces = faceCascade.detectMultiScale(gray, 1.3, 5)

              if len(faces) ==1:
                #print len(faces)
                for face in faces:

                  x,y,w,h = face



                  face_dec_num= face_dec_num+1

                  print("normal")

                  ran = random.randint(0,9)
                  print(ran)
                  if ran< 8:

                    tempimg = cv2.resize(img[y:y+h, x:x+w],(299,299),interpolation = cv2.INTER_CUBIC)
                    cv2.imwrite(output_path + ("%06d") % face_dec_num+'.jpg', tempimg)

                    f.write(output_path + ("%06d") % face_dec_num+'.jpg '+mark+'\n')
                    print("written")
                  else:
                    g.write(output_path + ("%06d") % face_dec_num+'.jpg '+mark+'\n')
                    print("done")

              else:
                print("No face")

          except :
            print(Exception.message)

        else:
          print ("No File")
  count1 = len(open(train_data_path,'rU').readlines())
  print(count1)
  print(len(open(test_data_path,'rU').readlines()))
  return


facedect(male_input_path,male_output_path,"0")
facedect(female_input_path,female_output_path,"1")
