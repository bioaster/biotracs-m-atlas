library(VennDiagram)
# Code to pass arguments in a shell
library("optparse")

option_list = list(
  make_option(c("-i", "--InputFile"), type="character", 
              help="Input File to plot the venn diagram", metavar="character"),
  make_option(c("-n", "--ConditionsNumber"), type="numeric", default=2, 
              help="The number of the conditions to compare", metavar="numeric"),
  make_option(c("-m", "--ConditionsNames"), type="character",  
              help="Name of the conditions to compare", metavar="character"),
  make_option(c("-o", "--OutputFileName"), type="character", 
              help="Name of the output file", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);


inputFile = opt$InputFile
n = opt$ConditionsNumber
outputFileName = opt$OutputFileName
print(paste('Input File is ',  inputFile))
print(paste('OutputFileName is ',  outputFileName))

x= read.csv(inputFile, header=TRUE, sep="\t",na.strings=c("","NA"))

conditionsNames <- strsplit(opt$ConditionsNames, ",")
pngOutputFileName <-  gsub( 'csv', 'png', outputFileName)
  # strsplit(basename(outputFileName), '[.]')

cN = conditionsNames[[1]]
print(paste('Conditions Names are ',  cN))

print(paste('coucou', pngOutputFileName))
if (n == 2){
  data = list( x[,1],  x[,2])
  names(data) <- c(cN[1], cN[2])
  venn.diagram(data, filename =pngOutputFileName, na="remove")
  o <- calculate.overlap(x=list('h'= x[,1],'h2'=x[,2]))
  df = data.frame(lapply(o, "length<-", max(lengths(o))))
  colnames(df) <- c(paste("All",cN[1], sep='_') , paste("All",cN[2], sep='_'), "12")
  write.table(df, paste(outputFileName, sep=''), sep ="\t", col.names =NA , quote = FALSE)
}
if (n == 3){
  data = list( x[,1],  x[,2], x[,3])
  names(data) <- c(cN[1], cN[2], cN[3])
  venn.diagram(data, filename = pngOutputFileName, na="remove")
  o <- calculate.overlap(x=list('h'= x[,1],'h2'=x[,2],'h3'=x[,3]))
  df = data.frame(lapply(o, "length<-", max(lengths(o))))
  colnames(df) <- c("All", "12", "13", "23", paste("1_",cN[1], sep='_'),paste("2_", cN[2], sep='_'),paste("3_",cN[3], sep='_'))
  write.table(df,  paste(outputFileName, sep=''), sep ="\t", col.names =NA , quote = FALSE)
}
if (n== 4){
  data = list( x[,1],  x[,2], x[,3], x[,4])
  names(data) <- c(cN[1], cN[2], cN[3], cN[4])
  venn.diagram(data, filename = pngOutputFileName, na="remove")
  o <- calculate.overlap(x=list('h'= x[,1],'h2'=x[,2],'h3'=x[,3], 'h4'= x[,4]))
  df = data.frame(lapply(o, "length<-", max(lengths(o))))
  colnames(df) <-c("All", "123", "124", "134", "234", "12", "13","14", "23", "24", "34", paste("1_",cN[1], sep='_'),paste("2_", cN[2], sep='_'),paste("3_",cN[3], sep='_'),paste("4_",cN[4], sep='_'))
  write.table(df,  paste(outputFileName, sep=''), sep ="\t", col.names =NA , quote = FALSE)
}

