# [jpf91/fedora-systemd](https://github.com/jpf91/docker-fedora-systemd)

This image provides a systemd (base) image based on the latest fedora release.

It can be either used as a base image for other systemd based containers or as a
standalone image to run systemd timers and other units. It provides the following features:

* Redirects journal logs to console so they show up in podman / docker logs
* Disables TTY login
* Allows running scripts on each container start
* Allows running scripts on first container start

## Supported Architectures

Currently only `x86_64` images are being built, allthough the `Dockerfile` is not architecture dependent.

## Usage

### As base image

If you just want to use this image as a base image:
```
# https://fedoramagazine.org/building-smaller-container-images/
FROM docker.io/jpf91/fedora-systemd

# Install your packages
RUN microdnf install \
    nano && \
    microdnf clean all

# Add a script which is run once on first container start (extension must be .sh)
ADD 01-setup-script.sh /etc/initial-setup.d/01-setup-script.sh

# Add a script which is run on every container start (extension must be .sh)
ADD 01-start-script.sh /etc/initial-setup.d/01-start-script.sh
```

### Running using podman cli

```
podman run --name systemd -t \
  -v $PWD/test/services:/etc/systemd/user-units
  -v $PWD/test/start:/etc/start-scripts.user.d
  -v $PWD/test/setup:/etc/initial-setup.user.d
  docker.io/jpf91/fedora-systemd
```

Here's an example to run startup scripts and a custom systemd timer:

test/services/test.timer:
```ini
[Unit]
Description=Test Timer

[Timer]
OnCalendar=*:0/1

[Install]
WantedBy=timers.target
```

test/services/test.service:
```ini
[Unit]
Description=Test Unit

[Service]
Type=oneshot
ExecStart=/usr/bin/echo Test Unit Executing
```

test/setup/01-setup.sh:
```bash
#!/bin/sh
echo "Running Setup"

systemctl enable --now test.timer
```

test/start/01-echo.sh:
```bash
#!/bin/sh

echo "This is a start script"
```


## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 22:22` would expose port `22` from inside the container to be accessible from the host's IP on port `22` outside the container.

| Parameter | Function |
| :----: | --- |
| `-t` | In order for logging to work, a terminal needs to be allocated. |
| `-v /etc/systemd/user-units` | Place systemd service files here. Files will be symlinked to `/etc/systemd/system` once on first container start. See above for an example. |
| `-v /etc/start-scripts.user.d` | Place bash scripts here (extension `.sh`) which will be executed at every container start. |
| `-v /etc/initial-setup.user.d` | Place bash scripts here (extension `.sh`) which will be executed at initial container start. |

## Support Info

* Shell access whilst the container is running: `podman exec -it systemd /bin/bash`
* To monitor the logs of the container in realtime: `podman logs -f systemd`.
* Report bugs [here](https://github.com/jpf91/docker-fedora-systemd).

## Building locally

If you want to make local modifications to these images for development purposes or just to customize the logic:
```
git clone https://github.com/jpf91/docker-fedora-systemd.git
cd docker-fedora-systemd
podman build \
  -t docker.io/jpf91/fedora-systemd:latest .
```

## Versions

* **05.04.21:** - Initial Release.
