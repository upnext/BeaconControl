# Actions

![Actions](../images/actions.png)

Actions are invoked when a mobile user starts the interaction with Beacons and/or Zones.
You can specify a few types of actions by default:

* URL - simply sends the URL to be opened to the application
* Custom - list of static key-value strings that should be handled by application
* Coupon - allows to create a mobile page based on the passed parameters. This is similar
to the URL, but the Coupon URL points to BeaconCtrl system (see below)

## Adding a new action

![New Action](../images/action_new.png)
![New Action](../images/action_new_2.png)

In this example you can see the process of creating *Coupon* action

### Fields:
* Based On - specifies if the action should be invoked on Beacon or Zone interaction
* Trigger - what type of interaction should appear to invoke it
  * On hello - when client enters into the range
  * On exit - when client leaves the range
  * Nearby / In Sight / Almost Touching - bases on the distance between client & beacon / zone.
    * **Note:** Implementation of Nearby / In Sight / Almost Touching depends on implementation in application
  * DwellTime - when client stays in the range for a particular period of time.

    **DwellTime** is the only one trigger that should not be invoked directly by the application.
    Instead, BeaconCtrl measures the time that client is inside the zone and, if client
    stays in the range of Beacon / Zone for the particular amount of time, sends Push Notification
    that should be handled by the app.
* Action Name - internal BeaconCtrl name for action

* Beacon / Zone - choose beacon / zone that will trigger action

The rest of the fields are used to create a template that will be shown to the client.
When typing/filling them in, the user is getting real-time feedback on what the website will look like.
