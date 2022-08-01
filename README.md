## TODOs:

 * create miro board for FE/BE
 * fix SSL redirect on www.x.com to have https everywhere
 * run some blame for db to make sure there's nothing taking up super crazy resources
 * create a single `/global_stats` endpoint that returns a long json rather than FE calling multiple stats endpoints
 --- that JSON should be generated as part of the job and replaced per run
 * make staging app && remove existing internal metrics
 * parse internal metrics and expose to FE
 * ensure addresses are always saved downcase
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
