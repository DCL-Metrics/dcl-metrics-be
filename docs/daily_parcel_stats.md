# Daily Parcel Stats

Parcel based stats computed each day

## API ENDPOINT

`https://dclund.herokuapp.com/api/parcel_stats`

## SAMPLE DATA

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
