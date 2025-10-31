#set working data year and Nephrops database
survey.year<- 2025
catch.year<- 2024

#working directories
mkdir("output")
outdir<- "output/"
datadir<- "data/"
modeldir<- "model/"

#Clear files from outdir directories
unlink(list.files(outdir, full.names = T, recursive = T))

file.copy(paste0(datadir,"nephup.mf.",catch.year,".rdata"), outdir, overwrite=T)
file.copy(paste0(datadir, c("international.landings.csv","moray firth_TV_results_bias_corrected.csv","Mean weights in landings.csv")), outdir, overwrite=T)
file.copy(paste0(modeldir, c("moray firth_Exploitation summary.csv")), outdir, overwrite=T)
plots.advice(wk.dir = outdir,
             f.u="moray firth", MSY.hr = HR["Fmsy"],stock.object=nephup.mf,
             international.landings = "international.landings.csv",
             tv_results = "moray firth_TV_results_bias_corrected.csv",
             Exploitation_summary = "moray firth_Exploitation summary.csv")
