# OpenID Connect certification + Docker
This is an early work in progress. 

There are currently a few issues I am aware of and working on with others. 
Please check the open issues to help understand the problems you might have 
when running this image.

Any ideas or pull requests to make the image better are most welcome.

# Docker

## Up and running with Docker

If you've not yet got Docker installed or you're on an older release follow
the documentation at
[https://docs.docker.com/engine/installation/](https://docs.docker.com/engine/installation/)
for assistance in getting your development machine ready.

## Image details

The image uses s6-overlay to bring up nginx and python web server processes.

The `root` directory located with your `Dockerfile` allows you to control parts
of the image generation process by baking in any files you might need in
addition to what is shipped here.

## Creating the docker image

From the project directory that you've cloned from Github:

`docker build -t oidc_certification:0.1 .`

## Running the docker image

Having built the image above run the following command:

`docker run --rm -it -p 8080:80 -p 8443:443 -p10000-10020:10000-10020 oidc_certification:0.1 bash`

As things aren't quite stable yet this will:

1. Start all required webservices
2. Provide you a bash prompt on the active docker instance allowing you to tweak
issues - remember when you kill the image all changes disappear!.

# Setup Tool

The docker image has been populated with an instance of the oidc test server as
part of it's creation. You can access these files at
`/opt/oidc/oidctest_server_instance/`.

To access the certification tooling open [http://localhost:8080](http://localhost:8080) in your browser.

n.b. Issue 1 is currently preventing us from auto starting all the python web
server bits, for now you'll need to exec run manually:

```
bash-4.3# cd /opt/oidc/oidctest_server_instance/oidc_op/
bash-4.3# ./run.sh
Traceback (most recent call last):
  File "config_server.py", line 10, in <module>
    from oidctest.tt import FileSystem
ImportError: cannot import name 'FileSystem'
```
Once we can address the `Traceback` shown there `run.sh` will be executed as
part of container startup, removing the need for this step.

# Certification Tooling

Your certification profiles will be accessible on https://localhost:10000-10020.
The setup tool above will give you specific ports for each certification profile
you setup.

Note this is secured with a self signed CA, you'll need to add this CA to your
browsers allow list.

# Documentation
All of the documentation I could locate is built and made available from running
containers at [http://127.0.0.1:8080/docs/](http://127.0.0.1:8080/docs/).

Currently this includes the projects:

* pyjwkest
* pyoidc
* oidctest
