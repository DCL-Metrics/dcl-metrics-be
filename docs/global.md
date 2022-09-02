# GET /global

Global stats computed x times per day (currently once at 1am UTC)

## API ENDPOINT

### `https://api.dcl-metrics.com/global`

#### SAMPLE DATA

The expected response, as json:

``` json
{
  'global': { // see "global" below
    "2022-08-01": {"unique_users":9392,"active_parcels":5130},
    "2022-08-02": {"unique_users":9722,"active_parcels":4890},
    // ...
  },
  'parcels': { // see "parcels" below
    "yesterday": {
      "logins": {
        "1,0": 1061,
        "-100,128": 1017,
        // ...
      },
      "logouts": {
        "-137,99": 270,
        "-100,129": 246,
        // ...
      },
      "time_spent": {
        "120,-12": 6337,
        "-100,129": 5897,
        // ...
      },
      "time_spent_afk": {
        "120,-12": 5154,
        "-29,55": 4284,
        // ...
      },
      "visitors": {
        "-101,126": 3804,
        "-29,55": 3229,
        // ...
      },
    "last_week": {}, // format as above
    "last_month": {} // format as above
  },
  'scenes': {}, // NOT YET IMPLEMENTED
  'users': { // see "users" below
    "yesterday": {
      "parcels_visited": [
        {
          "address": "0xf5950c26fb352c58adb9fc30825b012ac5b3d441",
          "parcels_visited": 196,
          "avatar_url": "https://peer-ec1.decentraland.org/xxx",
          "guest_user": false, // user is not logged in with web3?
          "name": "M1ssConduct",
          "verified_user": false // user has a name token?
        },
        // ...
      ],
      "time_spent: [
        {
          "address": "0x8acf65f50d56449894e655a6d018cbb01cf9a914",
          "time_spent": 83614, // seconds
          "avatar_url": "https://peer-ec1.decentraland.org/xxx",
          "guest_user": false, // user is not logged in with web3?
          "name": "nightrider#a914",
          "verified_user": false // user has a name token?
        },
        // ...
      ]
    },
    "last_week": {}, // format as above
    "last_month": {} // format as above
  }
}
```

[global](../spec/fixtures/expectations/serializers/global_daily_stats.json)
[parcels](../spec/fixtures/expectations/serializers/global_parcels.json)
[users](../spec/fixtures/expectations/serializers/global_users.json)
