# AppSignal frontend test setups

<!-- Generated from support/templates/README.md.erb -->

This repository contains a set of frontend apps to test with.
Get started by generating `appsignal.js` files for all apps:

```
rake global:set_appsignal_config key=<key>
```

To install an app:

```
rake app:install app=react/17
```

To run an app:

```
rake app:run app=react/17 revision=<revision> push_api_key=<key>
```
