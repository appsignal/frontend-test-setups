# AppSignal frontend test setups

<!-- Generated from support/templates/README.md.erb -->

This repository contains a set of frontend apps to test with.

## Setup

Make sure you have have a working local Node.js install, version 16 or
up. Install geckodriver and install the bundle:

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
```

To run an app and upload its sourcemaps:

```
rake app:run app=react/16 revision=<revision>
rake app:run app=react/17 revision=<revision>
```

Then navigate to http://localhost:5001 to trigger an error.

## Running tests

Run `bundle exec rspec` to run an integration test on all test setups.
