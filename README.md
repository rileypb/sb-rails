# Scrumboard API 

This is the back end for Scrumboard. Good to see you! See [sb-angular](https://github.com/rileypb/sb-angular) for a description of this project.

You'll also need to clone and run https://github.com/rileypb/sb-angular. 

## Setting Up

After cloning the repository, install the dependencies with `bundle install`. 

## Development server

Run `rails s`. This will start the server at `http://localhost:3000`. Navigating there will yield a "not authenticated" message since you must supply a token for access.

## Setting up Authentication

At this time, Scrumboard only supports authentication through [Auth0](https://auth0.com/), although it should work with any of the login methods available there.

To set up Auth0 authentication, create an account at auth0.com. Use the free plan for now. You'll get your own "domain" which will most likely be some random string. 

Next create an API, which essentially is just a universally unique string identifier naming your API, i.e., the service that needs to authenticate users - the back end. This could be, for instance, https://<my.domain.com>/scrumboard. 

Then create an application. The name doesn't matter, but it must be in your domain (I believe this is your only choice on the free plan). It will come with its own Client ID and Client Secret. The Client ID will be necessary for setting up the back and front ends.

You then need to add an auth0 section to your encrypted credentials:
```
auth0:
  api_identifier: https://<my.domain.com>/scrumboard
  domain: https://<my-domain-name>.us.auth0.com/
```

Remember not to commit your keys to git if you've forked this repo!
