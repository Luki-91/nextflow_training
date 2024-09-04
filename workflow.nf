nextflow.enable.dsl=2

params.temp = "${baseDir}/downloads"
process downloadFile {
	// publishDir: "Some of the things I make are final products"
	publishDir params.temp, mode:'copy', overwrite: true
	output:
		path "batch1.fasta" //which of the things I made are important for others?
	"""
	wget https://tinyurl.com/cqbatch1 -O batch1.fasta
	"""
}

// params.out = baseDir: "Making the base directory a variable"

process countSequences {
	publishDir params.out, mode:'copy', overwrite: true
	input: // where does the worker before me put the things?
		path infile
	output: // What do I make out of what they give me?
		path "numseqs.txt"
	""" # What do I do every time I get something from the worker before me?
	grep ">" ${infile} | wc -l > numseqs.txt
	"""
}
workflow {
  downloadFile() | countSequences() // |: Connecting processes with matching inputs/outputs
  
}