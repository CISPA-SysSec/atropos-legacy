# Subjects for Atropos (PHP-Fuzzing Project)

To start a container for a program use:

```bash
PROG=DVWA ./build-images.sh
```

Additionally, the `TOOL` argument can be given to add the tool to the image as
well.

```bash
PROG=DVWA TOOL=ZAP ./build-images.sh
```

To exec into the docker container, use the `./exec-images.sh` script. This
requires that the `./build-images.sh` command is being run
(so that the created container is still running), additionally, only one
of the containers based on that image can be alive.

```bash
PROG=DVWA TOOL=ZAP ./exec-images.sh
```
