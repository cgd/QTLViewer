#########################################################################################
## QTL Analysis R script
## 
## Cross Information:  Wergedal 2006 QTL Archive
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
setwd("/Users/garychurchill/GARY/Projects/035_QTL_Archive/Wergedal_QTV")

## Data import
nzrf <- read.cross("csv", file="Wergedal2006_NZBxRF_B37_Data.csv", 
	na.string="-",genotypes=c("N","H","R"),alleles=c("N","R")) 

## look at the cross object
summary.cross(nzrf)
##note %genotyped and segregation ratio
names(nzrf$pheno)
# covariates: "sex"     "pgm"      
# phenotypes: "Ftotden" "P"       "CrtThk"  
#note phenotype columns are 3:5 
pcol = 3:5
#
nind(nzrf)
nphe(nzrf)
table(nzrf$pheno$sex) # 661F 
table(nzrf$pheno$pgm) # 
#
quartz()
plot.cross(nzrf, pheno=pcol)

##############################
## Look at the genotype data
##############################

nchr(nzrf) #19 autosome 
nmar(nzrf) 

## draw missing genotype pattern
plot.missing(nzrf)

## Plot genetic map of original data
plot.map(nzrf)

## Re-estimate genetic map by 
newmap <- est.map(nzrf);
quartz()
plot.map(nzrf, newmap)
#note huge expansion on chr 7

## Recombination fraction plot
quartz()
plot.rf(est.rf(nzrf))

#############################################
# section added to repair map
#
#the second marker on chr 7 links to chr 17, remove it.
nzrf$geno[[7]]$map
#D7Mit152 D7Mit113  D7Mit69 D7Mit159  D7Mit93 D7Mit253 D7Mit358 D7Mit259 
#  2.7137  13.9326  31.1895  33.5250  44.8612  61.3679  67.2721  88.8540 
#
nzrf <- drop.markers(nzrf,c("D7Mit113"))
#
##recheck diagnostic plots
newmap <- est.map(nzrf);
quartz()
plot.map(nzrf, newmap)
#
quartz()
plot.rf(est.rf(nzrf))
## looks good
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
table1<-rbind(mean(nzrf$pheno[,pcol],na.rm = TRUE), 
					sd(nzrf$pheno[,pcol],na.rm = TRUE))
rownames(table1)<-c("mean", "sd")
t(round(table1,2))
# correlations
# alt: use method="spearman"
rho <- cor(nzrf$pheno[,pcol], method="pearson", use = "complete.obs")
round(rho,2)
#quartz()
#heatmap(rho)
#
# all pairwise plots - do not use if too many phenotypes
quartz()
pairs(nzrf$pheno[,c(pcol)])
#
#for(i in pcol){
#	quartz()
#	boxplot(split(nzrf$pheno[,i],nzrf$pheno$sex),xaxt="n")  
#	axis(1,at=c(1,2),labels=c("F","M"))
#   test <- t.test(nzrf$pheno[nzrf$pheno$sex==0,i],nzrf$pheno[nzrf$pheno$sex==1,i])  
#	title(c(main=names(nzrf$pheno)[i],as.character(signif(test$p.value,3))))
#	}
#
# qq-plots check prior to z-transform
for(i in pcol){
	quartz()
	qqnorm(nzrf$pheno[[i]],main=names(nzrf$pheno)[i])  
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
nzrf$pheno[,pcol] <- apply(nzrf$pheno[,pcol],2,rz.transform)


##############################################
## Genome scans
#
## initialize genotype probabilities
nzrf <- calc.genoprob(nzrf, step=2)
#
nperm = 100			#number of permutations use 100 rough, 1000 final
#
#sex as additive covariate scans
scan1.out <- scanone(nzrf, pheno.col=pcol,		model="normal", method="em",use="all.obs")
perm1.out<-scanone(nzrf, pheno.col=pcol, 
		model="normal", method="em", use="all.obs", n.perm=nperm)
#
summary(perm1.out)
summary(scan1.out, perms=perm1.out, alpha=0.10, format="tabByCol")
#
## save scans and perms
save(list=c("scan1.out","perm1.out"),file="Wergedal_scans.Rdata")
#
##load saved scans
#load("Wergedal_scans.Rdata")
#
##Plot the scans 
for(i in 1:length(pcol)){
	quartz()
	plot(scan1.out, lodcolumn=i, bandcol="gray70")
	add.threshold(scan1.out, perms=perm1.out, alpha=0.10, lodcolumn=i, 
		col="black",lty="dashed",lwd=2)
	}
#
graphics.off()


#generate output files for QTLViz
#
alpha = 0.05
#table of peak QTL
fname <- "Wergedal_2006.peaks.txt"
sink(fname)
summary(scan1.out,format="tabByCol",perms=perm1.out,alpha=alpha,pvalues=TRUE)
sink()
#
#Table of scan thresholds
fname <- "Wergedal_2006.thresh.csv"
write.csv(summary(perm1.out,alpha=alpha),file=fname)
#
#Table of LOD scores
fname <- "Wergedal_2006.lod.csv"
write.csv(scan1.out,file=fname)


## Run paircans - optional 
# use method="hk" for speed, method="em" for accuracy if marker data are sparse
# note if no missing phenotype data, use="complete.obs" may run faster
# X chromosome excluded - pairscans are not correct for X
scan2.out<-scantwo(nzrf, pheno.col=pcol, chr=1:19,
		model="normal", method="hk",use="all.obs")
save("scan2.out",file="Wergedal_scan2.Rdata")
#
## report pairscans
for(i in 1:length(pcol)){
	print(names(nzrf$pheno)[pcol[i]])
	print(summary(scan2.out, what = "best", lodcolumn=i,
			thresholds=c(9.1, 7.1, 6.3, 6.3, 3.3)))
	}
#
for(i in 1:length(pcol)){
	print(names(nzrf$pheno)[pcol[i]])
	print(summary.scantwo(scan2.out, lodcolumn=i, allpairs=FALSE))
	}


