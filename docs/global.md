# GET /global

Global stats computed x times per day (currently once at 1am UTC)

## API ENDPOINT

### `https://api.dcl-metrics.com/global`

#### SAMPLE DATA

``` json
{
  global: [serialized top level metrics](../spec/fixtures/expectations/serializers/global_daily_stats.json),
  parcels: [serialized parcel metrics](../spec/fixtures/expectations/serializers/global_parcels.json),
  scenes: {}, // NOT YET IMPLEMENTED
  users: [serialized user metrics](../spec/fixtures/expectations/serializers/global_users.json)
}
```
