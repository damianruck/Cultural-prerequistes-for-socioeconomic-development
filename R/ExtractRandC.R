library('psych')

D<-read.csv('data/WEVS',sep=',',header=TRUE)
D<-D[,2:dim(D)[2]] #remove the index column

#only run weighted PCA on cultural value questions (remove demographic questions)
cols <- c('A001', 'A002', 'A003', 'A004', 'A005', 'A006', 'A008', 'A009',
       'A029', 'A030', 'A032', 'A034', 'A035', 'A038', 'A039', 'A040',
       'A041', 'A042', 'A124_02', 'A124_03', 'A124_06', 'A124_07',
       'A124_08', 'A124_09', 'A165', 'A170', 'A173', 'C001', 'C002',
       'D057', 'E018', 'E004' ,'E023', 'E025', 'E026', 'E027', 'E033', 'E035',
       'E036', 'E037', 'E039', 'E069_01', 'E069_02', 'E069_04', 'E069_05',
       'E069_06', 'E069_07', 'E069_08', 'E069_11', 'E069_12', 'E069_13', 'E069_18',
      'E179', 'F025', 'F028', 'F034', 'F063', 'F114', 'F115', 'F116', 'F117', 'F118',
       'F119', 'F120', 'F121', 'F122', 'F123', 'G006')

print(length(cols))

demographic <- D[ , !(names(D) %in% cols)]

D <- D[,cols]



fitEFA <- fa(D, nfactors=9, rotate='oblimin',fm='ml')
factors <- fitEFA$scores
#name cultural factors
colnames(factors) <- c('SEC','CON','INV','PRO','WEL','VIO','ENG','POL','OUT')

fitPCA <- principal(factors, nfactors=3)
components <- fitPCA$scores[,1:2] #we're only interested in the first two components
colnames(components) <- c('RAT','COS')


#save correlated factors, orthogonal compooents and demogroahic information
df <- cbind(factors,components,demographic)
write.table(df,'data/compressedWEVS',sep=',')


