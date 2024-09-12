nextflow.enable.dsl = 2

params.url = ""
params.temp = "${launchDir}/downloads"
params.out = "${launchDir}/output/"
params.storeDir="${launchDir}/cache"
params.accession="SRR12022081"

process prefetch {
	storeDir params.storeDir
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
	input:
		val accession
	output:
		path "${accession}"
	"""
	prefetch $accession
	"""
}

process fasterqDump {
	storeDir params.storeDir
	container "https://depot.galaxyproject.org/singularity/sra-tools%3A2.11.0--pl5321ha49a11a_3"
	input:
		path infile
	output:
		path "${infile.getSimpleName()}*.fastq"
	"""
	fasterq-dump $infile
	"""
}

process fastQutils {
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/ngsutils%3A0.5.9--py27h9801fc8_5"
	input:
		path infile
	output:
		path "${infile.getSimpleName()}_fastqutils.txt"
	"""
	fastqutils stats $infile > ${infile.getSimpleName()}_fastqutils.txt
	"""
}

process fastQC {
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastqc%3A0.12.1--hdfd78af_0"
	input:
		path infile
	output:
		path "${infile.getSimpleName()}_fastqc.txt"
	"""
	fastqc -t 3 -o $params.out $infile > ${infile.getSimpleName()}_fastqc.txt
	"""
}
	
workflow {
	prefetch(Channel.from(params.accession)) | fasterqDump | flatten | (fastQC & fastQutils)
}