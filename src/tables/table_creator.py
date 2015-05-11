import sys

def table_creator():

	tex_file = open('aux.tex','w')
	tsv_file = open(sys.stdin.read().rstrip('\n'),'r')
	lines = tsv_file.readlines()
	first_line= lines[0].rstrip('\n').split('\t')

	tex_file.write('\documentclass[11pt]{article}\n\usepackage[table]{xcolor}\n\definecolor{lightblue}{rgb}{0.93,0.95,1.0}\n\\begin{document}\n\\begin{table}[ht]\n\Huge\n\centering\n\\rowcolors{1}{}{lightblue}\n\\begin{tabular}{r|')
	for word in first_line:
		tex_file.write('l')
	tex_file.write('}\n')
	for line in lines:
		info = line.rstrip('\n').split('\t')
		tex_file.write(info[0])
		info.pop(0)
		for word in info:
			tex_file.write('&'+word)
		tex_file.write('\\\\\n')
	tex_file.write('\end{tabular}\n\end{table}\n\end{document}')
	tex_file.close()


if __name__=='__main__':
	table_creator()
