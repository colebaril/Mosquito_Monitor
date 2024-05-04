# Mosquito Monitor  <img src='mosquito_monitor_hexsticker.png' align="right" height="210" />

[![](https://img.shields.io/badge/Shiny-shinyapps.io-blue?style=flat&labelColor=white&logo=RStudio&logoColor=blue)](https://colewb.shinyapps.io/Mosquito_Monitor/) ![](https://img.shields.io/badge/Status-In_Development-purple) ![](https://img.shields.io/badge/Build-Functional-green) ![](https://img.shields.io/badge/Version-0.0.1-orange)

I developed a workflow and app that, in conjunction, collects mosquito trap data from government sources, stores historical data, and displays data in a digestable format. The current data for nuissance mosquito trap counts displayed on the City of Winnipeg website is not entirely readable and only contains data for a single day at a time, which doesn't allow for visualizing trends. 

# Workflow 

Everyday, a workflow runs via GitHub Actions. This workflow scrapes data from various sources, cleans the data and appends metadata. The resulting file is saved as `mosquito_data.rds` in this repository and may be downloaded from the app by navigating to the `Data` tab and clicking either the `csv` or `Excel` buttons. 

# App 

A shiny app reads the `mosquito_data.rds` file and displays summary tables and figures. 

# In Development

I am currently working on ways to incorporate AFA analyses into the data and app, which is a calculation based on soil moisuture conditions, forecasted rainfall, trap counts, temperature and status of larval development sites. The City of Winnipeg monitors these factors, but only presents a static figure on their website. 

# Disclaimer

This application is not affiliated with, endorsed by, or sponsored by the City of Winnipeg, City of Brandon, or Government of Manitoba. All data utilized in this application is obtained from publicly available sources provided by the City of Winnipeg, City of Brandon and Manitoba Government. The creators of this application do not claim ownership of the data provided by the City of Winnipeg, City of Brandon or the Manitoba Government and do not assume responsibility for the accuracy or completeness of the data. Users of this application should verify any information obtained from this application with official sources.

# Data

The City of Brandon publishes their historical data annually on their website. However, the City of Winnipeg does not. I have submitted an access to information request for all historical data for use in this app, however I expect this process will take a long time. Similarly, the Manitoba Government does not post any historical trapping data for provincial traps on their website, only the number of *Culex tarsalis* specimens identified. If you have any sources of data you wish to contribute, please email me at cole@colebaril.ca. 

# References 

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

City of Winnipeg (2024). _Nuisance Mosquito Trap Counts_. <https://legacy.winnipeg.ca/publicworks/insectcontrol/mosquitoes/trapcounts.stm>.
