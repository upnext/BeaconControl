# Beacons

This API endpoint provides access to the application Beacons.

## List of Beacons

### Endpoint

```
GET /s2s_api/v1/beacons
```

### Request parameters

| Name | Required? | Example | Comments |
| ---- | --------- | ------- | -------- |
| name | no | ```Beacon1``` | Filter beacons by name containing given string, case sensitive |

### Examples of requests

```
GET /s2s_api/v1/beacons
```

```
GET /s2s_api/v1/beacons?name=Beacon
```

### JSON Response

Hash with ```ranges``` key containing array of beacons

| Name | Optional? | Example | Comments
| ---- | --------- | ------- | -------- |
| id | no | ```1``` | ID of Beacon in database |
| name | no | ```Beacon 1``` | |
| proximity_id | no | ```F7826DA6-4FA2-4E98-8024-BC5B71E0893E+53238+25345``` | Beacon location proximity |
| location[lat] | no | ```53.127383``` | Beacon location geographic latitude |
| location[lng] | no | ```23.117402``` | Beacon location geographic longitude |
| location[floor] | no | ```1```, ```null``` | Beacon location floor number, can be empty or number in range 0-10 |
| zone[] | yes | Object | Zone object, may be null |
| zone[id] | - | ```1``` | Zone id |
| zone[name] | - | ```Zone name``` | Zone id |
| zone[color] | - | ```ffaa33``` | Zone color |
| zone[hex_color] | - | ```#ffaa33``` | Zone color as hex|

### Example of response

```json
// HTTP 200 OK

{
    "ranges": [
        {
            "id": 1,
            "name": "Beacon 1",
            "proximity_id": "F7826DA6-4FA2-4E98-8024-BC5B71E0893E+53238+25345",
            "location": {
              "lat": "53.127383",
              "lng": "23.117402",
              "floor": null
            },
            "zone": {
              "id": 1,
              "name": "Zone 1",
              "color": "ffaa33",
              "hex_color": "#ffaa33"
            }
        },
        {
            "id": 3,
            "name": "",
            "proximity_id": "00000000-0000-0000-0000-000000000000+9+9",
            "location": {
              "lat": null,
              "lng": null,
              "floor": 1
            },
            "zone": {
              "id": 1,
              "name": "Zone 1",
              "color": "ffaa33",
              "hex_color": "#ffaa33"
            }
        }
    ]
}
```

## Create Beacon

### Endpoint

```
POST /s2s_api/v1/beacons
```

### Request parameters

| Name | Required? | Example | Comments |
| ---- | --------- | ------- | -------- |
| beacon[name] | no | ```Beacon 1``` |  |
| beacon[uuid] | yes | ```F7826DA6-4FA2-8024-4E98-BC5B71E0893E``` | Beacon location proximity, in UUID format |
| beacon[major] | yes | ```64345``` | Number used to differentiate a large group of related beacons |
| beacon[minor] | yes | ```62643`` | Number used to distinguish a smaller subset of beacons within the larger group |
| beacon[lat] | no | ```53.127383``` | Beacon location geographic latitude |
| beacon[lng] | no | ```23.117402``` | Beacon location geographic longitude |
| beacon[floor] | no | ```1``` | Beacon location floor number in range 0-10 |
| beacon[zone_id] | no | ```1``` | ID of zone to assign beacon to* |
| beacon[activity][name] | no | ```Test notification``` | Name for test notification |
| beacon[activity][trigger_attributes][test] | no | ```true``` | Must be ```true```, notification won't be created otherwise |
| beacon[activity][trigger_attributes][event_type] | no | ```enter``` | Only [valid options](activities.html#notes) for ```BeaconTrigger``` allowed |
| beacon[activity][custom_attributes_attributes][][name] | no | ```foo``` | Name of [custom attribute](activities.html#activity-attributes) |
| beacon[activity][custom_attributes_attributes][][value] | no | ```Foo``` | Value for [custom attribute](activities.html#activity-attributes) |

*Note1:* Test notification could be crateted along with new beacon. To do so, ```activity``` parameters must be provided with ```test``` flag set to ```true```.

### Example of request

```json
{
    "beacon": {
        "name": "Beacon 1",
        "uuid": "F7826DA6-4FA2-8024-4E98-BC5B71E0893E",
        "major": 64345,
        "minor": 62643,
        "lat": 53.127383,
        "lng": 23.117402,
        "floor": 1,
        "zone_id": 1
    }
}
```

```json
{
    "beacon": {
        "name": "Beacon 1",
        "uuid": "F7826DA6-4FA2-8024-4E98-BC5B71E0893E",
        "major": 64345,
        "minor": 62643,
        "lat": 53.127383,
        "lng": 23.117402,
        "floor": 1,
        "zone_id": 1,
        "activity": {
          "name": "Test notification",
          "trigger_attributes": {
            "test": true,
            "event_type": "enter"
          },
          "custom_attributes_attributes": [
            {
              "name": "foo",
              "value": "Foo"
            },
            {
              "name": "bar",
              "value": "Bar"
            }
          ]
        }
    }
}
```

### Examples of responses

```json
// HTTP 201 Created

{
    "range": {
        "id": 11,
        "name": "Beacon 1",
        "proximity_id": "F7826DA6-4FA2-8024-4E98-BC5B71E0893E+64345+62643",
        "location": {
          "lat": "53.127383",
          "lng": "23.117402",
          "floor": 1
        },
        "zone": {
          "id": 1,
          "name": "Zone 1",
          "color": "ffaa33",
          "hex_color": "#ffaa33"
        }
    }
}
```

```json
// HTTP 422 Unprocessable Entity

{
    "errors": {
        "uuid": [
            "is invalid"
        ],
        "minor": [
            "can't be blank",
            "is not a number"
        ],
        "major": [
            "is not a number"
        ],
        "floor": [
            "is not included in the list"
        ],
        "zone_id": [
            "is not included in the list"
        ]
    }
}
```

```json
// HTTP 422 Unprocessable Entity

{
    "errors": {
        "uuid": [],
        "minor": [],
        "major": [],
        "test_activity": [
            {
                "name": [
                    "can't be blank"
                ],
                "trigger.beacons": [
                    "is invalid"
                ]
            }
        ]
    }
}
```

## Update Beacon

### Endpoint

```
PUT|PATCH /s2s_api/v1/beacons/:id
```

### Request parameters

| Name | Required? | Example | Comments |
| ---- | --------- | ------- | -------- |
| beacon[name] | no | ```Beacon 1``` |  |
| beacon[uuid] | no | ```F7826DA6-4FA2-8024-4E98-BC5B71E0893E``` | Beacon location proximity, in UUID format. If provided, cannot be empty |
| beacon[major] | no | ```64345``` | If provided, cannot be empty |
| beacon[minor] | no | ```62643``` | If provided, cannot be empty |
| beacon[lat] | no | ```53.127383```, ```null``` | Beacon location geographic latitude |
| beacon[lng] | no | ```23.117402```, ```null``` | Beacon location geographic longitude |
| beacon[floor] | no | ```1```, ```null``` | Beacon location floor number in range 0-10 |
| beacon[zone_id] | no | ```1```, ```null``` | ID of zone to assign beacon to (or remove)* |
| beacon[activity][name] | no | ```Test notification``` | Name for test notification |
| beacon[activity][trigger_attributes][test] | yes | ```true``` | Must be ```true```, notification won't be created/updated otherwise |
| beacon[activity][trigger_attributes][event_type] | no | ```leave``` | Only [valid options](activities.html#notes) for ```BeaconTrigger``` allowed |
| beacon[activity][custom_attributes_attributes][][name] | no | ```foo``` | Name of [custom attribute](activities.html#activity-attributes) |
| beacon[activity][custom_attributes_attributes][][value] | no | ```Foo``` | Value for [custom attribute](activities.html#activity-attributes) |


### Example of request

```
PUT /s2s_api/v1/beacons/2
```

```json
{
    "beacon": {
        "uuid": "00000000-0000-0000-0000-000000000000",
        "major": 1,
        "minor": 2
    }
}
```

```json
{
    "beacon": {
        "activity": {
          "trigger_attributes": {
            "event_type": "leave"
          },
          "custom_attributes": [
            {
              "name": "baz",
              "value": "Baz"
            }
          ]
        }
    }
}
```

### Examples of responses

```json
// HTTP 204 No Content
```

```json
// HTTP 422 Unprocessable Entity

{
    "errors": {
        "uuid": [
            "is invalid"
        ],
        "minor": [
            "can't be blank"
        ],
        "major": [
            "is not a number"
        ]
    }
}
```

```json
// HTTP 422 Unprocessable Entity

{
    "errors": {
        "test_activity": [
            {
              "name": [
                  "can't be blank"
              ],
              "trigger.beacons": [
                  "is invalid"
              ]
            }
        ]
    }
}
```

## Remove Beacon

### Endpoint

```
DELETE /s2s_api/v1/beacons/:id
```

### Example of request

```
DELETE /s2s_api/v1/beacons/2
```

### Examples of responses

```
// HTTP 204 No Content
```

```
// HTTP 404 Not Found
```

## Remove batch of Beacons

### Endpoint

```
DELETE /s2s_api/v1/beacons
```


### Request parameters

| Name | Required? | Example | Comments |
| ---- | --------- | ------- | -------- |
| ids | yes | ```[1,2,3]``` | Array of beacons IDs |

### Examples of requests

```
DELETE /s2s_api/v1/beacons?ids[]=1&ids[]=2&ids[]=3
```

```json
// DELETE /s2s_api/v1/beacons

{
    "ids": [1,2,3]
}
```

### Example of response

```
// HTTP 204 No Content
```
