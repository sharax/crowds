import os
import Image

images = os.listdir(os.getcwd()+'/assets')
for image in images:
	if image[0]!='.':
		ext = image[-4:]
		if ext != '.png':
			im = Image.open(os.getcwd()+'/assets/'+image)
			im.save(os.getcwd()+'/assets/'+image[:-4]+'.png')


