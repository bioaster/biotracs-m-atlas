
library('stringr')
library('optparse')

option_list = list(
  make_option(c("-i", "--InputFilePath"), type="character", 
              help="Input File to plot the grouped boxplot", metavar="character"),
  make_option(c("-o", "--OutputFilePath"), type="character", 
              help="Output File of the plot", metavar="character"),
  make_option(c("-n", "--ConditionNameColor"), type="character",  
              help="The name of the conditions to color", metavar="character"),
  make_option(c("-g", "--ConditionNameGroup"), type="character",  
              help="Name of the conditions to group inside the boxplots", metavar="character"),
  make_option(c("-c", "--Colors"), type="character",  default = NA,
              help="colors to use, use, 'cond1:red,cond2:green'", metavar="character")
  
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser);


inputFilePath = opt$InputFilePath
outputFilePath = opt$OutputFilePath
conditionNameColor= opt$ConditionNameColor
conditionNameGroup = opt$ConditionNameGroup
print(paste('Input File Path is ',  inputFilePath))
print(paste('Output File Path is ',  outputFilePath))
x= read.csv(inputFilePath,  sep='\t',  as.is=1)

colorGroup = str_extract(x[,1], paste(conditionNameColor, ':[^_]*', sep='') )
group = str_extract(x[,1], paste(conditionNameGroup, ':[^_]*' , sep=''))
newx = paste(group, colorGroup, sep='_')
n = dim(x)
z = cbind.data.frame(newx, x[,2:n[2]] ,stringsAsFactors = FALSE)

data <- data.frame(lapply(z, function(x){gsub(paste(conditionNameColor, ":", sep=''), "", x) }),stringsAsFactors = FALSE)
data2 <- data.frame(lapply(data, function(x){gsub(paste(conditionNameGroup , ":", sep=''), "", x) }),stringsAsFactors = FALSE)

lipids = colnames(data2)

labels = unique(sort(data2$newx))
conditionColor = str_split_fixed(labels, '_', 2)[, 2]
number = str_split_fixed(labels, '_', 2)[, 1]

m = table(number)

n= length(m)

k= NULL;
cpt = 0;
for (i in 1:n){
  a = m[[i]]
  for (j in 1:a){
    cpt = cpt +1;
    k= c(k, cpt)
  }
  cpt = cpt+1;
}


colors = opt$Colors
colors[colors=='NA'] <- NA

if (is.na(colors)){
  colors = rainbow(10)
  uniqueConditionColor = unique(conditionColor)
  for (i in 1: length(uniqueConditionColor)) {
    conditionColor = gsub(uniqueConditionColor[i],colors[i],conditionColor)
  }
}else {
  splittedGroups = strsplit(colors, ',')
  splitted = strsplit(unlist(splittedGroups), ':')
  uniqueConditionColor = sapply(splitted, function(x) x[1])
  uniqueColor = sapply(splitted, function(x) x[2])
  for (i in 1: length(uniqueColor)) {
    conditionColor = gsub(uniqueConditionColor[i],uniqueColor[i],conditionColor)
  }
  
} 


for(l in 2:25){

  tiff(paste(outputFilePath, '\\', lipids[l], '.tif', sep=''),  pointsize = 5, res= 300, width = 1000, height = 1000)
  boxplot(as.numeric(data2[,l]) ~ data2$newx , las=2,
          col = conditionColor,
          at = k,
          par(mar = c(6, 4, 2, 2)))
  dev.off()
}
