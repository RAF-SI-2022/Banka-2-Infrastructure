# Infrastructure Documentation

The infrastructure repo is the central place for all Kubernetes-related code.

This repository does **not** contain the code to any microservice. Rather, it is used for configuring the environment the services will run in, automagically.

Other repositories in the project should **copy all the contents** of this directory into their root directory (as part of the CI/CD process) and activate the given scripts after setting environment variables.

## Environment Variables

The scripts in this repo **require** the following env vars to be set before executing:

* `ENV`: the name of the environment (`dev` or `prod`)
* `SIDE`: `backend` or `frontend`
* `NAMESPACE`: the Kubernetes namespace to execute the scripts in
* `SERVICES`: names of the services that should be built into images with Docker, separated by whitespace. There **must** exist a directory called `docker` in the project root, and within it, a `{service}.Dockerfile` for each service (service name must exactly match the name in the `$SERVICES` variable). The Dockerfiles will be build with the **project root directory as the context**, not the `docker` folder.