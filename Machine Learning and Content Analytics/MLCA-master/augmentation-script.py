# -*- coding: utf-8 -*-
"""
Created on Wed Aug 24 20:30:46 2022

@author: stavr
"""

import tensorflow as tf
import keras

tf.__version__
keras.__version__


from keras.preprocessing.image import ImageDataGenerator
from skimage import io

datagen = ImageDataGenerator(
rotation_range=30,
	zoom_range=0.15,
	width_shift_range=0.2,
	height_shift_range=0.2,
	shear_range=0.15,
	horizontal_flip=True,
	fill_mode="nearest"
  )  
    
x=io.imread('OneDrive\Desktop\Images_Stav\OLYMPOS ZWIS PLIRES 3,7%\IMG_1636.JPG')

x = x.reshape((1,) + x.shape)

i=0
for batch in datagen.flow(x, batch_size=1,

                          save_to_dir='OneDrive\Desktop\Images_Stav\OLYMPOS ZWIS PLIRES 3,7%',
                          save_prefix='aug',
                          save_format='JPG'):
    
    i +=1
    if i > 20:
        break