# Machine Learning and Content Analytics
*Course on Machine Learning and Content Analytics, MSc. in Business Analytics, AUEB*
*Year 2021-2022*

*Professor Haris Papageorgiou*
*Assistant Professor George Perakis*

Students Involved

- Athanasiou Antonis, P2822102
- Atzami Stavroula, P2822105
- Gkourioti Panagiota, P2822109
- Koletsi Thaleia, P2822120

## Main Project Repository

### Main Idea

Classify supermarket products given an image using Machine Learning methods.

### Model Weights

Models weights to load and test the model are available at google drive due to size constrains

https://drive.google.com/drive/folders/13cbnvyiROgYsynWK98OMYu13XHbVIYoK?usp=sharing

### File Explanation

**Model_Building.ipynb**

Main script for training our models.
The script reads our photo data in the form of .npz (compressed numpy array) which is located inside google drive.
The script is also responsible for splitting our X and Y data into train and test dataset respectively.

Trains a Convolutional Neural Network, a VGG16, a RESNET50 and an InceptionV3 network and exports training and test performance information.

The notebook is run Google Colab only due to the amount of memory  and computing power required to train the models

**photo_renamer.py**

Main script we used to rename our photos which were taken using our smartphones. It renames all the ".jpg" files inside the current working directory in which the script is run to a format {class_name}_{photo_id}_{file_format}.

The "class_name" is taken by folder name in which the photo is placed, thereby assuming that all photos are placed inside properly named folders. For example, "AMSTEL MPIRA 330ML" photos must be placed in a folder named as such.

Photo id is just a dummy id given to each photo.

This naming convention is necessary for reading images and assigning appropriate target labels.

**read_images.ipynb**

Notebook responsible for reading iteratively the images from drive and creating the respective numpy array containing the photos.
Saves the numpy array into a ".npz" file.

Run in Google Colab only.

**compress_images.py**

Script responsible for compressing the images before uploading to google drive. Necessary for uploading images to google drive in a reasonable amount of time

**augmentation-script.py**

Script used image augmentation (did not make it into the final dataset).
It takes as input one image and produces 20 different variations of the same photo.
