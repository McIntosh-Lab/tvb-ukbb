
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
	path.to.train.files <- args[[2]]
	print(path.to.train.files)
	weight.file.name <- args[[3]]
	print(weight.file.name)
	#
	#which.fix <- args[[4]]
	#print(which.fix)
} else {
	path.to.fix <- "/Users/reza/Documents/Academic/FIX/fix1.02"
	path.to.train.files <- "/Users/reza/Documents/Academic/FIX/raw_data/EXAMPLEL/TRAIN"
	weight.file.name <- "/Users/reza/Documents/Academic/FIX/raw_data/EXAMPLEL/TRAIN.RData"
}

if (substr(path.to.fix, nchar(path.to.fix), nchar(path.to.fix))!="/")
  path.to.fix <- paste(path.to.fix, "/", sep = "")
if (substr(path.to.train.files, nchar(path.to.train.files), nchar(path.to.train.files))!="/")
  path.to.train.files <- paste(path.to.train.files, "/", sep = "")

readMelView <- function(file.path) {
	    tmp <- readLines(file.path, -1) # read the full text file
	    tmp <- tmp[grepl("^\\[", tmp) & grepl("\\]$", tmp)] # get THE line
	    noise.list <- as.numeric(strsplit(gsub("\\]", "", gsub("\\[", "", gsub(" ", "", tmp))), ',')[[1]]) # only keep the comma-separated noise IDs > split them
	    return(noise.list) # return a vector, containing noise IDs
}

#readMelView <- function(file.path) {
#	numb <- runif(1,0,100000000000000)*10
#	system(paste("cat ", file.path, " | grep '^\\[' > ", file.path, numb, sep=""))
#	con <- file(paste(file.path, numb, sep=""), "rt")
#	tmp <- readLines(con, 1) # Read one line
#	close(con)
#	noise.list <- as.numeric(strsplit(gsub("\\]", "", gsub("\\[", "", gsub(" ", "", tmp))), ',')[[1]])
#	system(paste("rm ", file.path, numb, sep=""))
#	return(noise.list)
#}

# pre-processing (e.g., concatenate all files, etc.)
is.consistent <- T
file.feats <- list.files(path.to.train.files, "*csv")
file.label <- list.files(path.to.train.files, "*txt")
for(i.feat in file.feats)
	if(sum(substr(i.feat, 1, nchar(i.feat)-3)==substr(file.label, 1, nchar(file.feats)-3))==0)
		is.consistent <- F 

if (!is.consistent) {
	print("There is a problem in that the required files are not arranged properly")
	print("In order for this function to work, there needs to be two files per MELODIC folder")
	print("         1) a features file                  | CSV extracted by FIX")
	print("         2) a MELVIEW-compatible label file  | TXT from manual or FIX labeling")
} else {
	for(i in c(1:length(file.feats))) {
		tmpf <- read.csv(paste(path.to.train.files, file.feats[i], sep = ""), header = F)
		tmpl <- readMelView(paste(path.to.train.files, substr(file.feats[i], 1, nchar(file.feats[i])-3), "txt", sep = ""))
		tmpf$labs <- 1
		tmpf$labs[tmpl] <- 0
		if(i==1) train.mat <- tmpf else train.mat <- rbind(train.mat, tmpf)
	}
}

# given the big file, train and report the LOO accuracy
k.knn <- 11
q.thr <- .6

doAccuracyAnalysis <- function(actual.in, prd.in, do.print = F) {
    prd.in <- as.numeric(prd.in)
    conf.matrix <- table(actual = actual.in, pred = factor(prd.in, levels = c(0, 1)))
    TPR <- conf.matrix[2,2]/sum(conf.matrix[2,])
    TNR <- conf.matrix[1,1]/sum(conf.matrix[1,])
    ACC <- sum(diag(conf.matrix))/sum(conf.matrix)
    if(do.print) {
    	print(c('ACC', 'TPR', 'TNR'))
        print(c(ACC, TPR, TNR))
    }
    c(ACC, TPR, TNR)
}

calcFScore <- function(hcp.data, feat.id) {
	x.plus <- hcp.data[hcp.data$class.labs==1, feat.id]
	x.minus <- hcp.data[hcp.data$class.labs==0, feat.id]
	num.plus <- (mean(x.plus)-mean(hcp.data[, feat.id]))^2
	num.minus <- (mean(x.minus)-mean(hcp.data[, feat.id]))^2 
	n.plus <- length(x.plus)
	n.minus <- length(x.minus)
	den.plus <- sum((x.plus-mean(x.plus))^2)/n.plus
	den.minus <- sum((x.minus-mean(x.plus))^2)/n.minus
	F.score <- (num.plus+num.minus)/(den.plus+den.minus) # to avois NaN, one can +.Machine$double.eps
	F.score
}

calcLinSVMWeights <- function(hcp.data) {
	svm.lin <- ksvm(class.labs ~ ., data = hcp.data, prob.model = T, scale = T, kernel = "vanilladot")
	alpha.idxs <- alphaindex(svm.lin)[[1]]
	alphas <- alpha(svm.lin)[[1]]
	y.sv <- 2*(as.numeric(hcp.data$class.labs[alpha.idxs])-1.5)
	sv.matrix <- as.matrix(hcp.data[alpha.idxs,-dim(hcp.data)[2]])
	weight.vector <- (y.sv*alphas)%*%sv.matrix
	weight.vector
}

trainAndTestSVMs <- function(train.data, test.data) {
	# train
	svm.rbf <- ksvm(class.labs ~ ., data = train.data, prob.model = T, scale = T, kernel = "rbfdot")
	svm.lin <- ksvm(class.labs ~ ., data = train.data, prob.model = T, scale = T, kernel = "vanilladot")
	svm.pol <- ksvm(class.labs ~ ., data = train.data, prob.model = T, scale = T, kernel = "polydot")
	# predict on train
	svm.rbf.prd <- predict(svm.rbf, train.data, type = "probabilities")
	svm.lin.prd <- predict(svm.lin, train.data, type = "probabilities")
	svm.pol.prd <- predict(svm.pol, train.data, type = "probabilities")
	train.prob <- data.frame(rbf = svm.rbf.prd[,2], lin = svm.lin.prd[,2], pol = svm.pol.prd[,2])
	# predict on test
	svm.rbf.prd <- predict(svm.rbf, test.data, type = "probabilities")
	svm.lin.prd <- predict(svm.lin, test.data, type = "probabilities")
	svm.pol.prd <- predict(svm.pol, test.data, type = "probabilities")		
	test.prob <- data.frame(rbf = svm.rbf.prd[,2], lin = svm.lin.prd[,2], pol = svm.pol.prd[,2])
	# return
	list(train.prob, test.prob)
}

trainAndTestKNN <- function(train.data, test.data, k.knn) {
	tmp <- knn(train.data[,-dim(train.data)[2]], train.data[,-dim(train.data)[2]], train.data[,dim(train.data)[2]], k = k.knn, prob = T)
	knn.train <- attributes(tmp)
	knn.train$prob[tmp==0] <- 1-knn.train$prob[tmp==0]
	tmp <- knn(train.data[,-dim(train.data)[2]], test.data[,-dim(test.data)[2]], train.data[,dim(train.data)[2]], k = k.knn, prob = T)
	knn.test <- attributes(tmp)
	knn.test$prob[tmp==0] <- 1-knn.test$prob[tmp==0]
	list(knn.train$prob, knn.test$prob)
}

trainAndTestCTree <- function(train.data, test.data) {
	tmp <- ctree(class.labs ~ ., data = train.data, controls = ctree_control(minbucket = 10, mincriterion = 0.95))
	ctree.prd.train <- treeresponse(tmp, newdata = train.data)
	ctree.prd.test <- treeresponse(tmp, newdata = test.data)
	prob.train <- c(1:length(ctree.prd.train))
	prob.test <- c(1:length(ctree.prd.test))
	for(i in c(1:length(ctree.prd.train))){
		prob.train[i] <- ctree.prd.train[[i]][2]
	}
	for(i in c(1:length(ctree.prd.test))){
		prob.test[i] <- ctree.prd.test[[i]][2]
	}
	list(prob.train, prob.test)
}

# # # read the data and format/clean/standardise it
features.names <- c(	'number.of.ics',
						# temporal features
						'ar.drop.slope', 'ar.drop.offset', 
						'ar1.noise.var', 'ar1.param',
						'ar2.noise.var', 'ar2.param1', 'ar2.param2', 
						'ts.skewness', 'ts.kurtosis', 'ts.mean.min.median', 'ts.entropy1', 'ts.entropy2', 
						'ts.jump.max.abs.diff', 'ts.jump.max.abs.diff.std', 'ts.jump.max.abs.diff.std.len', 'ts.jump.max.abs.diff.std.localmean', 'ts.jump.max.abs.diff.std.localsum', 
						'ts.xcorr', 
						'fft.coarse.10', 'fft.coarse.15', 'fft.coarse.20', 'fft.coarse.25',
						'fft.finer.01', 'fft.finer.025', 'fft.finer.05', 'fft.finer.10', 'fft.finer.15', 'fft.finer.20', 'fft.finer.25',
						'fft.H0r.01', 'fft.H0r.025', 'fft.H0r.05', 'fft.H0r.10', 'fft.H0r.15', 'fft.H0r.20', 'fft.H0r.25', 'fft.H0r',
						'mcorr.max', 'mcorr.max.grad', 'mcorr.max.max', 'mcorr.reg.2nd.max', 'mcorr.reg.max', 'mcorr.reg.mean',
						'ts.oup.sigma', 'ts.oup.lambda', 
						# spatial features
						'cluster.num', 'cluster.mean.min.median', 'cluster.max', 'cluster.var', 'cluster.skew', 'cluster.kurt', 'cluster.max1', 'cluster.max2', 'cluster.max3',
						'negpos.entropy', 'negpos.abs.entropy', 'negpos.mean.ratio', 'negpos.stdmean.ratio', 'negpos.ratio', 'negpos.ratio.thresh',
						'zxfunc.99prctl', 'zxfunc.95prctl', 'z2func.99prctl', 'z2func.95prctl',						
						'num.slice.bt.15prcnt', 'max.slice.prcnt', 'thr.num.slice.bt.15prcnt', 'thr.max.slice.prcnt', 
						'every.2nd.single.var', 'every.2nd.pair.var', 'thr.every.2nd.single.var', 'thr.every.2nd.pair.var',
						# temporal features
						'wm.ts.coef', 'gm.ts.coef', 'csf.ts.coef', 
						# spatial features
						'prcnt.on.csf', 'prcnt.on.gm', 'prcnt.on.wm', 'thr.prcnt.on.csf', 'thr.prcnt.on.gm', 'thr.prcnt.on.wm',
						'thr.both.prcnt.on.csf', 'thr.both.prcnt.on.gm', 'thr.both.prcnt.on.wm', 
						'smoothness', 'smoothness.mm',
						'std.then.tfce.max', 'tfce.max', 'thr.then.tfce',
						'percent.on.edge.bin1', 'percent.on.edge.norm1', 'percent.of.edge1',
						'percent.on.edge.bin2', 'percent.on.edge.norm2', 'percent.of.edge2',
						'percent.on.edge.bin3', 'percent.on.edge.norm3', 'percent.of.edge3',
						'percent.on.edge.bin4', 'percent.on.edge.norm4', 'percent.of.edge4',
						'percent.on.edge.bin5', 'percent.on.edge.norm5', 'percent.of.edge5',
						'percent.on.mask01.bin', 'percent.on.mask01.norm', 'percent.of.mask01', 'cc01a', 'cc01b', 'cc01c',
						'percent.on.mask02.bin', 'percent.on.mask02.norm', 'percent.of.mask02', 'cc02a', 'cc02b', 'cc02c',
						'percent.on.mask03.bin', 'percent.on.mask03.norm', 'percent.of.mask03', 'cc03a', 'cc03b', 'cc03c',
						'percent.on.mask11.bin', 'percent.on.mask11.norm', 'percent.of.mask11', 'cc11a', 'cc11b', 'cc11c',
						'percent.on.mask12.bin', 'percent.on.mask12.norm', 'percent.of.mask12', 'cc12a', 'cc12b', 'cc12c',
						'percent.on.mask13.bin', 'percent.on.mask13.norm', 'percent.of.mask13', 'cc13a', 'cc13b', 'cc13c',
						'percent.on.mask21.bin', 'percent.on.mask21.norm', 'percent.of.mask21', 'cc21a', 'cc21b', 'cc21c',
						'percent.on.mask22.bin', 'percent.on.mask22.norm', 'percent.of.mask22', 'cc22a', 'cc22b', 'cc22c',
						'percent.on.mask23.bin', 'percent.on.mask23.norm', 'percent.of.mask23', 'cc23a', 'cc23b', 'cc23c',
						'percent.on.mask31.bin', 'percent.on.mask31.norm', 'percent.of.mask31', 'cc31a', 'cc31b', 'cc31c',
						'percent.on.mask32.bin', 'percent.on.mask32.norm', 'percent.of.mask32', 'cc32a', 'cc32b', 'cc32c',
						'percent.on.mask33.bin', 'percent.on.mask33.norm', 'percent.of.mask33', 'cc33a', 'cc33b', 'cc33c',
						'stripe.patt',
						'xlen', 'ylen', 'zlen', 'tlen', 'xres', 'yres', 'zres', 'tres',
						# class label
						'class.labs')
features.types <- c(0, rep(1, 45), rep(2, 27), rep(1, 3), rep(2, 102), rep(2, 3), rep(1, 1), rep(2, 3), rep(1, 1), 0)

# create the final the data.frame for the read data
hcp.data <- train.mat
# make sure all features are numeric (e.g., not categorical)
for(i in c(1:dim(hcp.data)[2]))	
	hcp.data[,i] <- as.numeric(hcp.data[,i])
names(hcp.data) <- features.names
num.ics <- dim(hcp.data)[1]
hcp.data$class.labs <- factor(hcp.data$class.labs)
# any features that we would like to drop/exclude?
init.keep.list <- c(1:187)
hcp.data <- hcp.data[, init.keep.list]
features.types <- features.types[init.keep.list]
# any features that we have to drop/exclude (for they have 0 variance)?
also.excl <- as.numeric(which(apply(hcp.data, 2, var)==0))
if (length(also.excl)) {
	hcp.data <- hcp.data[,-also.excl]
	features.types <- features.types[-also.excl]
}
# update things for the remaining features
features.names <- names(hcp.data)
num.ic <- dim(hcp.data)[1]
num.feat <- dim(hcp.data)[2]-1

# select usign F score
f.vec <- c(1:(dim(hcp.data)[2]-1))
for(i in c(1:(dim(hcp.data)[2]-1))){
	f.vec[i] = calcFScore(hcp.data, i)
}
f.vec[is.nan(f.vec)] <- min(f.vec[!is.nan(f.vec)])

# select usign Kruskal test
data.train.pval.vec <- apply(hcp.data[,-dim(hcp.data)[2]], 2, function(x){kruskal.test(x, as.numeric(hcp.data$class.labs))$p.value})
p.vec <- -log10(data.train.pval.vec)
p.vec[is.nan(p.vec)] <- 0

# select using single glm
uni.glm.log10pvals <- lapply(c(2:dim(hcp.data)[2])-1, function(x){	glm.fit <- glm(hcp.data[,dim(hcp.data)[2]] ~ hcp.data[,x], family = binomial(link = "logit"))
	                                        						coef.ps <- -log10(as.numeric(summary(glm.fit)$coefficients[-1,4]))
	                                        						coef.ps})
uni.glm.log10pvals <- as.numeric(uni.glm.log10pvals)
uni.glm.log10pvals[is.na(uni.glm.log10pvals)] <- 0
p.glm <- uni.glm.log10pvals

# select using linear svm
lin.svm.weights <- calcLinSVMWeights(hcp.data)
w.svm <- abs(as.numeric(lin.svm.weights))

# select using all
thr.fsc <- quantile(f.vec, q.thr)
thr.krs <- quantile(p.vec, q.thr)
thr.glm <- quantile(p.glm, q.thr)
thr.svm <- quantile(w.svm, q.thr)
selected.features <- (f.vec > thr.fsc) | (p.vec > thr.krs) | (p.glm > thr.glm) | (w.svm > thr.svm)

# apply the feature selection
hcp.data.sub <- hcp.data[, c(selected.features, TRUE)]
num.feat.sub <- dim(hcp.data.sub)[2]-1

# create spatial and temporal data
hcp.data.temporal <- hcp.data[,features.types!=2]
hcp.data.spatial <- hcp.data[,features.types!=1]

# and the same for the selected features
hcp.data.sub.temporal <- hcp.data[, features.types!=2 & c(selected.features, TRUE)]
hcp.data.sub.spatial <- hcp.data[, features.types!=1 & c(selected.features, TRUE)]


# # (1)
train.data <- hcp.data
# SVM
svm.rbf1 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "radial")
svm.rbf.prd1 <- attributes(predict(svm.rbf1, train.data, probability=T))$probabilities[,2]
svm.lin1 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "linear")
svm.lin.prd1 <- attributes(predict(svm.lin1, train.data, probability=T))$probabilities[,2]
svm.pol1 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "polynomial")
svm.pol.prd1 <- attributes(predict(svm.pol1, train.data, probability=T))$probabilities[,2]
# KNN
tmp <- knn(train.data[,-dim(train.data)[2]], train.data[,-dim(train.data)[2]], train.data[,dim(train.data)[2]], k = k.knn, prob = T)
knn.train1 <- attributes(tmp)
knn.train1$prob[tmp==0] <- 1-knn.train1$prob[tmp==0]
# CTREE
ctree1 <- ctree(class.labs ~ ., data = train.data, controls = ctree_control(minbucket = 10, mincriterion = 0.95))
ctree.prd.train1 <- treeresponse(ctree1, newdata = train.data)
ctree.prob.train1 <- c(1:length(ctree.prd.train1))
for(i in c(1:length(ctree.prd.train1))){ctree.prob.train1[i] <- ctree.prd.train1[[i]][2]}
# GLM
#glm.fit01 <- glm(class.labs ~ ., data = train.data, family = binomial(link = "logit"))
#glm.fit02 <- step(glm.fit01, trace = 0)

	
# # (2)
train.data <- hcp.data.sub
# SVM
svm.rbf2 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "radial")
svm.rbf.prd2 <- attributes(predict(svm.rbf2, train.data, probability=T))$probabilities[,2]
svm.lin2 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "linear")
svm.lin.prd2 <- attributes(predict(svm.lin2, train.data, probability=T))$probabilities[,2]
svm.pol2 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "polynomial")
svm.pol.prd2 <- attributes(predict(svm.pol2, train.data, probability=T))$probabilities[,2]
# KNN
tmp <- knn(train.data[,-dim(train.data)[2]], train.data[,-dim(train.data)[2]], train.data[,dim(train.data)[2]], k = k.knn, prob = T)
knn.train2 <- attributes(tmp)
knn.train2$prob[tmp==0] <- 1-knn.train2$prob[tmp==0]
# CTREE
ctree2 <- ctree(class.labs ~ ., data = train.data, controls = ctree_control(minbucket = 10, mincriterion = 0.95))
ctree.prd.train2 <- treeresponse(ctree2, newdata = train.data)
ctree.prob.train2 <- c(1:length(ctree.prd.train2))
for(i in c(1:length(ctree.prd.train2))){ctree.prob.train2[i] <- ctree.prd.train2[[i]][2]}

	
# # (3)
train.data <- hcp.data.temporal
# SVM
svm.rbf3 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "radial")
svm.rbf.prd3 <- attributes(predict(svm.rbf3, train.data, probability=T))$probabilities[,2]
svm.lin3 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "linear")
svm.lin.prd3 <- attributes(predict(svm.lin3, train.data, probability=T))$probabilities[,2]
svm.pol3 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "polynomial")
svm.pol.prd3 <- attributes(predict(svm.pol3, train.data, probability=T))$probabilities[,2]
# KNN
tmp <- knn(train.data[,-dim(train.data)[2]], train.data[,-dim(train.data)[2]], train.data[,dim(train.data)[2]], k = k.knn, prob = T)
knn.train3 <- attributes(tmp)
knn.train3$prob[tmp==0] <- 1-knn.train3$prob[tmp==0]
# CTREE
ctree3 <- ctree(class.labs ~ ., data = train.data, controls = ctree_control(minbucket = 10, mincriterion = 0.95))
ctree.prd.train3 <- treeresponse(ctree3, newdata = train.data)
ctree.prob.train3 <- c(1:length(ctree.prd.train3))
for(i in c(1:length(ctree.prd.train3))){ctree.prob.train3[i] <- ctree.prd.train3[[i]][2]}


# # (4)
train.data <- hcp.data.spatial
# SVM
svm.rbf4 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "radial")
svm.rbf.prd4 <- attributes(predict(svm.rbf4, train.data, probability=T))$probabilities[,2]
svm.lin4 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "linear")
svm.lin.prd4 <- attributes(predict(svm.lin4, train.data, probability=T))$probabilities[,2]
svm.pol4 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "polynomial")
svm.pol.prd4 <- attributes(predict(svm.pol4, train.data, probability=T))$probabilities[,2]
# KNN
tmp <- knn(train.data[,-dim(train.data)[2]], train.data[,-dim(train.data)[2]], train.data[,dim(train.data)[2]], k = k.knn, prob = T)
knn.train4 <- attributes(tmp)
knn.train4$prob[tmp==0] <- 1-knn.train4$prob[tmp==0]
# CTREE
ctree4 <- ctree(class.labs ~ ., data = train.data, controls = ctree_control(minbucket = 10, mincriterion = 0.95))
ctree.prd.train4 <- treeresponse(ctree4, newdata = train.data)
ctree.prob.train4 <- c(1:length(ctree.prd.train4))
for(i in c(1:length(ctree.prd.train4))){ctree.prob.train4[i] <- ctree.prd.train4[[i]][2]}


# # (5)
train.data <- hcp.data.sub.temporal
# SVM
svm.rbf5 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "radial")
svm.rbf.prd5 <- attributes(predict(svm.rbf5, train.data, probability=T))$probabilities[,2]
svm.lin5 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "linear")
svm.lin.prd5 <- attributes(predict(svm.lin5, train.data, probability=T))$probabilities[,2]
svm.pol5 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "polynomial")
svm.pol.prd5 <- attributes(predict(svm.pol5, train.data, probability=T))$probabilities[,2]
# KNN
tmp <- knn(train.data[,-dim(train.data)[2]], train.data[,-dim(train.data)[2]], train.data[,dim(train.data)[2]], k = k.knn, prob = T)
knn.train5 <- attributes(tmp)
knn.train5$prob[tmp==0] <- 1-knn.train5$prob[tmp==0]
# CTREE
ctree5 <- ctree(class.labs ~ ., data = train.data, controls = ctree_control(minbucket = 10, mincriterion = 0.95))
ctree.prd.train5 <- treeresponse(ctree5, newdata = train.data)
ctree.prob.train5 <- c(1:length(ctree.prd.train5))
for(i in c(1:length(ctree.prd.train5))){ctree.prob.train5[i] <- ctree.prd.train5[[i]][2]}


# # (6)
train.data <- hcp.data.sub.spatial
# SVM
svm.rbf6 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "radial")
svm.rbf.prd6 <- attributes(predict(svm.rbf6, train.data, probability=T))$probabilities[,2]
svm.lin6 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "linear")
svm.lin.prd6 <- attributes(predict(svm.lin6, train.data, probability=T))$probabilities[,2]
svm.pol6 <- svm(class.labs ~ ., data = train.data, probability = T, scale = T, kernel = "polynomial")
svm.pol.prd6 <- attributes(predict(svm.pol6, train.data, probability=T))$probabilities[,2]
# KNN
tmp <- knn(train.data[,-dim(train.data)[2]], train.data[,-dim(train.data)[2]], train.data[,dim(train.data)[2]], k = k.knn, prob = T)
knn.train6 <- attributes(tmp)
knn.train6$prob[tmp==0] <- 1-knn.train6$prob[tmp==0]
# CTREE
ctree6 <- ctree(class.labs ~ ., data = train.data, controls = ctree_control(minbucket = 10, mincriterion = 0.95))
ctree.prd.train6 <- treeresponse(ctree6, newdata = train.data)
ctree.prob.train6 <- c(1:length(ctree.prd.train6))
for(i in c(1:length(ctree.prd.train6))){ctree.prob.train6[i] <- ctree.prd.train6[[i]][2]}


# # fuse the train results
labs <- train.data$class.labs
df.train.tmp <- data.frame(knn6 = knn.train6$prob,
                           tre6 = ctree.prob.train6,
                           rbf6 = svm.rbf.prd6,
                           lin6 = svm.lin.prd6,
                           pol6 = svm.pol.prd6,
                           knn5 = knn.train5$prob,
                           tre5 = ctree.prob.train5,
                           rbf5 = svm.rbf.prd5,
                           lin5 = svm.lin.prd5,
                           pol5 = svm.pol.prd5,
                           knn4 = knn.train4$prob,
                           tre4 = ctree.prob.train4,
                           rbf4 = svm.rbf.prd4,
                           lin4 = svm.lin.prd4,
                           pol4 = svm.pol.prd4,
                           knn3 = knn.train3$prob,
                           tre3 = ctree.prob.train3,
                           rbf3 = svm.rbf.prd3,
                           lin3 = svm.lin.prd3,
                           pol3 = svm.pol.prd3,
                           knn2 = knn.train2$prob,
                           tre2 = ctree.prob.train2,
                           rbf2 = svm.rbf.prd2,
                           lin2 = svm.lin.prd2,
                           pol2 = svm.pol.prd2,
                           knn1 = knn.train1$prob,
                           tre1 = ctree.prob.train1,
                           rbf1 = svm.rbf.prd1,
                           lin1 = svm.lin.prd1,
                           pol1 = svm.pol.prd1,                           
                           class.labs = labs
                           )
df.train.stat <- df.train.tmp

if(F){ # TREE, which.fix=='T'
	fusion.tree <- ctree(class.labs ~ ., data = df.train.stat, controls = ctree_control(minbucket = 5, mincriterion = 0.9))
	fusion.tree.prd.trainp <- simplify2array(treeresponse(fusion.tree, newdata = df.train.stat))[2,]
}

if(T){ # RF, which.fix=='F'
	fusion.tree <- randomForest(class.labs ~ ., data = df.train.stat)
	fusion.tree.prd.trainp <- predict(fusion.tree, newdata = df.train.stat, type="prob")[,2]
}

if(F){ # SVM, RBF, which.fix=='R'
	fusion.tree <- svm(class.labs ~ ., data = df.train.stat, probability = T, scale = T, kernel = "radial")
	fusion.tree.prd.trainp <- attributes(predict(fusion.tree, newdata = df.train.stat, probability=T))$probabilities
  	fusion.tree.prd.trainp <- fusion.tree.prd.trainp[,which(colnames(fusion.svmr.prd.trainp)=='1')]
}

if(F){ # SVM, LIN, which.fix=='L'
	fusion.tree <- svm(class.labs ~ ., data = df.train.stat, probability = T, scale = T, kernel = "linear")
	fusion.tree.prd.trainp <- attributes(predict(fusion.tree, newdata = df.train.stat, probability=T))$probabilities
  	fusion.tree.prd.trainp <- fusion.tree.prd.trainp[,which(colnames(fusion.svmr.prd.trainp)=='1')]
}


# # do some performance assessment
# TPR, TNR
acc.tmp <- doAccuracyAnalysis(labs, fusion.tree.prd.trainp>=.5)
train.tpr50 <- acc.tmp[2]
train.tnr50 <- acc.tmp[3]
acc.tmp <- doAccuracyAnalysis(labs, fusion.tree.prd.trainp>=.4)
train.tpr40 <- acc.tmp[2]
train.tnr40 <- acc.tmp[3]
acc.tmp <- doAccuracyAnalysis(labs, fusion.tree.prd.trainp>=.3)
train.tpr30 <- acc.tmp[2]
train.tnr30 <- acc.tmp[3]
acc.tmp <- doAccuracyAnalysis(labs, fusion.tree.prd.trainp>=.2)
train.tpr20 <- acc.tmp[2]
train.tnr20 <- acc.tmp[3]
acc.tmp <- doAccuracyAnalysis(labs, fusion.tree.prd.trainp>=.1)
train.tpr10 <- acc.tmp[2]
train.tnr10 <- acc.tmp[3]

# ROC
pred <- prediction(fusion.tree.prd.trainp, train.data$class.labs)
train.auc <- attributes(performance(pred, 'auc'))$y.values[[1]]
df <- data.frame(thresh = c('thr=10', 'thr=20', 'thr=30', 'thr=40', 'thr=50'),
                 TPR = c(train.tpr10, train.tpr20, train.tpr30, train.tpr40, train.tpr50),
                 TNR = c(train.tnr10, train.tnr20, train.tnr30, train.tnr40, train.tnr50)
                 )
print(train.auc)
print(df)

test.features.names <- features.names[-length(features.names)]
test.features.types <- features.types[-length(features.names)]

save(file = weight.file.name,
     also.excl, init.keep.list,
     hcp.data, hcp.data.temporal, hcp.data.spatial,
     hcp.data.sub, hcp.data.sub.temporal, hcp.data.sub.spatial,
     k.knn,
     selected.features,
     svm.rbf1, svm.lin1, svm.pol1, ctree1,
     svm.rbf2, svm.lin2, svm.pol2, ctree2,
     svm.rbf3, svm.lin3, svm.pol3, ctree3,
     svm.rbf4, svm.lin4, svm.pol4, ctree4,
     svm.rbf5, svm.lin5, svm.pol5, ctree5,
     svm.rbf6, svm.lin6, svm.pol6, ctree6,
     fusion.tree,
     train.tpr50, train.tnr50,
     train.tpr20, train.tnr20,
     train.tpr10, train.tnr10,
     test.features.types, test.features.names
     )

