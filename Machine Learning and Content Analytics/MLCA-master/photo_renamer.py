'''
This module contains the basic classes that will transform the
data into usable format for the neural netowork to be trained
'''

import os
import glob
from typing import List
import random
import string


def path_extractor(path: str, path_seperator: str = "/") -> str:
	"""
	Takes a Path as input and removes the last part,
	e.g. /home/media/example.jpg -> /home/media
	"""
	return path_seperator.join(path.split(path_seperator)[:-1])

def full_path(path: str) -> str:
	"""
	Returns the full (absolute path). Expects as input a relative path
	"""
	cwd = os.getcwd()
	return os.path.join(cwd,path)

def id_generator() -> str:
	"""Generates an photo ID"""
	return "".join(random.choices(string.ascii_letters, k = 10))

def new_image_name(path: str, class_name: str, file_format: str = ".jpg") -> str:
	"""
	The function takes the relative path of a file and returns a new path
	with the file renamed as "{class_name}_{photo_id}_{file_format}"
	"""
	
	photo_path = path_extractor(path)
	photo_path = full_path(photo_path)
	photo_id = id_generator()
	new_name = class_name+"_"+photo_id+file_format
	return os.path.join(photo_path,new_name)

class photoRenamer(object):
	"""
	This Class takes photo file paths which are inside folders.
	The folder name depicts label that the image represents.
	With the .rename method, the images are renamed to
	{class_name}_{photo_id}_{file_format} 
	"""

	def __init__(self, photo_paths: List[str]):
		self.photos = photo_paths
		

	def get_class_names_from_folders(self, path_seperator: str = "/") -> List[str]:
		"""
		This method assumes that photo class names are
		located in the name of the folder. The returned List
		has equal length to the self.photo List.
		"""
		self.classes = [path.split(path_seperator)[-2] for path in self.photos]
	

	def rename_photos(self):
		for old_image_name,class_name in zip(self.photos,self.classes):

			image_name_new = new_image_name(old_image_name,class_name)
			os.rename(old_image_name,image_name_new)
			

if __name__ == "__main__":


	file_paths = glob.glob("**/*.jpg",recursive = True)
	renamer = photoRenamer(file_paths)
	renamer.get_class_names_from_folders() # Get Classes from Folders
	renamer.rename_photos()
	file_paths_after = glob.glob("**/*.jpg",recursive = True)
	print(f"Number of jpg images before {len(file_paths)}")
	print(f"Number of jpg images after renaming {len(file_paths_after)}")
	print(f"Difference of {len(file_paths)-len(file_paths_after)}")
