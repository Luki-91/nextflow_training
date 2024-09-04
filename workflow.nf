nextflow.enable.dsl=2

process downloadFile {
	// publishDir: "Some of the things I make are final products"
	publishDir "/root/nextflow_training/nextflow_training/", mode:'copy', overwrite: true
	output:
		path "batch1.fasta" //which of the things I made are important for others?
	"""
	wget https://tinyurl.com/cqbatch1 -O batch1.fasta
	"""
}

process countSequences {
	publishDir "/root/nextflow_training/nextflow_training/", mode:'copy', overwrite: true
	output:
		path "numseqs.txt"
	"""
	grep ">" batch1.fasta | wc -l > numseqs.txt
	"""
}
workflow {
  downloadFile()
  countSequences()
}