# BeaconCtrl API
## About

This section provides information about API calls available on BeaconCtrl platform.

Here, you can find out how to authenticate web / mobile application with a BeaconCtrl app
and how to create and push events.

## General information

BeaconCtrl API supports JSON / XML format.

Currently this documentation provides only JSON examples.

## API Versioning

We use API versioning to provide continous support for older clients. No change
should break previous client implementations.

The current Mobile clients API version is [v1](../api_docs_v1/README.md):
```
https://beaconctrl.example.com/api/v1
```

Current Server-2-Server(S2S) clients API version is [v1](../s2s_api_docs_v1/README.md):
```
https://beaconctrl.example.com/s2s_api/v1
```

## HTTP Verbs

Where possible, API strives to use appropriate HTTP verbs for each action.

| Verb	 | Description |
| ----   | ----------- |
| HEAD	 | Can be issued against any resource to get just the HTTP header info. |
| GET	   | Used for retrieving resources. |
| POST	 | Used for creating resources. |
| PATCH	 | Used for updating resources with partial JSON data. For instance, an Issue resource has title and body attributes. A PATCH request may accept one or more of the attributes to update the resource. PATCH is a relatively new and uncommon HTTP verb, so resource endpoints also accept POST requests. |
| PUT	   | Used for replacing resources or collections. For PUT requests with no body attribute, be sure to set the Content-Length header to zero. |
| DELETE|	Used for deleting resources. |


## Docs convention

Every example in these docs should contain an endpoint, an example of a request & an example of a response (including HTTP status).
