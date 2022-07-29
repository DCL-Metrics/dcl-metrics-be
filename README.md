## TODOs:

 * update daily user stats to add all stats for each user
 * ensure addresses are always saved downcase
 * maybe can make up missing visit/duration from the difference between session duration and sum(visit) duration?
 * pull and calculate data for ALL address and ALL parcels (subject to grant)
 * anonymize wallet addresses (pay to have them de-anonymized)
 * run some blame for db to make sure there's nothing taking up super crazy resources
 * create a single `/global_stats` endpoint that returns a long json rather than FE calling multiple stats endpoints

## DONE:

 * ~~add endpoint to collect metrics from FE~~
 * ~~check that times are being created consistently as UTC in prod~~
