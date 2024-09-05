nextflow.enable.dsl=2

params.out = "${launchDir}/output"
// params.out = "${launchDir}/output": "putting the output in a dedicated folder"

process downloadFile {
	// publishDir: "Some of the things I make are final products"
	publishDir params.out, mode:'copy', overwrite: true
	output:
		path "batch1.fasta" //which of the things I made are important for others?
	"""
	wget https://tinyurl.com/cqbatch1 -O batch1.fasta
	"""
}

process splitSequences{
	publishDir params.out, mode:'copy', overwrite: true
	input: // where does the worker before me put the things?
		path infile
	output:
		path "split_*"
		
	// splitting the file ${infile} into .fasta files 
	// having 2 lines (-l 2) with the name split_number (-d -a 1)
	"""
	split -l 2 -d -a 1 --additional-suffix=.fasta ${infile} split_
	"""
}

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
  downloadFile | splitSequences // |: Connecting processes with matching inputs/outputs
}