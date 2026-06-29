# Mosquito Monitor  

<img src='mosquito_monitor_hexsticker.png' align="right" height="210" />

[![](https://img.shields.io/badge/Shiny-shinyapps.io-blue?style=flat&labelColor=white&logo=RStudio&logoColor=blue)](https://colewb.shinyapps.io/Mosquito_Monitor/) 
![](https://img.shields.io/badge/Status-Active-green) 
![](https://img.shields.io/badge/Version-0.0.6-orange)
![Last Commit](https://img.shields.io/github/last-commit/colebaril/Mosquito_Monitor)
[![Follow on X](https://img.shields.io/badge/X-Follow-blue?logo=x&logoColor=white)](https://twitter.com/mosquitomonitor)
[![Follow on Bluesky](https://img.shields.io/badge/Bluesky-Follow-blue?logo=bluesky)](https://bsky.app/profile/mosquitomonitor.bsky.social)
[![Scrape Data](https://github.com/colebaril/Mosquito_Monitor/actions/workflows/scrape_data.yaml/badge.svg)](https://github.com/colebaril/Mosquito_Monitor/actions/workflows/scrape_data.yaml)
[![Scrape Data Brandon](https://github.com/colebaril/Mosquito_Monitor/actions/workflows/scrape_data_bdn.yaml/badge.svg)](https://github.com/colebaril/Mosquito_Monitor/actions/workflows/scrape_data_bdn.yaml)

I developed an [automated workflow](https://github.com/colebaril/Mosquito_Monitor/blob/main/.github/workflows/) and [Shiny App](https://colewb.shinyapps.io/Mosquito_Monitor/) that, in conjunction, collects mosquito trap data from government sources, stores historical data, and displays data in a digestable format. Historical data for the City of Brandon, City of Winnipeg and Western Manitoba will be displayed in addition to daily updates on City of Winnipeg and City of Brandon trap counts. When the data is updated, a Skeet is sent from the [Mosquito Monitor Bluesky Account](https://bsky.app/profile/mosquitomonitor.bsky.social). 

> The City of Brandon stopped updating their mosquito count data. Thus, there is no new data being displayed for 2026. 

# Updates

## Version 0.0.6

- Removed the Twitter bot due to Twitter making the process to use an automated account unnecessarily complicated.
- Converted the City of Winnipeg and Western Manitoba (2020-2021) maps to interactive Leaflet maps.
- Added in a tab to display data from mosquitoes I am collecting from my backyard.

## Version 0.0.5

- Added a Bluesky bot that functions exactly the same as the Twitter bot. Follow [here](https://bsky.app/profile/mosquitomonitor.bsky.social)
- Added a check for no data; this allows the first run of the year to work correctly
- Changed environment timezone to Winnipeg local to improve accuracy of the figure and data processing

## Version 0.0.4

- Identified a bug that causes the figure to be updated before the updated data is committed to the repository, resulting in old data being tweeted. This is likely due to how GitHub Actions handles triggers via commits
   - Added wait times such that the data is up-to-date by the time the scripts to update figures and Tweet runs
- Added a workflow to include City of Brandon mosquito trap counts in both the Shiny application as well as the Twitter account notifications

## Version 0.0.3

- Changed y axis trans to `log1p` for the faceted Winnipeg plots to better display the poisson-like mosquito trap count distributions
- Implemented a Twitter Bot using Python that sends a Tweet with the city map when the data has been updated

## Version 0.0.2

- Introduced a map of Winnipeg displaying the number of specimens caught in each zone separated by Forward Sortation Area
- Introduced comparable weather data along with City of Winnipeg historical trapping data (e.g., temperature, precipitation)

# Citing This Repository

Baril, Cole. (2026). _Mosquito Monitor: An Automated Workflow and Shiny App for Mosquito Trap Data Collection and Visualization_ [Repository]. GitHub. https://github.com/colebaril/Mosquito_Monitor

# Disclaimer

This application is not affiliated with, endorsed by, or sponsored by the City of Winnipeg, City of Brandon, or Government of Manitoba. All data utilized in this application is obtained from publicly available sources provided by the City of Winnipeg, City of Brandon and Manitoba Government. The creators of this application do not claim ownership of the data provided by the City of Winnipeg, City of Brandon or the Manitoba Government and do not assume responsibility for the accuracy or completeness of the data. Users of this application should verify any information obtained from this application with official sources.

# References 

Baril, C., Pilling, B.G., Mikkelsen, M.J. et al. The influence of weather on the population dynamics of common mosquito vector species in the Canadian Prairies. _Parasites Vectors 16_, 153 (2023). <https://doi.org/10.1186/s13071-023-05760-x>. 

City of Winnipeg (2024). _Nuisance Mosquito Trap Counts_. <https://legacy.winnipeg.ca/publicworks/insectcontrol/mosquitoes/trapcounts.stm>.

City of Brandon (2024). _Mosquito Abatement Program_. <https://brandon.ca/mosquito-abatement/mosquito-abatement-program>. 

Environment and Climate Change Canada (2024). _WINNIPEG A CS Weather Station_. <https://climate.weather.gc.ca/climate_data/>. 

R Core Team (2023). _R: A Language and Environment for Statistical Computing_. R Foundation for Statistical Computing, Vienna, Austria.
<https://www.R-project.org/>.

Python Software Foundation. (2024). _Python Language Reference, version 3.10_. Available at https://www.python.org.

Wickham H, Averick M, Bryan J, Chang W, McGowan LD, François R, Grolemund G, Hayes A, Henry L, Hester J, Kuhn M, Pedersen TL, Miller E, Bache
SM, Müller K, Ooms J, Robinson D, Seidel DP, Spinu V, Takahashi K, Vaughan D, Wilke C, Woo K, Yutani H (2019). “Welcome to the tidyverse.”
_Journal of Open Source Software_, *4*(43), 1686. doi:10.21105/joss.01686 <https://doi.org/10.21105/joss.01686>.

Wickham H (2024). _rvest: Easily Harvest (Scrape) Web Pages_. R package version 1.0.4, <https://CRAN.R-project.org/package=rvest>.

Chang W, Cheng J, Allaire J, Sievert C, Schloerke B, Xie Y, Allen J, McPherson J, Dipert A, Borges B (2023). _shiny: Web Application Framework
for R_. R package version 1.8.0, <https://CRAN.R-project.org/package=shiny>.

Pebesma E, Bivand R (2023). _Spatial Data Science: With applications in R_. Chapman and Hall/CRC. doi:10.1201/9780429459016
<https://doi.org/10.1201/9780429459016>, <https://r-spatial.org/book/>.

LaZerte S, Albers S (2018). “weathercan: Download and format weather data from Environment and Climate Change Canada.” _The Journal of Open Source Software_,
*3*(22), 571. <https://joss.theoj.org/papers/10.21105/joss.00571>.

Firke S (2023). _janitor: Simple Tools for Examining and Cleaning Dirty Data_. R package version 2.2.0,
<https://CRAN.R-project.org/package=janitor>.

Grolemund G, Wickham H (2011). “Dates and Times Made Easy with lubridate.” _Journal of Statistical Software_, *40*(3), 1-25.
<https://www.jstatsoft.org/v40/i03/>.

Xie Y, Cheng J, Tan X (2023). _DT: A Wrapper of the JavaScript Library 'DataTables'_. R package version 0.31,
<https://CRAN.R-project.org/package=DT>.

Chang W (2021). _shinythemes: Themes for Shiny_. R package version 1.2.0, <https://CRAN.R-project.org/package=shinythemes>.

Roesslein, Joshua. (2024). *Tweepy: Twitter for Python!* Available at https://www.tweepy.org.

Reitz, Kenneth, & Chisom, Cory. (2024). *Requests: HTTP for Humans* [Software]. Available at https://docs.python-requests.org/en/latest/.





