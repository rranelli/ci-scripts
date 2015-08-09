# Awesome CI scripts to make your life easier

## Usage:

### Requirements:

If you intend to use the default CI suite, make sure your Gemfile contains the
following gems:

- brakeman
- bundler-audit
- rubycritic
- rubocop
- gitlab

We recommend you to do something in the lines of [this commit](https://code.locaweb.com.br/paas/recipes-manager/commit/e2aa7840fb5a50bac146f8ea47119246a75f0516)

### Configuration:

To customize your job, you need to add the `ci-jobs.sh` and `ci-env.sh` files to your
git project root.

The `ci-jobs.sh` must define the build types and their steps for your project. See
[ci-jobs.sh.example](./ci-jobs.sh.example).

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
configuration. If no configuration is provided, the [ci-env.sh.example](./ci-env.sh.example)
and [ci-jobs.sh.example](./ci-jobs.sh.example) will be used instead.

### Overriding individual scripts

If you wish to override the behavior of some script provided by this repository,
or want to add one of your own making, just add the scripts in the
`build-scripts` directory of your project's git root.

For example, if you want to use your own rspec script, you should create a file
`build-scripts/rspec` in your project. The provided `build` script will use it
instead of the default one.

It's *important* to make sure that every script in that directory is
*executable*. (i.e., just `chmod +x` it.)
