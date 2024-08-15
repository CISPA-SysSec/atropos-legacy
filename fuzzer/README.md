
# Overview

Atropos has multiple components. One part of it is the agent which is running in the VM and turning the inputs into actual executions of the PHP script via FastCGI. It's written in Nim and requires a patched fastcgi library.

The other component runs on the host system and generates the inputs etc., this one is implemented as a custom mutator for AFL++ in Python as it comes with built-in Nyx support and we can re-use the familiar GUI of it.

The VM support is implemented by Nyx, you need to install it first ([see here](../README.md)).

The web app itself is installed via docker containers so they can be easily transferred from the host to the VM. One advantage of this approach is that you can perform the installation of the web application via your web browser (many web apps require you to go step-by-step through a web UI to install it), perform a login and then save a snapshot of it so it can be re-used in the VM. This snapshot will contain the database, the sessions etc.

Use the docker_build.sh tool for that, check out the docker-lodel directory for an example of how to write a Dockerfile for the web application you want to test. It will also flatten and compress the image to save space and reduce the snapshot overhead.

# Install

To build the agent, we need to install Nim and Musl so the binary can be built statically on the host and be executed correctly inside of the VM.

```shell
curl  https://nim-lang.org/choosenim/init.sh  -sSf | sh
nimble  install  https://github.com/egueler/fastcgi.nim-patched.git
nim  --gcc.exe:musl-gcc  --gcc.linkerexe:musl-gcc  --passL:-static  c  --d:release  --opt:speed  atropos_agent.nim
cp  atropos_agent  webapp_share/
```

Install AFL++ with Nyx support. See [this guide](https://github.com/AFLplusplus/AFLplusplus/blob/stable/nyx_mode/README.md).

Now adjust the paths in the webapp_share/*.ron files so Nyx can find your snapshot and the webapp_share directory here etc.

Build your docker container via `docker_build.sh docker-xxx`.

To run Atropos, try something like this:

```shell
export SHAREDIR=$(realpath $SCRIPT_DIR/webapp_share/)
export WORKDIR=/dev/shm/workdir_$(basename $SHAREDIR)
cp atropos_agent $SHAREDIR/
pkill -9 -f qemu
python3 stop.py
sleep 2

mkdir  -p ${WORKDIR}_in;
echo  A > ${WORKDIR}_in/A;
mkdir  -p ${WORKDIR}_out;

python3  extract_filenames.py --src ./docker-xxx/html_bkp/ -o /tmp/filenames.txt -e ./docker-xxx/html_bkp/excludeme --add-parent-path /var/www/html

PYTHONPATH=$(pwd) AFL_PYTHON_MODULE=atropos_fuzzer AFL_CUSTOM_MUTATOR_ONLY=1  PHP_FILENAMES=/tmp/filenames.txt /home/user/atropos/aflplusplus-nyx/afl-fuzz -i ${WORKDIR}_in/ -o ${WORKDIR}_out/ -X $SHAREDIR -t 100000
```

Also check out parallel_fuzz.py which helps starting multiple fuzzers in parallel.

# Tips
Atropos uses Xeger to generate strings matching a regular expression, but the strings are usually pretty long, so you can adjust this:

```shell
nano  $HOME/.local/lib/python3.8/site-packages/rstr/xeger.py
# change this:
STAR_PLUS_LIMIT  =  3
```