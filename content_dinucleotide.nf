nextflow.enable.dsl = 2

params.infile = "split.py"
params.numsfile = "dinucleotides.txt"
params.out = "$projectDir/out"
params.url = "https://gitlab.com/dabrowskiw/cq-examples/-/raw/master/data/dinucleotides/homosapienscontig.fasta?inline=false"
params.species = "not specified"

process downloadGenome {
	publishDir params.out, mode:'copy', overwrite: true
	output:
		path "${params.species}.fasta"
	//downlading the file with the variable params.url
	"""
	wget $params.url -O ${params.species}.fasta
	"""
}

// example process with combined channels as input. This is a solution hint to learn how to work with combined inputs
process copyFiles {
	publishDir params.out
	input:
		tuple val(num), path(tocopy)
	output:
		path "${tocopy}_${num}"
	"""
	cp $tocopy ${tocopy}_${num}
	"""
}

// This process gets two channels combined (tuple) as input (the config file with the dinucleotides and the downloaded fasta file)
// The type of Dinucleotides is saved as the value of the tuple and echoed as the first element in each output .txt file
// then a "," is added (all w/o new lines because of "-n". In the end the Dinucleotide (${dinuc}) is used as the regex for the
// .fasta file ${tocount} where the output is put in new lines, then the number of lines are counted
process countDinucleotides {
	publishDir params.out, mode:'copy', overwrite: true
	input: 
		tuple val(dinuc), path(tocount)
	output: 
		path "${dinuc}_DiNuccounts.txt"
	"""
	echo -n ${dinuc} > ${dinuc}_DiNuccounts.txt
	echo -n ", " >> ${dinuc}_DiNuccounts.txt
	grep -o ${dinuc} ${tocount} | wc -l >> ${dinuc}_DiNuccounts.txt
	"""
}

// The output of countDinucleotides is used as input for this process, where "Dinucleotides and the No. of repeats" is the first line
// and then the specific Dinucleotides and the numbers are appended to the csv file
process countReport {
  publishDir params.out, mode: "copy", overwrite: true
  input:
		path infile 
  output:
    path "${params.species}.csv"
  """
  cat * > counts.csv
  echo "# Dinucleotide, No_repeats" > ${params.species}.csv
  cat counts.csv >> ${params.species}.csv
  """
}

process generateGraph {
  publishDir params.out, mode: "copy", overwrite: true
  input:
    path infile 
  output:
    path "${params.species}.png"
  """
  Rscript ${projectDir}/plotting_script.R ${params.species}.csv ${params.species}.png || true
  """
}

workflow{
	infile_channel = downloadGenome()
	nucl_channel = Channel.fromPath(params.numsfile).splitText().map { it.trim() }
	counted_channel = countDinucleotides(nucl_channel.combine(infile_channel)).collect() 
	generateGraph(countReport(counted_channel)) 
	// numsfile_channel = Channel.fromPath(params.numsfile)
	// numsfile_split = numsfile_channel.splitText().map { it.trim() }
	// combined_channel = infile_channel.combine(numsfile_split)
	// copyFiles(combined_channel)
}