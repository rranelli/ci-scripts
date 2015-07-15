# Awesome CI scripts to make your life easier

## Usage:

### Configuration:

To customize your job, you need to add the `jobs.sh` and `env.sh` files to your
git project root.

The `jobs.sh` must define the build types and their steps for your project. See
[jobs.sh.example](./jobs.sh.example).

The `env.sh` must define environment variables that will be sourced into your
build scripts (contained in the `build-scripts/` directory)

The `.ci-scripts-version` file must contain the git reference of this project
that you want to use in your CI build. For example, if you want to always use
the `v1.2.3.sbrebols` version (defined by a `git tag`), the contents of
`.ci-scripts-version` will be:

```
v1.2.3.sbrebols
```

### Running your job

Add the following lines to your jenkins job:

```sh
cd <your project root>
wget --output-document build-scripts.tar.gz https://code.locaweb.com.br/locawebcommon/ci-scripts/repository/archive.tar.gz?ref="$(cat .ci-scripts-version || echo master)"
tar xvf build-scripts.tar.gz --strip=1
build-scripts/build <build-type>
```

This will download this project build scripts and run them against your project
configuration. If no configuration is provided, the [env.sh.example](./env.sh.example)
and [jobs.sh.example](./jobs.sh.example) will be used instead.
