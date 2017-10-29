

import matplotlib.pyplot as plt
import tensorflow as tf

def decodeJPEG(rawData):
    return tf.image.decode_jpeg(rawData)

def encodeJPEG(imgData):
    return tf.image.encode_jpeg(imgData)

def stretchImage(imgData, sizeX = 300, sizeY = 300, method = 0):

    return tf.image.resize_images(imgData, [sizeX, sizeY], method = method)

def cutOrPadImage(imgData, sizeX = 300, sizeY = 300):
    return tf.image.resize_image_with_crop_or_pad(imgData, sizeX, sizeY)

def centralCropImage(imgData, percentage = 0.8):
    # percentage : (0,1] real number
    return tf.image.central_crop(imgData, percentage)


def adjustBrightOfImage(imgData):
    # tf.image.adjust_brightness(imgData, 0.5)
    return tf.image.random_brightness(imgData, 0.5)

def adjustContrastOfImage(imgData):
    return tf.image.random_contrast(imgData, 0, 5)

def adjustHueOfImage(imgData):
    return tf.image.random_hue(imgData, 0.5)

def adjustSaturationOfImage(imgData):
    return tf.image.random_saturation(imgData, 0, 5)

def standardizationImage(imgData):
    return tf.image.per_image_standardization(imgData)

if __name__ == '__main__':
    IMAGE_PATH = input('enter your image path: ')[:-1]
    rawImage = tf.gfile.FastGFile(IMAGE_PATH, 'r').read()
    with tf.Session() as sess:
        imgData = decodeJPEG(rawImage)
        imgData = tf.image.convert_image_dtype(imgData, dtype = tf.float32)

        resizedImg = standardizationImage(imgData)

        print(resizedImg.get_shape())
        plt.imshow(resizedImg.eval())
        plt.show()
