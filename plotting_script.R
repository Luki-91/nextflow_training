library(ggplot2)
args = commandArgs(trailingOnly=TRUE)

rawdata <- read.csv(args[1])

rawdata[,1]
sum(rawdata[,2])
rawdata[,3]=rawdata[,2]/sum(rawdata[,2])

ggplot(rawdata, aes(x= X..Dinucleotide, y=V3))+
  geom_bar(stat = "identity")+
  ylim(0,0.1)+
  xlab("Dinucleotide")+
  ylab("Nucleotice Fequency")

ggsave(args[2])
