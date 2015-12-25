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

Make sure that those gems are available in your bundle.

If you don't want to add the gems to your bundle for whatever reason, you can
export the `GEM_DEPENDENCIES_AUTOINSTALL` variable with the `"true"` value and
`ci-scripts` will provide a version of the required gems automatically.

### Introduction:

`ci-scripts` provides a useful convention and `travis`-ish feel to configure
you continuous integration jobs. Everything in `ci-scripts` is written in
`Bash`, requiring version 4.2+.

`ci-scripts` is organized in `jobs` and `steps`. A `job` is composed of a
sequence of `steps`, which must correspond to script in the `build-scripts/`
directory. A `ci-scripts` `job` is just a `bash` array.

For example, the `failure_by_broken_post_hook` test job is defined at
`ci-jobs.sh.example` as:

```sh
failure_by_broken_post_hook=(
    tests/success
    tests/success_with_broken_post_hook
    tests/its_broken_if_you_see_this
)
```

Take the `success` job defined at the `ci-jobs.sh.example` file. In order to run
it, the build will execute the following scripts in order:

* `build-scripts/tests/success`
* `build-scripts/tests/success_with_no_hooks`
* `build-scripts/tests/success_because_minus_e_was_not_set`
* `build-scripts/tests/success`

The build will only succeed if every script returns with exit status 0.

Since everything is shell script, `ci-scripts` is highly flexible and
customizable.

### Configuring your JenkinsCI job:

Add the following lines to your Jenkins' *execute shell* step:

```sh
cd <your project root>
ci_scripts_version=$(cat .ci-scripts-version || echo master)

wget --output-document build-scripts.tar.gz \
  https://<gitlabhost>/ci-scripts/repository/archive.tar.gz?ref="${ci_scripts_version}"
tar xvf build-scripts.tar.gz --strip=1

build-scripts/build <build-type>
```

This will download this project build scripts and run them against your project
configuration. If no configuration is provided, the [ci-env.sh.example](./ci-env.sh.example)
and [ci-jobs.sh.example](./ci-jobs.sh.example) will be used instead.

### Ci-scripts configuration:

To customize your job, you need to add the `ci-jobs.sh` and `ci-env.sh` files to your
git project root. If you only intend to do a small modification of the default
environment or `job` definition, It is advised that you source the default file
in your script:

```sh
. ci-jobs.sh.example # at your custom ci-jobs.sh
. ci-env.sh.example # at your custom ci-env.sh
```

The `ci-jobs.sh` must define the build types and their steps for your project. See
[ci-jobs.sh.example](./ci-jobs.sh.example).

The `env.sh` must define environment variables that will be sourced into your
build scripts (contained in the `build-scripts/` directory). The `env.sh`

The `.ci-scripts-version` file must contain the git reference of this project
that you want to use in your CI build. For example, if you want to always use
the `v1.2.3.sbrebols` version (defined by a `git tag`), the contents of
`.ci-scripts-version` will be:

```
v1.2.3.sbrebols
```

If the `.ci-scripts-version` file is missing, `ci-scripts`' `master` will be
used to build your project.

### Overriding individual scripts

If you wish to override the behavior of some script provided by this repository,
or want to add one of your own making, just add the scripts in the
`build-scripts` directory of your project's git root.

For example, if you want to use your own rspec script, you should create a file
`build-scripts/rspec` in your project. The provided `build` script will use it
instead of the default one.

It's *important* to make sure that every script in that directory is
*executable*. (i.e., just `chmod +x` it)

If you just want to *ignore* a step in a build but don't want to redefine the
whole build it is easy to override the desired script with an empty file. For
example, in order to ignore the `bundle-outdated` step you can override the
`build-scripts/bundle-outdated` script with the following content:

```sh
#!/usr/bin/env bash
echo 'Skipping bundle outdated verification...'
echo 'For the night is dark and full of terrors.'
```

### Job and step hooks

#### Job post execution hook

Every `job` can associate a `post-execution hook` to itself. In order to do so,
you need to define a special job whose name is `#{job_name}_ensure`. For
example, the `post-execution hook` of the `success` job is called
`success_ensure`.

The `steps` executed in the `post-execution hook` **do not** affect the result
of the build. Those steps are intended to execute clean-up tasks, reporting,
alerting and things like that. They were created in order to add `gitlab`
merge-request notifications.

#### Step post and pre execution hooks

Every `step` can associate a `post-execution hook` and a `pre-execution hook` to
itself. In order to do so, the `build-scripts/build` script will look for a
script file named `#{step_name}_pre` to execute **before** the given `step` and
a script file named `#{step_name}_post` to execute **after** the given `step`.

Those hook `steps` are considered part of the build and, as such, must return
with exit status 0. Otherwise, the overall build will fail.

### Regression Testing

To check that you have not introduced any regressions, run:

```sh
cd $ci-scripts-root
./regression.sh
```

This command checks whether the "test" jobs are yielding the same output. Think
of it as some poor-man's specification

If you want to recreate the regression, just run:

```sh
cd $ci-scripts-root
./test.sh >regression.txt
```
