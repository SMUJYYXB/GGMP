#Author: Pan Li
#Date: 2017.04.16
#Contact: 648758696@qq.com
#Copyright: Hong-Wei Zhou


# Install necessary packages
doInstall <- FALSE  #Change to FALSE if don't want packages installed
package <- c("ggplot2","optparse")
if (doInstall){install.packages(package,repos = "http://cran.us.r-project.org")}
lapply(package, library, character.only = TRUE)

# Make option list and parse command line
args <- commandArgs(trailingOnly =  TRUE)
option_list <- list(
        make_option(c("-i","--meta"),type = "character", help = "Input metadata file(Required)"),
        make_option(c("-o","--output_dir"),type = "character", help = "Output directory(Required)")
)
opts <- parse_args(OptionParser(option_list = option_list), args = args)

# Check paramenter
if(is.null(opts$meta)) stop('Please supply the metadata file.')
if(is.null(opts$output_dir)) stop('Please supply the output directory.')

# Make output directory
dir.create(outpath<-opts$output_dir)


### the MetS standardise function
count <- function(disease){
  # NA is not calculated into sum(n)
  n <- data.frame(table(disease),row.names = 1) 
  return(n)
}
standardise <- function(input,feature.to.standard,level = NA,divide,standard.by){
  library(reshape)
  f <- function(disease,level = levels(disease)[1]){
    # NA is not calculated into sum(n)
    n <- data.frame(table(disease),row.names = 1) 
    x <- n[which(rownames(n)==level),1]/sum(n)
    return(x)
  }
  attach(input)
  k <- data.frame(table(standard.by),row.names = 1)
  c <- data.frame(table(divide),row.names = 1)
  if (is.na(level)){
    prevalence <- aggregate(feature.to.standard,by=list(divide,standard.by),f)
  }else{
    prevalence <- aggregate(feature.to.standard,by=list(divide,standard.by),f,level = level)
  }
  detach(input)
  colnames(prevalence)[3] <- "value"
  m <- cast(prevalence,Group.2~Group.1)
  rownames(m) <- m[,1]
  m[,1] <- k
  a <- data.frame()
  for (i in colnames(m)[2:ncol(m)]){
    m[,i] <- m[,i]*m$Group.2
  }
  a <- data.frame(colSums(m,na.rm = T)/sum(m$Group.2))
  colnames(a) = "standardised.rate"
  name.pos <- paste("positive",level,sep = ".")
  name.neg <- paste("negative",level,sep = ".")
  a[,name.pos] <- data.frame(round(c*colSums(m,na.rm = T)/sum(m$Group.2)))
  a[,name.neg] <- data.frame(c-round(c*colSums(m,na.rm = T)/sum(m$Group.2)))
  return(a)
}


### data input 
d <- read.table(opts$meta,header = T,sep = "\t",comment.char = "")
a <- summary(d$c__Gammaproteobacteria)
b <- summary(d$act_static_time)
d$age_group <- cut(d$age,breaks = c(-Inf,30,40,50,60,70,79,Inf))
d$gender_age_group <- paste(d$age_group,d$gender)

### extract the Gammaproteobacteria and lifestyle group 
dta <- subset(d,select = c(c__Gammaproteobacteria,p__Proteobacteria,act_static_time,MetS,
                           county_level_code,gender_age_group))
dta$groupbac <- "k"
dta$grouplife <- "k"
dta <- na.omit(dta)
dta <- within(dta,{
  groupbac[c__Gammaproteobacteria < a[2]] <- "bacter1"
  groupbac[c__Gammaproteobacteria <= a[3] & c__Gammaproteobacteria >= a[2]] <- "bacter2"
  groupbac[c__Gammaproteobacteria <= a[5] & c__Gammaproteobacteria > a[3]] <- "bacter3"
  groupbac[c__Gammaproteobacteria > a[5]] <- "bacter4"
  
  grouplife[act_static_time < b[2]] <- "lifestyle1"
  grouplife[act_static_time <= b[3] & act_static_time >= b[2]] <- "lifestyle2"
  grouplife[act_static_time <= b[5] & act_static_time > b[3]] <- "lifestyle3"
  grouplife[act_static_time > b[5]] <- "lifestyle4"
})
dta$group <- paste(dta$groupbac,dta$grouplife)

### calculate the gender-age standardise MetS incidence
pre <- standardise(input = dta,feature.to.standard =  MetS,divide = group,
                   standard.by = gender_age_group,level = "y")
names(pre) <- c("x")
pre$Group.1 <- rownames(pre)

### chisq test among four groups
x <- c()
x[1] <- chisq.test(pre[c(1,4),c(2,3)])$p.value
x[2] <- chisq.test(pre[c(1,13),c(2,3)])$p.value
x[3] <- chisq.test(pre[c(1,16),c(2,3)])$p.value
x[4] <- chisq.test(pre[c(4,13),c(2,3)])$p.value
x[5] <- chisq.test(pre[c(4,16),c(2,3)])$p.value
x[6] <- chisq.test(pre[c(13,16),c(2,3)])$p.value

names(x)[1] <- paste(rownames(pre[1,]),rownames(pre[4,]),sep = "--vs--")
names(x)[2] <- paste(rownames(pre[1,]),rownames(pre[13,]),sep = "--vs--")
names(x)[3] <- paste(rownames(pre[1,]),rownames(pre[16,]),sep = "--vs--")
names(x)[4] <- paste(rownames(pre[4,]),rownames(pre[13,]),sep = "--vs--")
names(x)[5] <- paste(rownames(pre[4,]),rownames(pre[16,]),sep = "--vs--")
names(x)[6] <- paste(rownames(pre[13,]),rownames(pre[16,]),sep = "--vs--")
x <- p.adjust(x,method = "fdr")
write.table(x,paste(opts$output_dir,"pvalue.txt",sep="/"),quote=F,sep="\t")

### make the plot (four groups and the MetS incidence)
pre <- pre[c(1,4,13,16),]
p <- ggplot(pre,aes(Group.1)) 
p + geom_bar(aes(y = x-0.1),stat="identity") + theme(legend.position = "none") + 
  xlab("")+ ylab("MetS Prevalence") + #labs(title="") +
  theme(axis.text.x = element_text(size = 8,angle = 30,vjust = 0.72),
        axis.text.y = element_text(size = 8,angle = 90),
        plot.title = element_text(size = 12)) +
  scale_y_continuous(breaks = c(0,0.1,0.2),limits = c(0,0.2),labels = c(0.1,0.2,0.3)) + 
  scale_x_discrete(labels= c("bacter1 lifestyle1"= "G.Low.S.Low","bacter1 lifestyle4"= "G.Low.S.High",
                             "bacter4 lifestyle1"= "G.High.S.Low","bacter4 lifestyle4"= "G.High.S.High"),
                   limits = c("bacter1 lifestyle1","bacter4 lifestyle1","bacter1 lifestyle4","bacter4 lifestyle4"))
ggsave(paste(opts$output_dir,"bacter.lifestyle.4groups.pdf",sep="/"),height = 3,width = 3)


### the standardise MetS incidence of two groups(Low-G, High-G)
pre <- standardise(input = dta,feature.to.standard =  MetS,divide = groupbac,
                   standard.by = gender_age_group,level = "y")
### the chisq test of two groups (Low-G, High-G)
chisq.test(pre[c(1,4),c(2,3)])
### make the plot(two groups) 
names(pre) <- c("x")
pre$Group.1 <- rownames(pre)
pre <- pre[c(1,4),]
p <- ggplot(pre,aes(Group.1)) 
p + geom_bar(aes(y = x-0.1),stat="identity") + theme(legend.position = "none") + 
  xlab("")+ ylab("MetS Prevalence") +# labs(title="") +
  theme(axis.text.x = element_text(size = 8,angle = 30,vjust = 0.72),
        axis.text.y = element_text(size = 8,angle = 90),
        plot.title = element_text(size = 12)) +
  scale_y_continuous(breaks = c(0,0.1,0.2),limits = c(0,0.2),labels = c(0.1,0.2,0.3)) + 
  scale_x_discrete(labels= c("bacter1"= "G.Low","bacter4"= "G.High"),
                   limits= c("bacter1","bacter4"))
ggsave(paste(opts$output_dir,"bacter2groups.pdf",sep="/"),height = 3,width = 2.5)
