import Image

def format_table():
	im = Image.open('aux.jpeg')
	width, height = im.size
	print(width,height)
	cr_im = im.crop((300,250,width-300,height-1300))
	cr_im.save('aux.png')

if __name__=='__main__':
	format_table()
