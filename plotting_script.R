library(ggplot2)

rawdata <- read.csv('countreport.csv')

rawdata[,1]
sum(rawdata[,2])
rawdata[,3]=rawdata[,2]/sum(rawdata[,2])

ggplot(rawdata, aes(x= X..Dinucleotide, y=V3))+
  geom_bar(stat = "identity")+
  geom_text(aes(label = V3), vjust = 0)+
  ylim(0,0.4)+
  xlab("Dinucleotide")+
  ylab("Nucleotice Fequency")

ggsave("homosapiens.png")
