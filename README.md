# AppSignal frontend test setups

<!-- Generated from support/templates/README.md.erb -->

This repository contains a set of frontend apps to test with.

## Setup

Make sure you have have a working local Node.js install.
Install geckodriver and install the bundle:

```
brew install geckodriver
bundle install
```

Get started by adding a push and frontend key:

```
cp keys.example.yml keys.yml
```

Open this file and follow the instructions.

## Usage

To install an app:

```
rake app:install app=react/16
rake app:install app=react/17
rake app:install app=react/18
rake app:install app=vue/2
rake app:install app=vue/3
```

To run an app and upload its sourcemaps:

```
rake app:run app=react/16 revision=<revision>
rake app:run app=react/17 revision=<revision>
rake app:run app=react/18 revision=<revision>
rake app:run app=vue/2 revision=<revision>
rake app:run app=vue/3 revision=<revision>
```

Then navigate to http://localhost:5001 to trigger an error.

## Running tests

Run `bundle exec rspec` to run an integration test on all test setups.

## Adding a new app

You can add a new test app in one of the framework directories. Add this
line to import a configured `Appsignal` instance:

```javascript
import appsignal from "./appsignal.js"
```

Make sure to use wildcard dependencies in `package.json`. Specify the
major version of the framework you're using, for example `=2` or `=3`.

For the tests to pass a test app should throw a JS error on `/`:

```javascript
throw new Error("This is an error")
```

This error should be caught by the app, the app should render the following text:

```
An error was thrown
```

## Linking a local integration checkout

To do local testing checkout the integrations somewhere, and run `mono
bootstrap` in the directory. Then run:

```
rake link
```

This will link the local packages into all the test setups.

Whenever you make changes to the integrations run `mono build`. If this is
done running apps works in the usual manner.

To undo this step and unlink the packages run:

```
rake unlink
```
