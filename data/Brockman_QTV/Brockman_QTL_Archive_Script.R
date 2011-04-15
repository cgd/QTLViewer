#########################################################################################
## QTL Analysis R script
## 
## Cross Information:  Brockman 2009 QTL Archive
## 
## Script History:
## March 2011 - template written by Gary Churchill
## March 2011 - Modified by GC
## 
#########################################################################################
#
# clear the deck
rm(list=ls())

## Load the R/qtl package and check the version
version
library(qtl)
qtlversion()

## Change the directory
setwd("/Users/garychurchill/GARY/Projects/035_QTL_Archive/Brockman_QTV")

## Data import
dbnm <- read.cross("csv", file="Brockmann2009_DBA2xNMRI8_B37_Data.csv", na.string="-",
                  genotypes=c("D","H","N"),alleles=c("D","N")) 

## look at the cross object
summary.cross(dbnm)
names(dbnm$pheno)
# covariates: "Id" "F" "M" "pgm" "sex" "parity" "subfam" "pupsize" 
# phenotypes: "Bw3" "Bw4" "Bw5" "Bw6" "Afw" "Afp" "Mw" "Liver" "Kidney" "Spleen" 
#note phenotype columns are 9-18 
nind(dbnm)
nphe(dbnm)
table(dbnm$pheno$sex) # 142F 133M
table(dbnm$pheno$pgm) #  All D
#
quartz()
plot.cross(dbnm, pheno=c(9:18))

##############################
## Look at the genotype data
##############################

nchr(dbnm) #19 autosome plus X chr 
nmar(dbnm) #note %genotyped and segregation ratio

## draw missing genotype pattern
plot.missing(dbnm)

## Plot genetic map of original data
plot.map(dbnm)

## Re-estimate genetic map by 
newmap <- est.map(dbnm);
quartz()
plot.map(dbnm, newmap)
#note modest map expansion on chr 4

## Recombination fraction plot
quartz()
plot.rf(est.rf(dbnm))

#####################################################
## section added by GC to diagnose and correct map problems
#
#take a closer look at chr 4
quartz()
plot.rf(est.rf(dbnm), chr=4)

ripple(dbnm, 4, 4)
# there is a marker ordering problem
#                    obligXO
#Initial 1 2 3 4 5 6     469
#1       1 2 5 3 4 6     310
#2       1 2 5 3 6 4     339
#3       1 2 3 5 4 6     366
#
# current order
dbnm$geno[[4]]$map
#D4Mit196 D4Mit140  D4Mit37  D4Mit54 D4Mit205  D4Mit42 
# 20.1640  31.1252  53.4255  70.0210  76.5800  82.6371 
#
#reorder
dbnm <- switch.order(dbnm, 4, c(1,2,5,3,4,6))
dbnm$geno[[4]]$map
# D4Mit196 D4Mit140 D4Mit205  D4Mit37  D4Mit54  D4Mit42 
# 20.16400 29.82151 48.98323 59.59570 80.35605 93.48747
#
#calculate the interpolation to reposition D4Mit205
dbnm$geno[[4]]$map <- c(20.1640,31.1252,45.4777,53.4255,70.0210,82.6371)
names(dbnm$geno[[4]]$map) <- c("D4Mit196","D4Mit140","D4Mit205",
	"D4Mit37","D4Mit54","D4Mit42")
dbnm$geno[[4]]$map
#
##recheck diagnostic plots
newmap <- est.map(dbnm);
quartz()
plot.map(dbnm, newmap)
#
quartz()
plot.rf(est.rf(dbnm), chr=4)
## looks great
## end of map correction
#####################################################

## clean up
graphics.off()
rm(newmap)
ls()

##############################
#phenotype data
##############################

## optional diagnostics
# means and sds
table1<-rbind(mean(dbnm$pheno[,9:18],na.rm = TRUE), sd(dbnm$pheno[,9:18],na.rm = TRUE))
rownames(table1)<-c("mean", "sd")
t(round(table1,2))
# correlations
# alt: use method="spearman"
rho <- cor(dbnm$pheno[,9:18], method="pearson", use = "complete.obs")
round(rho,2)
quartz()
heatmap(rho)
#
# all pairwise plots - do not use if too many phenotypes
quartz()
pairs(dbnm$pheno[,c(9:18)])
#
for(i in 9:18){
	quartz()
	boxplot(split(dbnm$pheno[,i],dbnm$pheno$sex),xaxt="n")  
	axis(1,at=c(1,2),labels=c("F","M"))
   test <- t.test(dbnm$pheno[dbnm$pheno$sex==0,i],dbnm$pheno[dbnm$pheno$sex==1,i])  
	title(c(main=names(dbnm$pheno)[i],as.character(signif(test$p.value,3))))
	}
#
# qq-plots check prior to z-transform
for(i in 9:18){
	quartz()
	qqnorm(dbnm$pheno[[i]],main=names(dbnm$pheno)[i])  
	}
#
#clean up
graphics.off()
rm(table1, rho, i, test)
ls()
## end of optional diagnostics	


### transform the phenotype data
#
rz.transform<-function(y) {
   rankY=rank(y, ties.method="average", na.last="keep")
   rzT=qnorm(rankY/(length(na.exclude(rankY))+1))  
   rzT
}
dbnm$pheno[,9:18] <- apply(dbnm$pheno[,9:18],2,rz.transform)


##############################################
## Genome scans
#
## initialize genotype probabilities
dbnm <- calc.genoprob(dbnm, step=2)
#
pcol = c(9:18)	#vector of phenotype columns to scan 
nperm = 100			#number of permutations use 100 rough, 1000 final
#
#sex as additive covariate scans
scan1.add <- scanone(dbnm, pheno.col=pcol, addcov=dbnm$pheno$sex,
		model="normal", method="em",use="all.obs")
perm1.add<-scanone(dbnm, pheno.col=pcol, addcov=dbnm$pheno$sex,
		model="normal", method="em", use="all.obs", perm.Xsp=TRUE, n.perm=nperm)
#
summary(perm1.add)
summary(scan1.add, perms=perm1.add, alpha=0.10, format="tabByCol")

#
#sex as interactive covariate scans
scan1.int <- scanone(dbnm, pheno.col=pcol, intcov=dbnm$pheno$sex,
		model="normal", method="em",use="all.obs")
perm1.int <- scanone(dbnm, pheno.col=pcol, intcov=dbnm$pheno$sex,
		model="normal", method="em", use="all.obs", perm.Xsp=TRUE, n.perm=nperm)
#
summary(perm1.int)
summary(scan1.int, perms=perm1.int, alpha=0.10, format="tabByCol")

#
## save scans and perms
save(list=c("scan1.add","perm1.add","scan1.int","perm1.int"),file="Brockman_scans.Rdata")
#
##load saved scans
#load("Brockman_scans.Rdata")

##Plot the scans
for(i in 1:length(pcol)){
	quartz()
	par(mfrow=c(3,1), mar = c(3.1, 4.1, 2.1, 2.1))
	plot(scan1.add, lodcolumn=i,bandcol="gray80",xlab="",ylab="")
	add.threshold(scan1.add, perms=perm1.add, alpha=0.10, lodcolumn=i,
		lty="dashed",lwd=2,col="red")
	mtext(paste(names(dbnm$pheno)[pcol[i]],"~ Q + SEX"), 
		side=3, line=0,cex=1.0,xlab="",ylab="")
	plot(scan1.int, lodcolumn=i,bandcol="gray80")
	add.threshold(scan1.int,perms=perm1.int,alpha=0.10,lodcolumn=i,
		lty="dashed",lwd=2,col="red")
	mtext(paste(names(dbnm$pheno)[pcol[i]],"~ Q * SEX"), 
		side=3, line=0,cex=1.0,xlab="",ylab="")
	plot(scan1.int-scan1.add, lodcolumn=i,bandcol="gray70",xlab="",ylab="")
	abline(h=2,lty="dashed",lwd=2,col="red")
	mtext("DIFF", side=3, line=0,cex=1.0,xlab="",ylab="")
	}
#	
graphics.off()
#
##Plot the scans - alternative one panel per trait
for(i in 1:length(pcol)){
	quartz()
	plot(scan1.add,scan1.int,scan1.int-scan1.add, lodcolumn=i,bandcol="gray70")
	add.threshold(scan1.add, perms=perm1.add, alpha=0.10, lodcolumn=i, 
		col="black",lty="dashed",lwd=2)
	add.threshold(scan1.int, perms=perm1.int, alpha=0.10, lodcolumn=i, 
		col="blue",lty="dashed",lwd=2)
	abline(h=2,lty="dashed",lwd=2,col="red")
	}
#
graphics.off()


#generate output files for QTLViz
#
# table of QTL peaks - version I
#peak.table <- function(mycross, scan.out, perm.out, pcol, alpha.out=0.10){
#    out1 <- summary(scan.out[,c(1,2,pcol+2)], 
#    						perms=subset(perm.out,lodcolumn=pcol), 
#    						alpha=alpha.out, pvalues=TRUE)
#    if (length(out1)>0 ) { # we have at least one QTL peak above threshold
#      peakMar=find.marker(mycross, out1$chr, out1$pos)
#      qCI <- NULL
#      for (kk in 1:length(out1$chr)) {
#           k=out1$chr[kk]
#           
#           # get the QTL CI using LOD drop method
#           a=round((lodint(scan.out[,c(1,2,pcol+2)],chr=k,drop=1.5))[c(1,3),2],2)
#           a=paste(a, collapse="-")
#
#           # get the QTL CI using bayesint()
#           b <- round((bayesint(scan.out[,c(1,2,pcol+2)],chr=k,prob=0.95))[c(1,3),2],2)
#           b <- paste(b, collapse=" - ")
#           
#           qCI <- rbind(qCI, c(a,b))
#      }
#      out1=cbind(out1, qCI, peakMar)
#      colnames(out1)=c("chr","pos","LOD","pval","CI.lod","CI.bayes","PeakMarker")
#      out1
#    }
#}
##
#for(i in 1:length(pcol)){
#	fname <- paste("Brockman_2006_",names(dbnm$pheno)[pcol[i]],".th.chr.csv",sep="")
#	write.csv(peak.table(dbnm, scan1.add, perm1.add, i),file=fname)
#}


#table of peak QTL - version II
fname <- "Brockman_2006_sexadd.peaks.txt"
sink(fname)
summary(scan1.add,format="tabByCol",perms=perm1.add,alpha=0.1, pvalues=TRUE)
sink()
#
fname <- "Brockman_2006_sexint.peaks.txt"
sink(fname)
summary(scan1.int,format="tabByCol",perms=perm1.int,alpha=0.1, pvalues=TRUE)
sink()

#table of peak QTL - version III
make.rownames <- function(qtl, trait){
	#qtl is a dataframe from scanone.summary
	#trait is a charcter string trait name
	n <- dim(qtl)[1]
	names <- NULL
	for(i in 1:n){
		names <- c(names,paste(trait,as.character(i),sep="_"))
		}
	rownames(qtl) <- names
	qtl
	}
tmp <- summary(scan1.add,format="tabByCol",perms=perm1.add,alpha=0.1, pvalues=TRUE)
out.table <- NULL
for(i in 1:length(tmp)){
	out.table <- rbind(out.table, make.rownames(tmp[[i]], names(tmp)[i]))
	}
#
fname <- "Brockman_2006_sexadd.peaks.csv"
write.csv(out.table, file=fname)

#Table of scan thresholds - version I
fname <- "Brockman_2006_sexadd.thresh.txt"
sink(fname)
summary(perm1.add, alpha=c(0.63,0.1,0.05))
sink()
#
fname <- "Brockman_2006_sexint.thresh.txt"
sink(fname)
summary(perm1.int, alpha=c(0.63,0.1,0.05))
sink()

#Table of thresholds - version II
fname <- "Brockman_2006_sexadd.thresh.csv"
alpha = c(0.63,0.1,0.05)
tmp <- summary(perm1.add, alpha=alpha)
tmp <- cbind(c(alpha, alpha),rbind(tmp$A, tmp$X))
colnames(tmp) <- c("alpha",colnames(tmp)[2:length(colnames(tmp))])
rownames(tmp) <- c(rep("A",length(alpha)),rep("X",length(alpha)))
write.csv(tmp, file=fname)

#Table of LOD scores
fname <- "Brockman_2006_sexadd.lod.csv"
write.csv(scan1.add,file=fname)
#
fname <- "Brockman_2006_sexint.lod.csv"
write.csv(scan1.int,file=fname)



## Run paircans - optional 
# use method="hk" for speed, method="em" for accuracy if marker data are sparse
# note if no missing phenotype data, use="complete.obs" may run faster
# X chromosome excluded - pairscans are not correct for X
scan2.add<-scantwo(dbnm, pheno.col=pcol, chr=1:19, addcov=dbnm$pheno$sex,
		model="normal", method="hk",use="all.obs")

#
## report pairscans
#summary.scantwo(scan2.BPPC, what = "best", thresholds=c(8, 6, 4, 6, 3))
#summary.scantwo(scan2.BPPC, allpairs=FALSE)

