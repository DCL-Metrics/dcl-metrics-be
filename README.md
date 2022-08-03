## TODOs:

 * fix SSL redirect on www.x.com to have https everywhere
 * run some blame for db to make sure there's nothing taking up super crazy resources
 * create a single `/global_stats` endpoint that returns a long json rather than FE calling multiple stats endpoints
 --- that JSON should be generated as part of the job and replaced per run
 * make staging app && remove existing internal metrics
 * ensure addresses are always saved downcase

### Internal dashboard
 * parse internal metrics and expose endpoint
 * create repo that reads and displays this
 * attach to admin.dcl-metrics.com // internal.dcl-metrics.com
 * add obsidian (at least readonly?)

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
