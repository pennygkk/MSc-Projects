"""
The script compresses image files
"""


import os
import glob
from tqdm import tqdm
from pathlib import Path
from PIL import Image, ImageOps
from typing import List

def merge_lists(list1: List[str], list2: List[str]) -> List:
    return list1 + list2


def path_extractor(path: str, path_seperator: str = "/") -> str:
    """
    Takes a Path as input and removes the last part,
    e.g. /home/media/example.jpg -> /home/media
    """
    return path_seperator.join(path.split(path_seperator)[:-1])


def full_path(path: str) -> str:
	""" Returns the absolute path when fed a relative path"""
	cwd = os.getcwd()
	return os.path.join(cwd,path)


def createDirectory(path: str) -> None:
    """Creates the path RECURSIVELY if it does not exist"""
    if not os.path.isdir(path):
        os.makedirs(path)


def deleteExifTags(image: Image) -> None:
    """Deletes all tags except the one that rotates the image when saved"""
    exif = image.getexif()
    # Remove all exif tags
    for k in exif.keys():
        if k != 0x0112:
            exif[k] = None # If I don't set it to None first (or print it) the del fails for some reason.
            del exif[k]
    # Put the new exif object in the original image
    new_exif = exif.tobytes()
    image.info["exif"] = new_exif


def compressPicture(filepath: str, output_folder:str = "compressed", quality: int = 25) -> None:
    """ The function reads the image and saves it the compressed version into the output_folder parameter"""
    def readPicture(filepath:str) -> Image:
        """Function that reads an image prodived the path for that Image"""
        picture = Image.open(full_path(filepath))
        deleteExifTags(picture)
        picture = ImageOps.exif_transpose(picture) # Necessary for the image not be rotated
        return picture

    picture = readPicture(filepath)

    cwd = os.getcwd()
    image_path = os.path.join(cwd,output_folder,filepath) # Actual image path into the compressed folder directory
    output_path = path_extractor(image_path) # Creates the compressed folder directory


    createDirectory(output_path)

    picture.save(image_path, quality = quality, format = "JPEG")

def main() -> None:

    images_antonis = glob.glob("Images_Antonis/**/*.jpg", recursive = True)
    images_stav = glob.glob("Images_Stav/**/*.jpg", recursive = True)
    images = merge_lists(images_antonis, images_stav)

    for image in tqdm(images):
        compressPicture(image)

if __name__ == "__main__":
    main()
