nextflow.enable.dsl = 2

params.url = ""
params.temp = "${launchDir}/downloads"
params.out = "${launchDir}/output"
params.storeDir="${launchDir}/cache"
params.accession="SRR12598797"
params.with_fastqc = false
params.with_stats = false


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
	when:
	params.with_stats
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
		path "${infile.getSimpleName()}_fastqc"
	when:
	params.with_fastqc
	"""
	mkdir ${infile.getSimpleName()}_fastqc
	fastqc -o ${infile.getSimpleName()}_fastqc $infile
	"""
}

process fastP {
	publishDir params.out, mode: "copy", overwrite: true
	container "https://depot.galaxyproject.org/singularity/fastp%3A0.23.4--hadf994f_3"
	input:
		path infile
	output:
		path "${infile.getSimpleName()}_trimmed.fastq"
	when:
	params.with_fastp
	"""
	fastp -i $infile -o ${infile.getSimpleName()}_trimmed.fastq -5
	"""
}
	// after flatten brackets are needed
workflow {
	// this way of writing the workflow shows a better performance since FastQC can run before FastP has started
	prefetch_channel = prefetch(Channel.from(params.accession))
	fasterq_channel = fasterqDump(prefetch_channel).flatten() 
	fastP_channel = fastP(fasterq_channel)
	QC_channel = fasterq_channel.concat(fastP_channel)
	fastQC(QC_channel)
	fastQutils(fasterq_channel)
	// in this way FastQC needs to wait for FastP to finish so the whole process is slower
//	fasterq_channel = Channel.from(params.accession) | prefetch | fasterqDump | flatten	
//	fastP(fasterq_channel) | concat(fasterq_channel) | fastQC
}