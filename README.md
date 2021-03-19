# Scrumboard API 

This is the back end for Scrumboard. Good to see you!

You'll also need to clone and run https://github.com/rileypb/sb-angular.

## Setting Up

After cloning the repository, install the dependencies with `bundle install`. 

## Development server

Run `rails s`. This will start the server at `http://localhost:3000`. Navigating there will yield a "not authenticated" message since you must supply a token for access.

## Setting up Authentication

At this time, Scrumboard only supports authentication through [Auth0](https://auth0.com/), although it should work with any of the login methods available there.
