# Dokku

Docker powered mini-Heroku. The smallest PaaS implementation you've ever seen.

[![Build Status](https://travis-ci.org/progrium/dokku.png?branch=master)](https://travis-ci.org/progrium/dokku)

## Requirements

Assumes Ubuntu 13 or 12.04 x64 right now. Ideally have a domain ready to point to your host. It's designed for and is probably
best to use a fresh VM. The bootstrapper will install everything it needs.

**Note: There are known issues with docker and Ubuntu 13.10 ([1](https://github.com/dotcloud/docker/issues/1300), [2](https://github.com/dotcloud/docker/issues/1906)) - use of 12.04 is recommended until these issues are resolved.**

## Installing

### Stable

    $ wget -qO- https://raw.github.com/progrium/dokku/v0.2.1/bootstrap.sh | sudo DOKKU_TAG=v0.2.1 bash

**Note**: Users on 12.04 will need to run `apt-get install -y python-software-properties` before bootstrapping stable.

### Development

    $ wget -qO- https://raw.github.com/progrium/dokku/master/bootstrap.sh | sudo bash

This may take around 5 minutes. Certainly better than the several hours it takes to bootstrap Cloud Foundry.

You may also wish to take a look at the [advanced installation](http://progrium.viewdocs.io/dokku/advanced-installation) document for additional installation options.

## Configuring

Set up a domain and a wildcard domain pointing to that host. Make sure `/home/dokku/VHOST` is set to this domain. By default it's set to whatever hostname the host has. This file is only created if the hostname can be resolved by dig (`dig +short $(hostname -f)`). Otherwise you have to create the file manually and set it to your prefered domain. If this file still is not present when you push your app, dokku will publish the app with a port number (i.e. `http://example.com:49154` - note the missing subdomain).

You'll have to add a public key associated with a username by doing something like this from your local machine:

    $ cat ~/.ssh/id_rsa.pub | ssh progriumapp.com "sudo sshcommand acl-add dokku progrium"

That's it!

## Deploy an App

Now you can deploy apps on your Dokku. Let's deploy the [Heroku Node.js sample app](https://github.com/heroku/node-js-sample). All you have to do is add a remote to name the app. It's created on-the-fly.

    $ cd node-js-sample
    $ git remote add progrium dokku@progriumapp.com:node-js-app
    $ git push progrium master
    Counting objects: 296, done.
    Delta compression using up to 4 threads.
    Compressing objects: 100% (254/254), done.
    Writing objects: 100% (296/296), 193.59 KiB, done.
    Total 296 (delta 25), reused 276 (delta 13)
    -----> Building node-js-app ...
           Node.js app detected
    -----> Resolving engine versions

    ... blah blah blah ...

    -----> Application deployed:
           http://node-js-app.progriumapp.com

You're done!

Right now Buildstep supports buildpacks for Node.js, Ruby, Python, [and more](https://github.com/progrium/buildstep#supported-buildpacks). It's not hard to add more, [go add more](https://github.com/progrium/buildstep#adding-buildpacks)!
Please check the documentation for your particular build pack as you may need to include configuration files (such as a Procfile) in your project root.

## Remote commands

Dokku commands can be run over ssh. Anywhere you would run `dokku <command>`, just run `ssh -t dokku@progriumapp.com <command>`
The `-t` is used to request a pty. It is highly recommended to do so.
To avoid the need to type the `-t` option each time, simply create/modify a section in the `.ssh/config` on the client side, as follows :

    Host progriumapp.com
    RequestTTY yes

If you want a client-side command you can run to automatically run a command
against the server based on your `dokku` remote, similar to the Heroku
Toolbelt, check out dokku-client.sh in the "contrib" directory.

## Run a command in the app environment

It's possible to run commands in the environment of the deployed application:

    $ dokku run node-js-app ls -alh
    $ dokku run <app> <cmd>

## Plugins

Dokku itself is built out of plugins. Checkout the wiki for information about
creating your own and a list of existing plugins:

https://github.com/progrium/dokku/wiki/Plugins

## Removing a deployed app

SSH onto the server, then execute:

    $ dokku delete myapp

## Environment variable management

Typically an application will require some environment variables to run properly. Environment variables may contain private data, such as passwords or API keys, so it is not recommend to store them in your application's repository.

The `config` plugin provides the following commands to manage your variables:
```
config <app> - display the config vars for an app
config:get <app> KEY - display a config value for an app
config:set <app> KEY1=VALUE1 [KEY2=VALUE2 ...] - set one or more config vars
config:unset <app> KEY1 [KEY2 ...] - unset one or more config vars
```

## TLS support

Dokku provides easy TLS support from the box. To enable TLS connection to your application, copy the `.crt` and `.key` files into the `/home/dokku/:app/ssl` folder (notice, file names should be `server.crt` and `server.key`, respectively). Redeployment of the application will be needed to apply TLS configuration. Once it is redeployed, the application will be accessible by `https://` (redirection from `http://` is applied as well).

## Upgrading

Dokku is in active development. You can update the deployment step and the build step separately.

**Note**: If you are upgrading from a revision prior to [27d4bc8c3c](https://github.com/progrium/dokku/commit/27d4bc8c3c19fe580ef3e65f2f85b85101cd83e4), follow the instructions in [this wiki entry](https://github.com/progrium/dokku/wiki/Migrating-to-Dokku-0.2.0).

To update the deploy step (this is updated less frequently):

    $ cd ~/dokku
    $ git pull origin master
    $ sudo make install

Nothing needs to be restarted. Changes will take effect on the next push / deployment.

To update the build step:

    $ git clone https://github.com/progrium/buildstep.git
    $ cd buildstep
    $ git pull origin master
    $ sudo make build

This will build a fresh Ubuntu Quantal image, install a number of packages, and
eventually replace the Docker image for buildstep.

## Support

You can use [Github Issues](https://github.com/progrium/dokku/issues), check [Troubleshooting](https://github.com/progrium/dokku/wiki/Troubleshooting) on the wiki, or join us on [freenode in #dokku](https://webchat.freenode.net/?channels=%23dokku)

## Components

 * [Docker](https://github.com/dotcloud/docker) - Container runtime and manager
 * [Buildstep](https://github.com/progrium/buildstep) - Buildpack builder
 * [pluginhook](https://github.com/progrium/pluginhook) - Shell based plugins and hooks
 * [sshcommand](https://github.com/progrium/sshcommand) - Fixed commands over SSH

Looking to keep codebase as simple and hackable as possible, so try to keep your line count down.

## Things this project won't do

 * **Multi-host.** Not a huge leap, but this isn't the project for it. Have a look at [Flynn](https://flynn.io/).
 * **Multitenancy.** It's ready for it, but again, have a look at [Flynn](https://flynn.io/).
 * **Client API.** Given the constraints, running commands remotely via SSH is fine.

## License

MIT
