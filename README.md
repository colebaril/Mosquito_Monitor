# Mosquito Monitor  <img src='mosquito_monitor_hexsticker.png' align="right" height="210" />

[![](https://img.shields.io/badge/Shiny-shinyapps.io-blue?style=flat&labelColor=white&logo=RStudio&logoColor=blue)](https://colewb.shinyapps.io/Mosquito_Monitor/) ![](https://img.shields.io/badge/Status-In_Development-purple) ![](https://img.shields.io/badge/Build-Functional-green) ![](https://img.shields.io/badge/Version-0.0.2-orange)

I developed an [automated workflow](https://github.com/colebaril/Mosquito_Monitor/blob/main/.github/workflows/) and [Shiny App](https://colewb.shinyapps.io/Mosquito_Monitor/) that, in conjunction, collects mosquito trap data from government sources, stores historical data, and displays data in a digestable format. Historical data for the City of Brandon, City of Winnipeg and Western Manitoba will be displayed in addition to daily updates on City of Winnipeg and City of Brandon trap counts. 

# Version 0.0.2

- Introduced a map of Winnipeg displaying the number of specimens caught in each zone separated by Forward Sortation Area
- Introduced comparable weather data along with City of Winnipeg historical trapping data (e.g., temperature, precipitation)

# Workflow 

A scheduled workflow runs via GitHub Actions. This workflow scrapes data from various sources including the City of Winnipeg and City of Brandon websites. The workflow then cleans the data and appends metadata. The resulting file is saved as `mosquito_data.rds` in this repository and may be downloaded from the app by navigating to the `Data` tab and clicking either the `csv` or `Excel` buttons. 

# App 

A shiny app reads the `mosquito_data.rds` file remotely and displays summary tables, figures and downloadable data. Weather data was obtained from [Environment and Climate Change Canada's Winnipeg A CS Weather Station](https://climate.weather.gc.ca/climate_data/hourly_data_e.html?hlyRange=2013-12-10%7C2024-05-26&dlyRange=1996-10-01%7C2024-05-26&mlyRange=1996-10-01%7C2007-11-01&StationID=27174&Prov=MB&urlExtension=_e.html&searchType=stnName&optLimit=yearRange&StartYear=1840&EndYear=2024&selRowPerPage=25&Line=0&searchMethod=contains&Month=5&Day=26&txtStationName=Winnipeg&timeframe=1&Year=2024) using the [weathercan package](https://github.com/ropensci/weathercan). The map of Winnipeg was constructed using data obtained from [Statistics Canada Boundary Files](https://www12.statcan.gc.ca/census-recensement/2021/geo/sip-pis/boundary-limites/index2021-eng.cfm?Year=21) and constructed using the [sf package](https://cran.r-project.org/web/packages/sf/index.html). 

#  Historic Metadata Analysis 

## City of Winnipeg 

## City of Brandon 

# Disclaimer

This application is not affiliated with, endorsed by, or sponsored by the City of Winnipeg, City of Brandon, or Government of Manitoba. All data utilized in this application is obtained from publicly available sources provided by the City of Winnipeg, City of Brandon and Manitoba Government. The creators of this application do not claim ownership of the data provided by the City of Winnipeg, City of Brandon or the Manitoba Government and do not assume responsibility for the accuracy or completeness of the data. Users of this application should verify any information obtained from this application with official sources.

# Data

The City of Brandon and City of Winnipeg publishes their historical data annually on their websites. The Manitoba Government does not post any historical trapping data for provincial traps on their website, only the number of *Culex tarsalis* specimens identified. If you have any sources of data you wish to contribute, please email me at cole@colebaril.ca. 

# References 

Baril, C., Pilling, B.G., Mikkelsen, M.J. et al. The influence of weather on the population dynamics of common mosquito vector species in the Canadian Prairies. _Parasites Vectors 16_, 153 (2023). <https://doi.org/10.1186/s13071-023-05760-x>. 

City of Winnipeg (2024). _Nuisance Mosquito Trap Counts_. <https://legacy.winnipeg.ca/publicworks/insectcontrol/mosquitoes/trapcounts.stm>.

City of Brandon (2024). _Mosquito Abatement Program_. <https://brandon.ca/mosquito-abatement/mosquito-abatement-program>. 

Wickham H, Averick M, Bryan J, Chang W, McGowan LD, François R, Grolemund G, Hayes A, Henry L, Hester J, Kuhn M, Pedersen TL, Miller E, Bache
SM, Müller K, Ooms J, Robinson D, Seidel DP, Spinu V, Takahashi K, Vaughan D, Wilke C, Woo K, Yutani H (2019). “Welcome to the tidyverse.”
_Journal of Open Source Software_, *4*(43), 1686. doi:10.21105/joss.01686 <https://doi.org/10.21105/joss.01686>.

Wickham H (2024). _rvest: Easily Harvest (Scrape) Web Pages_. R package version 1.0.4, <https://CRAN.R-project.org/package=rvest>.

Chang W, Cheng J, Allaire J, Sievert C, Schloerke B, Xie Y, Allen J, McPherson J, Dipert A, Borges B (2023). _shiny: Web Application Framework
for R_. R package version 1.8.0, <https://CRAN.R-project.org/package=shiny>.

Firke S (2023). _janitor: Simple Tools for Examining and Cleaning Dirty Data_. R package version 2.2.0,
<https://CRAN.R-project.org/package=janitor>.

Grolemund G, Wickham H (2011). “Dates and Times Made Easy with lubridate.” _Journal of Statistical Software_, *40*(3), 1-25.
<https://www.jstatsoft.org/v40/i03/>.

Xie Y, Cheng J, Tan X (2023). _DT: A Wrapper of the JavaScript Library 'DataTables'_. R package version 0.31,
<https://CRAN.R-project.org/package=DT>.

Chang W (2021). _shinythemes: Themes for Shiny_. R package version 1.2.0, <https://CRAN.R-project.org/package=shinythemes>.


