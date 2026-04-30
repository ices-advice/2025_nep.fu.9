#set working data year and Nephrops database
survey.year<- 2025
catch.year<- 2024

#working directories
mkdir("report")
reportdir<- "report/"
outdir<- "output/"

#Clear files from outdir directories
unlink(list.files(reportdir, full.names = T, recursive = T))

#load stock object
load(paste0(outdir,"nephup.mf.",catch.year,".rdata"))

##############################################################################################

#Calculate mean sizes and create time series plot
mean.length <-mean.sizes(nephup.mf)
plot.mean.sizes(reportdir,nephup.mf,mean.length)

##following script produces mean size trends male/female  as per Ewen
#  set up df for LF plot - the tables which are output are incorrect - uses 
# lower bound to calculate mean length
tmp <-FLCore::trim(nephup.mf,year=2000:catch.year)
disc <-as.data.frame(seasonSums(tmp@discards.n))
catch <-as.data.frame(seasonSums(tmp@catch.n))
land <-as.data.frame(seasonSums(tmp@landings.n))

#Year, Sex, Length, Landings, Discards, Catch
LF.data.frame <-data.frame(Year=disc$year,Sex=disc$unit,
                           Length=disc$lengths,Landings=land$data,Discards=disc$data,
                           Catch=catch$data)
png(paste0(reportdir, "LFD_MF.png"),width = 800, height = 1000)
plot.ld(LF.data.frame,"FU 9",range(tmp,'minyear'),range(tmp,'maxyear'),25,35)
dev.off()

# Could use this instead 
catch.ldist.plot(flneph.object = nephup.mf, years=c(2000,catch.year), extra.space=3)
length.freq.dist(neph.object = nephup.mf, av.years = c(catch.year))

#WGNSSK agreed LF plot for advice sheets
#prepare data frame format
CatchLDsYr<- LF.data.frame
CatchLDsYr$Discards<- NULL #remove discard column as not needed
names(CatchLDsYr)<- c("Year","Sex","Length","LandNaL","CatchNaL") # rename fields
CatchLDsYr$Sex<- substr(CatchLDsYr$Sex,1,1)# Take the first letter (either M or F) from Sex ("Male" and "Female") for NEP_LD_plot_ICES function
#Run new function. Output goes to reportdir
NEP_LD_plot_ICES(df=subset(CatchLDsYr,CatchNaL>0), FU="9", FUMCRS=25, RefLth=35, out.dir=reportdir)

#Plot landings and quartery landings
nephup.quarterly.plots(reportdir,tmp, nephort.mf$days)

#Sex ratio plot
sex.ratio.plot(wdir=reportdir, stock.obj=nephup.mf, print.output=F, type="year")
sex.ratio.plot(wdir=reportdir, stock.obj=tmp, print.output=F, type="quarter")

#Landings long term plot
nephup.long.term.plots_kw_effort_aggregated(outdir,stock=nephup.mf,effort.data.days=nephort.mf$days, effort.data.kwdays=nephort.mf$kwdays,
                                            international=T,international.landings="international.landings.csv", output.dir=reportdir)
