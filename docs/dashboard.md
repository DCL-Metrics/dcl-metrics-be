# GET /dashboard/:dashboard_name

Data for dashboard clients

## API ENDPOINT

### `https://api.dcl-metrics.com/dashboard/:dashboard_name`

where `dashboard_name` is the name of the subscribed client. these are mapped to
the scenes they have subscribed to in the backend

#### SAMPLE DATA

The expected response, as json:

``` json
{
  "daily_users": {
    "2022-10-15": 23,
    "2022-10-16": 208,
    "2022-10-17": 42
  },
  "result": {} // scene stats
}
```

for full information on scene stats format, see [scenes](../docs/scenes/top.md)
