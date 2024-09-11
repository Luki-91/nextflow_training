nextflow.enable.dsl = 2

params.url = ""
params.temp = "${launchDir}/downloads"
params.out = "${launchDir}/output"
params.storeDir="${launchDir}/cache"

process prefetch {
	storeDir params.storeDir
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