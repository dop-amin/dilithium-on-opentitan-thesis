# Dilithium on OpenTitan

This repository accompanies the master's thesis "Dilithium on OpenTitan" and
provides the resources to reproduce the results.

## Overview

The contents in this repository:
- Submodule
  [`opentitan`](https://github.com/dop-amin/opentitan/tree/43ff969b418e36f4e977e0d722a176e35238fea9)
  is a fork from the [official OpenTitan
  repository](https://github.com/lowRISC/opentitan) and includes modifications
  to the OTBN simulator, instruction set, and our implementation of Dilithium,
  as well as the setup for testing and benchmarking said implementation.
- [`Dockerfile`](https://github.com/dop-amin/dilithium-on-opentitan-thesis/blob/main/Dockerfile)
  can be used to build the container for reproducing our results. In the build
  process, the aforementioned submodule is cloned into the container and the
  relevant dependencies from the OpenTitan project are installed.
- A file
  [`docker-compose.yml`](https://github.com/dop-amin/dilithium-on-opentitan-thesis/blob/main/docker-compose.yml)
  that acts as a convenience wrapper, mounting the host directory
  [`dilithium_benchmarks`](https://github.com/dop-amin/dilithium-on-opentitan-thesis/tree/main/dilithium_benchmarks)
  to a directory inside the container where the sqlite database holding the
  results will be stored.
- A directory
    [`dilithium_benchmarks`](https://github.com/dop-amin/dilithium-on-opentitan-thesis/tree/main/dilithium_benchmarks)
    that contains an exemplary database `dilithium_bench_example.db` and a
    script that can be used to evaluate the benchmark data from such a database
    called
    [`Evaluation.py`](https://github.com/dop-amin/dilithium-on-opentitan-thesis/blob/main/dilithium_benchmarks/Evaluation.py).

## Setup Instructions

For the setup, it is assumed that git, Docker, and Docker Compose are available
on the host system.

```bash
# Acquire the source code
git clone --recursive https://github.com/dop-amin/dilithium-on-opentitan-thesis.git
cd dilithium-on-opentitan-thesis
# Build the image
docker build -t dilithium-on-opentitan-image .
# Start the container 
docker compose up -d dilithium-on-opentitan
# Attach to the container
docker attach dilithium-on-opentitan
```

After the container setup is complete, a shell inside the container should be
open. The tests can be run and reproduced as follows. The option `-f` determines
the database file to evaluate, `-i` defines the IDs from the database to evaluate,
and `-o` optionally the output file to write the result to. As this directory is
mapped from the container to the host, the results will remain accessible after
quitting the container.

```bash
# Run a first test, may take some time as bazel sets itself up in this step (inside the Docker container's shell)
./bazelisk.sh test --cache_test_results=no --sandbox_writable_path="/home/ubuntu/dilithium_benchmarks" //sw/otbn/crypto/tests:dilithium_key_pair_bench
cd ../dilithium_benchmarks
# Run the evaluation script
python3 Evaluation.py -i 1 2 3 4 5 6 -f dilithium_bench_example.db -o my_result.txt
```

The naming for the tests follows this pattern
`//sw/otbn/crypto/tests:dilithium_{key_pair,sign,verify}{,_base}_bench` meaning,
there are separate tests for key pair generation, signing, and verification.
Appending _base to the operation selects the test that does not make use of our
modifications to the instruction set. By default, the number of tests to be run
is set to 2 though this can be varied in the file
`./sw/otbn/crypto/tests/dilithiumpy_bench_otbn/bench_dilithium.py` by setting
`ITERATIONS` to the number of desired iterations. `NPROC` can be used to define
how many processes will work on the given number of iterations in parallel. Note
that it may be required to increase the timeout of the test using
`--test_timeout` for a large number of iterations.

### Docker-less Setup

When using Docker is not desired, a local setup is also possible by following
the [instructions by the OpenTitan
Team](https://opentitan.org/book/doc/getting_started/index.html). Additionally,
the option `--sandbox_writable_path` needs to be defined to match the
`DATABASE_PATH` in
`./sw/otbn/crypto/tests/dilithiumpy_bench_otbn/bench_dilithium.py` such that the
result from the sandbox can be written to the host file system.