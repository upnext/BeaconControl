# Authentication

This endpoint provides OAuth 2 authentication for clients. Creating requests
to this endpoint requires application on BeaconCtrl where you can find ```client_id```
& ```client_secret``` (app section: Settings)


## Obtain access token

### Endpoint

```
POST /api/v1/oauth/token
```

### Request parameters

| Name | Required? | Example | Comments |
| ---- | --------- | ------- | -------- |
| client_id     | yes | below | OAuth client id |
| client_secret | yes | below | OAuth client secret |
| grant_type | yes | ```password``` | |
| user_id | yes | ```foobar``` | needs to be unique per application & user |
| os | yes | ```ios``` | currently supported: ```ios``` |
| environment | no | ```production``` | currently supported: ```production```, ```sandbox```. This is required to send proper push tokens based on APNS build |
| push_token | no | ```token-test``` | APNS push token to send push notifications. One user_id can have multiple push_tokens |


### Example of request

```json
{
  "client_id":"44bc993498c0c106c7b0de81875ffd60da7c9465253758caadb66d52aaedd257",
  "client_secret":"b0017ef77ee910df9ff92c39fda8d9f77647451b20fd6bb4e5f9e0c129ce7579",
  "grant_type":"password",
  "user_id":"foobar",
  "os":"ios",
  "environment":"production",
  "push_token":"token-test"
}
```

### Response parameters

| Name | Optional? | Example | Comments |
| ---- | --------- | ------- | -------- |
| access_token | no | below | Access token that should be cached by app |
| token_type | no | ```bearer``` | Type of token, only ```bearer``` for now |
| expires_in | no | ```null```, ```7200``` | ```null``` if no refresh token strategy is used. *Number of seconds in the other case* |
| refresh_token | yes | below | Token that should be used to revalidate client when access_token expires |


### Example of response

#### Success

```json
// HTTP/1.1 200 OK

{
  "access_token":"3f869446e859ec87d38bcae12e83d566af22ea4dc1ccaa6f74364a2f1969ebd8",
  "token_type":"bearer",
  "expires_in":null
}
```

Token expiration can be configured be via application configuration (config.yml).
If you use a refresh token, you will receive the following response:

```json
// HTTP/1.1 200 OK

{
  "access_token":  "9e8e2031180e05a0383a0d4516d33a5927df8ef972b6ad5b78c90e30a279b959",
  "token_type":    "bearer",
  "expires_in":    7200,
  "refresh_token": "34e72a230bc1b126f33789ae5f1af4e8641c3529480d2ea15e1af7b0ae443391",
}
```


#### Failure

```json
// HTTP/1.1 401 Unauthorized

{
  "error": "invalid_resource_owner",
  "error_description": "The provided resource owner credentials are not valid, or resource owner cannot be found"
}
```

## Refresh access token

### Endpoint

```
POST /api/v1/oauth/token
```

### Request parameters

| Name | Required? | Example | Comments |
| ---- | --------- | ------- | -------- |
| client_id     | yes | below | OAuth client id |
| client_secret | yes | below | OAuth client secret |
| grant_type | yes | ```refresh_token``` | |
| refresh_token | no | ```below``` | OAuth refresh token, received during previous request |


### Example of request

```json
{
  "client_id":"44bc993498c0c106c7b0de81875ffd60da7c9465253758caadb66d52aaedd257",
  "client_secret":"b0017ef77ee910df9ff92c39fda8d9f77647451b20fd6bb4e5f9e0c129ce7579",
  "grant_type":"refresh_token",
  "refresh_token":"34e72a230bc1b126f33789ae5f1af4e8641c3529480d2ea15e1af7b0ae443391"
}
```

### Response parameters

| Name | Optional? | Example | Comments |
| ---- | --------- | ------- | -------- |
| access_token | no | below | Access token that should be cached by app |
| token_type | no | ```bearer``` | Type of token, only ```bearer``` for now |
| expires_in | no | ```null```, ```7200``` | null if no refresh token strategy is used. *Number of seconds in other case* |
| refresh_token | yes | below | Token that should be used to revalidate client when access_token expires |


### Example of response

#### Success
```json
//  HTTP/1.1 200 OK

{
  "access_token":  "9e8e2031180e05a0383a0d4516d33a5927df8ef972b6ad5b78c90e30a279b959",
  "token_type":    "bearer",
  "expires_in":    7200,
  "refresh_token": "34e72a230bc1b126f33789ae5f1af4e8641c3529480d2ea15e1af7b0ae443391",
}
```


#### Failure

```json
// HTTP/1.1 401 Unauthorized

{
  "error": "invalid_resource_owner",
  "error_description": "The provided resource owner credentials are not valid, or the resource owner cannot be found"
}
```
