# Eirini Filesystem

This package contains all necessary code to run a Cloud Foundry (CF) app on Kubernetes. It is used by Eirini's [`k8s`](https://github.com/cloudfoundry-incubator/eirini/tree/master/k8s) package to run the app as Kubernetes `StatefulSet`.

If no startup command was provided for a CF app, this package parses the `startup_command` from `staging_info.yml` (inside the CF app). It simply wraps the launcher (added via the `buildpackapplifecycle` submodule), which provides the environment setup and launch command for the the app. 

The `launchcmd` is then provided together with [`cflinuxfs2`](https://github.com/cloudfoundry/cflinuxfs2) and [`launcher`](https://github.com/cloudfoundry/buildpackapplifecycle/tree/master/launcher) as `eirinifs.tar`, forming the root filesystem of the CF app. The [bits-service](https://github.com/cloudfoundry-incubator/bits-service) consumes the GitHub release of `eirinifs` when building the OCI image for the CF app (running in Kubernetes).

Building and updating the release is handled in the [CI pipeline](ci). Use `ci/set-pipeline` to configure it.

