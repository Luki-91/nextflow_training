nextflow.enable.dsl = 2

params.url = ""
params.temp = "${launchDir}/downloads"
params.out = "${launchDir}/output"
params.storeDir="${launchDir}/cache"
params.accession="SRR1777174"

process prefetch {
	storeDir params.storeDir
	container "docker://ncbi/sra-tools"
	input:
		val accession
	output:
		path "${accession}"
	"""
	prefetch $accession
	"""
}

workflow {
	prefetch(Channel.from(params.accession))
}