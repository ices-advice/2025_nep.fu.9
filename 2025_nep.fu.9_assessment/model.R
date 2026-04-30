#set working data year and Nephrops database
survey.year<- 2025
catch.year<- 2024

#working directories
mkdir("model")
modeldir<- "model/"
datadir<- "data/"

#Clear files from modeldir directories
unlink(list.files(modeldir, full.names = T, recursive = T))

#Latest advice given (in tonnes)
latest.advice<- c(884,884) #884 tonnes catch advice given in 2024 for 2025.


#FORECAST
########################################################################################
##Forecast for next year using the lastest survey point
survey<- paste(datadir, "moray firth", "_TV_results.csv", sep="")
international<- paste0(datadir, "international.landings.csv")

# Creates an exploitation table for the years in the survey file which can be 1 year more than in the
# landings and stock object (for an autumn advice)
#exploitation.table.2014(wk.dir = paste(Wkdir, "fishstats", sep=""), f.u = "fladen", stock.object=nephup.fl, international.landings = international, survey=survey)
exploitation.table(wk.dir = modeldir, f.u = "moray firth", stock.object=nephup.mf, international.landings = international, survey=survey)

#September 2021: No HR available for 2020 dur to no survey in 2020. Calculating HR2020 based on Average abundance (2019,2021).
exp.tab.mf<- read.csv(paste0(modeldir, "moray firth_Exploitation summary.csv"))
R2020<- exp.tab.mf[exp.tab.mf$year %in% "2020","removals.numbers"]
AV_AB2019_2021<- mean(exp.tab.mf[exp.tab.mf$year %in% c("2019","2021"),"adjusted.abundance"])
F2020<- R2020/AV_AB2019_2021*100
exp.tab.mf[exp.tab.mf$year %in% "2020","harvest.ratio"]<- F2020
write.csv(exp.tab.mf,paste0(modeldir, "moray firth_Exploitation summary.csv"), row.names=F)

data.yr<- catch.year
av.yrs<- (catch.year-2):catch.year  #last 3 years
#Flower added to list of HRs (EU request to provide Fmsy ranges for selected North Sea and Baltic Sea stocks)
HR<- list(
  Flower=9.1,
  Fmsy = 11.8,
  F0.1 = 7.8,
  Fmax = 14.9,
  #  Fyear = exp.tab.mf[exp.tab.mf$year==data.yr,"harvest.ratio"],
  #  Fav.yrs = round(mean(exp.tab.mf[exp.tab.mf$year %in% av.yrs,"harvest.ratio"]), 1)
  Fyear = exp.tab.mf[exp.tab.mf$year==data.yr,"harvest.ratio"],
  Fav.yrs = round(mean(exp.tab.mf[exp.tab.mf$year %in% av.yrs,"harvest.ratio"]), 1)
)

HR<- sapply(HR, as.vector)
#Flow<- 9.1
#extra.options<- unique(c(seq(floor(min(HR)), ceiling(max(HR)), by=1), seq(Flow, HR[names(HR)=="Fmsy"], by=0.1))); extra.options<- extra.options[!extra.options %in% HR]
#HR<- c(HR, extra.options)
HR<- c(HR[names(HR) %in% "Fmsy"],sort(HR[!names(HR) %in% "Fmsy"]))
# names(HR)[which(names(HR) %in% "Fyear")]<- paste0("F",data.yr)
# names(HR)[which(names(HR) %in% "Fav.yrs")]<- paste0("F",av.yrs[1],"_",av.yrs[3])
#September 2021: No HR available for 2020. Using 2019 for Fyear and 2017-2019 for HR average
names(HR)[which(names(HR) %in% "Fyear")]<- paste0("F",data.yr)
names(HR)[which(names(HR) %in% "Fav.yrs")]<- paste0("F",av.yrs[1],"_",av.yrs[3])

#Forecast table as required by WGNSSK 2017
file.copy(paste0(datadir, c("Mean_weights.csv")), modeldir, overwrite=T)
forecast.table.WGNSSK(wk.dir = modeldir,
                      fu="FU9",hist.sum.table = "moray firth_Exploitation summary.csv",
                      mean.wts="Mean_weights.csv",
                      land.wt.yrs=av.yrs, disc.wt.yrs=av.yrs, disc.rt.yrs=av.yrs, 
                      h.rates=HR, d.surv =25, latest.advice=latest.advice)
