
library(party)
library(e1071)
library(kernlab)
library(class)
library(ROCR)
library(randomForest)
library(MASS)

# R CMD BATCH "--no-restore --args ${FIXDIR}/ ${MELOUT}/ Standard 0.1" ${FIXDIR}/fix_2_PREDICT.R ${MELOUT}/fix/logR_Standard_0.1.txt

if (T) {
	args <- commandArgs(TRUE)
	path.to.fix <- args[[1]]
	print(path.to.fix)
	melodic.path <- args[[2]]
	print(melodic.path)
	weight.file.name <- args[[3]]
	print(weight.file.name)
	bin.thresh <- args[[4]]
	print(bin.thresh)
	#
	#which.fix <- args[[5]]
	#print(which.fix)
} else {
	rm(list = ls())
	path.to.fix <- "/Users/reza/Documents/Academic/FIX/fix1.02"
	melodic.path <- "/Users/reza/Documents/Academic/FIX/raw_data/EXAMPLEL/20100509_151441IM-0015-140s015a001.ica"
	weight.file.name <- "/Users/reza/Documents/Academic/FIX/raw_data/EXAMPLEL/TRAIN.RData"
	bin.thresh <- 20	
}





if(substr(path.to.fix, nchar(path.to.fix), nchar(path.to.fix))!="/") 
	path.to.fix <- paste(path.to.fix, "/", sep = "")
if(substr(melodic.path, nchar(melodic.path), nchar(melodic.path))!="/") 
	melodic.path <- paste(melodic.path, "/", sep = "")
bin.thresh <- as.numeric(bin.thresh)

load(weight.file.name)
test.data <- read.csv(paste(melodic.path, "fix/features.csv", sep = ""), header = F)
# drop the undesired features
test.data <- test.data[, init.keep.list[-length(init.keep.list)]]
# drop the zero-var features
if (length(also.excl)) test.data <- test.data[, -also.excl]
# make the feature numeric (i.e., not categorical, etc.)
for(i in c(1:dim(test.data)[2])) test.data[,i] <- as.numeric(test.data[,i])
names(test.data) <- test.features.names


test.data.1 <- test.data # full
test.data.2 <- test.data.1[, selected.features] # sub
test.data.3 <- test.data.1[, test.features.types!=2] # temporal
test.data.4 <- test.data.1[, test.features.types!=1] # spatial
test.data.5 <- test.data.1[, (test.features.types!=2) & selected.features] # sub temporal
test.data.6 <- test.data.1[, (test.features.types!=1) & selected.features] # sub spatial

train.data.1  <- hcp.data # full
train.data.2  <- hcp.data.sub # sub
train.data.3  <- hcp.data.temporal # temporal
train.data.4  <- hcp.data.spatial # spatial
train.data.5  <- hcp.data.sub.temporal # sub temporal
train.data.6  <- hcp.data.sub.spatial # sub spatial


for(indx in c(1:6)) {
	# SVM
	eval(parse(text = paste("svm.rbf.prd",indx," <- attributes(predict(svm.rbf",indx,", test.data.",indx,", probability=T))$probabilities[,2]", sep = "")))
  	eval(parse(text = paste("svm.lin.prd",indx," <- attributes(predict(svm.lin",indx,", test.data.",indx,", probability=T))$probabilities[,2]", sep = "")))
  	eval(parse(text = paste("svm.pol.prd",indx," <- attributes(predict(svm.pol",indx,", test.data.",indx,", probability=T))$probabilities[,2]", sep = "")))
  	
	# Tree
        eval(parse(text = paste("ctree", indx, " = ctree", indx, "@update()", sep = "")))
	eval(parse(text = paste("ctree.prd.test",indx," <- treeresponse(ctree",indx,", newdata = test.data.",indx,")", sep = "")))
	eval(parse(text = paste("ctree.prob.test",indx," <- c(1:length(ctree.prd.test",indx,"))", sep = "")))
	eval(parse(text = paste("for(i in c(1:length(ctree.prob.test",indx,"))){ctree.prob.test",indx,"[i] <- ctree.prd.test",indx,"[[i]][2]}", sep = "")))

	# KNN
	eval(parse(text = paste("tmp <- knn(train.data.",indx,"[,-dim(train.data.",indx,")[2]], test.data.",indx,", train.data.",indx,"[,dim(train.data.",indx,")[2]], k = k.knn, prob = T)", sep = "")))
	eval(parse(text = paste("knn.test",indx," <- attributes(tmp)", sep = "")))
	eval(parse(text = paste("knn.test",indx,"$prob[tmp==0] <- 1-knn.test",indx,"$prob[tmp==0]", sep = "")))
}

df.test.tmp <- data.frame(knn6 = knn.test6$prob,
                          tre6 = ctree.prob.test6,
                          rbf6 = svm.rbf.prd6,
                          lin6 = svm.lin.prd6,
                          pol6 = svm.pol.prd6,
                          knn5 = knn.test5$prob,
                          tre5 = ctree.prob.test5,
                          rbf5 = svm.rbf.prd5,
                          lin5 = svm.lin.prd5,
                          pol5 = svm.pol.prd5,
                          knn4 = knn.test4$prob,
                          tre4 = ctree.prob.test4,
                          rbf4 = svm.rbf.prd4,
                          lin4 = svm.lin.prd4,
                          pol4 = svm.pol.prd4,
                          knn3 = knn.test3$prob,
                          tre3 = ctree.prob.test3,
                          rbf3 = svm.rbf.prd3,
                          lin3 = svm.lin.prd3,
                          pol3 = svm.pol.prd3,
                          knn2 = knn.test2$prob,
                          tre2 = ctree.prob.test2,
                          rbf2 = svm.rbf.prd2,
                          lin2 = svm.lin.prd2,
                          pol2 = svm.pol.prd2,
                          knn1 = knn.test1$prob,
                          tre1 = ctree.prob.test1,
                          rbf1 = svm.rbf.prd1,
                          lin1 = svm.lin.prd1,
                          pol1 = svm.pol.prd1
                          )


if(F) { # TREE, which.fix=='T'
	fusion.tree.prd.testp <- simplify2array(treeresponse(fusion.tree, newdata = df.test.tmp))[2,]
}

if(T) { # RF, which.fix=='F'
	fusion.tree.prd.testp <- predict(fusion.tree, newdata = df.test.tmp, type="prob")[,2]
}

if(F) { # SVM, RBF, which.fix=='R'
	fusion.tree.prd.testp <- attributes(predict(fusion.tree, newdata = df.test.tmp, probability=T))$probabilities
  	fusion.tree.prd.testp <- fusion.tree.prd.testp[,which(colnames(fusion.tree.prd.testp)=='1')]
}

if(F) { # SVM, LIN, which.fix=='L'
	fusion.tree.prd.testp <- attributes(predict(fusion.tree, newdata = df.test.tmp, probability=T))$probabilities
  	fusion.tree.prd.testp <- fusion.tree.prd.testp[,which(colnames(fusion.tree.prd.testp)=='1')]
}


bin.thresh <- bin.thresh/100
weight.file.name.bits <- strsplit(weight.file.name, "/")[[1]]
weight.file.name.bits <- weight.file.name.bits[length(weight.file.name.bits)]
weight.file.name.bits <- substr(weight.file.name.bits, 1, nchar(weight.file.name.bits)-6)
sink(paste(melodic.path, "fix4melview_", weight.file.name.bits, "_thr", bin.thresh*100, ".txt", sep = ""))
cat("filtered_func_data.ica")
cat("\n")
end.string <- "["
anynoise <- 0
for(i in c(1:length(fusion.tree.prd.testp))){
	if(fusion.tree.prd.testp[i]< bin.thresh){
		#cat(paste(i, ", ", "Unclassified Noise", ", ", "True", sep = ""))
		cat(paste(i, ", ", "Unclassified Noise", ", ", "True",",",fusion.tree.prd.testp[i], sep = ""))
		cat("\n")
		end.string <- paste(end.string, i, ", ", sep = "")
		anynoise <- 1
	}else if(fusion.tree.prd.testp[i]>.5){
		#cat(paste(i, ", ", "Signal", ", ", "False", sep = ""))
		cat(paste(i, ", ", "Signal", ", ", "False",",",fusion.tree.prd.testp[i], sep = ""))
		cat("\n")
	}else{
		#cat(paste(i, ", ", "Unknown", ", ", "False", sep = ""))
		cat(paste(i, ", ", "Unknown", ", ", "False",",",fusion.tree.prd.testp[i], sep = ""))
		cat("\n")
	}
}
if (anynoise>0) {
  end.string <- substr(end.string, 1, nchar(end.string)-2)
}
end.string <- paste(end.string, "]\n", sep = "")
cat(end.string)
sink()

