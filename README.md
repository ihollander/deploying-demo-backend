# Backend Deploying with Heroku

## How To Deploy

Make sure your backend project is in its own repo (separate from your frontend
project), and that it is connected to a repo on Github.

- [Tutorial](https://devcenter.heroku.com/articles/getting-started-with-rails6)

## Environment Variables

When working on your app, it's useful to consider which environment you're working on:

- Development: when working locally
- Test: when running tests
- Production: when deployed to server

You'll likely have some variables that change depending on what environment you're working in. For example, after deploying your site to production, you won't be able to access your backend on `localhost` anymore.

To handle these kind of **environment variables**, we can use `.env` files.

In Rails, you can use the `dotenv-rails` gem to work with `.env` files. After
installing the gem, you can make a `.env` file in the root of your project
directory, and add key-value pairs to it, like this:

```txt
MY_KEY=some-value
```

If you are using this file to keep sensitive data, like API keys, make sure to
also add `.env` in your `.gitignore` file so that the file won't be tracked by
git and won't be pushed to GitHub with your code.

To work with environment variables in your production server, Heroku has a
configuration section in your app dashboard where you can add
[config vars](https://devcenter.heroku.com/articles/config-vars).

## CORS

Once you've deployed your frontend, it's time to update your
[CORS](https://github.com/cyu/rack-cors) configuration!

```rb
# config/initializers/cors.rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'ians-app.netlify.app'

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

You can use an environment variable to make it easier to have an origin
for development as well as production:

```rb
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV['CORS_DOMAIN']

    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
```

## Common Issues

If you get an error about having the wrong Ruby version:

- Use RVM to install the version needed by Heroku:
  - `rvm install 2.6.6`
- Update the Ruby version at the top of your Gemfile:
  - ruby '2.6.6'
- Delete `Gemfile.lock` and update your gems:
  - `bundle install`
- commit your code and push the new version to Heroku
  - `git add .`
  - `git commit -m 'Updated Ruby version'`
  - `git push heroku main`

## What Happens When I Deploy?

Glad you asked! Deploying your site involves taking the code that lives on your
machine, and setting it up to run on someone else's machine.

For our Rails applications, that means our Ruby code needs to run on someone
else's computer and be accessible to requests from anywhere on the internet
(instead of just from our local computer).

With Heroku, when we deploy an application, Heroku carves out a piece of memory
for our app to run on its servers. It creates a virtual environment in a Unix
container (in Heroku-speak, a `dyno`) that has all the required environment
setup to run our Rails applications.

When we upload our code to Heroku (by pushing up our git repo), Heroku will
build our application and set it up to run and listen for requests.

Heroku is configured to use **Continuous Deployment**, which typically works by
connecting your Git repository with Heroku. Then, any time you push up changes
to your main branch to our Heroku remote, your deployed site will automatically
update! This makes it very easy to add features even after you've deployed.
