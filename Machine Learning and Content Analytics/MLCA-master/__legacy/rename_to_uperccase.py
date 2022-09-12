"""
This script renames all ".jpg" files to ".JPG" files (uppercase extension) 
"""

import os
import glob


def change_to_underscoreJPG(path:str) -> str:
	"""
	Change string from .jpg to "_.JPG". A change of name (appart from
	changing case) needs to happen because os.rename does not
	work when directly changing from lowercase to uppercase. Hence we add
	and underscore
	"""
	return path.replace(".jpg","_.JPG")


def change_to_normalJPG(path: str) -> str:
	"""
	Revert back to normal uppercase extension
	"""
	return path.replace("_.JPG", ".JPG")


def change_to_lowercasejpg(path: str) -> str:
	return path.replace("jpg",".jpg")


def main() -> None:

	file_paths = glob.glob("**/*jpg", recursive = True)
	cur_dir = os.getcwd()

	for file in file_paths:
		old_file = os.path.join(cur_dir,file)
		new_file = os.path.join(cur_dir, change_to_lowercasejpg(file))

		os.rename(old_file,new_file)

if __name__ == "__main__":
	
	main()	