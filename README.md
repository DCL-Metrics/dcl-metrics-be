## TODOs:

 * fix SSL redirect on www.x.com to have https everywhere
 * run some blame for db to make sure there's nothing taking up super crazy resources
 * ensure addresses are always saved downcase
 * generate data for global stats endpoint as single JSON and replaced per run

### Internal dashboard

 * parse internal metrics and expose endpoint
 * create repo that reads and displays this
 * attach to admin.dcl-metrics.com // internal.dcl-metrics.com
 * add obsidian (at least readonly?)
 * add api documentation

### Just weird ideas

 * maybe can make up missing visit/duration from the difference between session duration and sum(visit) duration?
 * anonymize wallet addresses (pay to have them de-anonymized)

### As part of grant

 * run stats for scenes
 * update daily user stats to add all stats for each user
 * pull and calculate data for ALL address and ALL parcels
 * partial daily runs for current day (every Xhrs)

## DONE:

 * ~~add endpoint to collect metrics from FE~~
 * ~~check that times are being created consistently as UTC in prod~~
 * ~~create miro board for FE/BE~~
 * ~~create a single `/global_stats` endpoint that returns a long json rather than FE calling multiple stats endpoints~~
 * ~~add telegram notification service~~

## Proposed Roadmap

**2022 Q3**

* Update FE aesthetic and charts components
* Build metrics for scenes (ie, Wilderness p2e as a whole rather than each of the 20 parcels of which it is comprised)

**2022 Q4**

* Build metrics for all users / parcels / scenes not just top 10 lists
* Introduce Daily New Users to global tracking
* Introduce Concurrent Users histogram globally and by scene
* Increasing daily run intervals for nearly live metrics
* Incorporate land sales and rental data
* Incorporate and work with Atlas Corporation's new data warehouse

**2023 Q1**

* Personalized metric dashboards
* More detailed parcel and scene-based metrics
  * Z-axis analytics
* Advanced user analytics
  * Wearables
  * POAPs
  * DAO activity
