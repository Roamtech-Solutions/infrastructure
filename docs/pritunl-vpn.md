# Pritunl VPN


## Overview

A [Pritunl][pritunl] instance is deployed on the `management` project.
The purpose of the VPN is help with restricting access to our services, especially the ones that are in development and have experimental features.

For access to the VPN please speak to a member of the [Infrastructure Team][infra-team].


## Setting Up a User

This guide is for infrastructure engineers.


### Requirements

You need the following before you are able to setup a user:

1. Be in the Roamtech office and connected to that
   network so that you have a public IP address that is accepted by the web
   application firewall (WAF) that is protecting our VPN web console. Or
   rather ironically, connected to the VPN, since the VPN IP address is also
   allowed.
2. Access to the VPN [web console credentials][vpn-web-console-credentials].


### How to setup a user

To add a user:

1. Open the VPN web console [here][vpn-web-console]
2. Login using the [credentials][vpn-web-console-credentials], use the latest
   version of the credentials.
3. Go to the [users][vpn-web-console-users] tab in the VPN web console.
4. Select _Add User_
5. Fill in the form, providing the full name and email address of the user as
   well as selecting an appropriate organisation, do not create a pin.
6. Find the new user in the list of users and select the _Get temporary profile
   links icon_ for the new user.
7. Privately share the _Temporary url to view profile links_, which is the
   second from bottom in the list of links. This will give a guided setup for
   the new user to complete access to the VPN.


<!-- Links -->
[pritunl]: https://pritunl.com/
[infra-team]: /docs/infra-team.md
[vpn-web-console]: https://vpn.roamtech.whitemire-technologies.com/
[vpn-web-console-credentials]: https://console.cloud.google.com/security/secret-manager/secret/vpn-web-console-credentials/versions?project=management-b6d6 
[vpn-web-console-users]: https://vpn.roamtech.whitemire-technologies.com/#/users
