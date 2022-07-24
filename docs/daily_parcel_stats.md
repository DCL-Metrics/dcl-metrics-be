# Daily Parcel Stats

Parcel based stats computed each day

## API ENDPOINT

### `https://dclund.herokuapp.com/api/parcel_stats/:attribute/daily`

where `attribute` is the attribute to sort by. Accepted attributes are:

 * `time_spent`
 * `visitors`
 * `logins`
 * `logouts`

#### SAMPLE DATA

``` json
{
  '2022-07-20': [
    {
      'coordinates': '23,-77',
      'avg_time_spent': 7000, // seconds
      'avg_time_spent_afk': 5400, // seconds
      'unique_visitors': 3,
      'logins': 3,
      'logouts': 3
    }
  ]
}
```

### `https://dclund.herokuapp.com/api/parcel_stats/:attribute/top`

returns a sum of the given attribute(s) per parcel over the last 7 days. Accepted attributes are    :

 * `time_spent`
 * `visitors`
 * `logins`
 * `logouts`

#### SAMPLE RESPONSE

``` json
{
  '23,-77': {
    'avg_time_spent': 7000,
    'avg_time_spent_afk': 5400,
    'unique_visitors': 3,
    'logins': 3,
    'logouts': 3
  }
}
```
