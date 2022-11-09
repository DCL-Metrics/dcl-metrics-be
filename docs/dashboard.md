# GET /dashboard/:dashboard_name

Data for dashboard clients

## API ENDPOINT

### `https://api.dcl-metrics.com/dashboard/:dashboard_name`

where `dashboard_name` is the name of the subscribed client. these are mapped to
the scenes they have subscribed to in the backend

## QUERY PARAMENTERS

### `date`

[optional] - the date for which to fetch scene stats. available dates are
returned with every successful response

#### SAMPLE DATA

The expected response, as json:

``` json
{
  "available_dates":["2022-10-15","2022-10-16","2022-10-17"]
  "result": {} // scene stats
}
```

for full information on scene stats format, see [scenes](../docs/scenes/top.md)
