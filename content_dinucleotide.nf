nextflow.enable.dsl = 2

params.infile = "split.py"
params.numsfile = "dinucleotides.txt"
params.out = "$projectDir/out"

process copyFiles {
	publishDir projectDir
	input:
		tuple val(num), path(tocopy)
	output:
		path "${tocopy}_${num}"
	"""
	cp $tocopy ${tocopy}_${num}
	"""
}

workflow{
	infile_channel = Channel.fromPath(params.infile)
	Channel.fromPath(params.numsfile) | splitText | map { it.trim() } | combine(infile_channel) | copyFiles
	// numsfile_channel = Channel.fromPath(params.numsfile)
	// numsfile_split = numsfile_channel.splitText().map { it.trim() }
	// combined_channel = infile_channel.combine(numsfile_split)
	// copyFiles(combined_channel)
}