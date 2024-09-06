nextflow.enable.dsl = 2

params.infile = "split.py"
params.numsfile = "dinucleotides.txt"

process copyFiles {
	publishDir projectDir
	input:
		tuple path(tocopy), val(num)
	output:
		path "$tocopy_${num}"
	"""
	cp $tocopy ${tocopy}_${num}
	#cat * > count.csv
	#echo "# Sequence number, repeats" > finalcount.csv
	#cat count.csv >> finalcount.csv
	"""
}

workflow{
	infile_channel = Channel.fromPath(params.infile)
	numsfile_channel = Channel.fromPath(params.numsfile)
	numsfile_split = numsfile_channel.splitText().map { it.trim() }
	combined_channel = infile_channel.combine(numsfile_split)
	copyFiles(combined_channel)
//	Channel.fromPath(params.numsfile) | splitText | map { it.trim() } | copyFiles
}