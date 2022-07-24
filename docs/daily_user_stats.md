# Daily User Stats

User based stats computed each day

## API ENDPOINT

`https://dclund.herokuapp.com/api/user_stats/:attribute`

where `attribute` is the attribute to sort by. Accepted attributes are:

 * `time_spent`
 * `parcels_visited`

## SAMPLE DATA

``` json
{
  '2022-07-20': [
    {
      'address': '0xea5a43a3251230ed1cc877b463a32cc3ab2986db',
      'time_spent': 82963, // seconds
      'parcels_visited': 3
    }
  ],
  '2022-07-19': [
    {
      'address': '0xde8736f2439db342ae4df7a80da4cd2f59bcffcf',
      'time_spent': 20451, // seconds
      'parcels_visited': 68
    }
  ]
}
```
