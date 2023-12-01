# Overview

This project demonstrates how to use spring-boot with GraalVM native compilation. The container are deployed on 
Google Cloud Run and the performances compared in a perf test.

This repository is a support for [this medium article](https://medium.com/google-cloud/cloud-run-the-spring-boot-rebirth-with-graalvm-native-compilation-bacd14307cb0)

# Usage

The file `command.txt` contains the commands to run the tests.

* Build the containers with Maven
* Push the containers to Architect Registry
* Deploy the containers on Google Cloud Run
* Run unitary test (on the URLs) 
* Run the perf test

# Requirements

The project requirement are the following:

* Java
* Maven
* Docker
* Google Cloud SDK (gcloud) with authentication on a project with
  * Cloud Run enabled
  * Artifact Registry enabled
* Curl and bc for the perf test


# Licence

This library is licensed under Apache 2.0. Full license text is available in
[LICENSE](https://github.com/guillaumeblaquiere/spring-boot-native/tree/main/LICENSE).