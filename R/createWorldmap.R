library(rworldmap)

#ddf<-read.table('data/cluster_assign4.csv',sep=',',header=TRUE,)

ddf<-read.csv('figure3Data/cos_rat.csv',sep=',',header=TRUE)

ddf[,2]<-rowSums(ddf[,2:3])


#ddf$X<-rownames(ddf)




#pdf('file.pdf',width=6,height=4,paper='special') 



spdf <- joinCountryData2Map(ddf, joinCode="NAME", nameJoinColumn="X",verbos=TRUE)



mapDevice('x11')
mapParams <-mapCountryData( spdf, nameColumnToPlot="OPN", catMethod="fixedWidth", numCats=300,
         addLegend='TRUE', mapTitle="")

#do.call( addMapLegend, c(mapParams, legendWidth=0.5, legendMar = 2, legendLabels="none"))


outputPlotType ='png'
savePlot('world_map',type=outputPlotType) #end of month loopclose.ncdf(nc) #closing the ncdf file
