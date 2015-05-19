while read LINE; do
	echo ${LINE}|python table_creator.py
	pdflatex 'aux.tex'
	sips -s format jpeg aux.pdf --out aux.jpeg
	python format_table.py
	NAME=$(echo ${LINE}|rev|cut -c 5-|rev)
	mv "aux.png" "${NAME}.png"
	rm aux*	
done
exit 0
