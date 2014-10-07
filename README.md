# Shuttle

Shuttle is a minimalistic application deployment tool designed for small applications 
and one-server deployments. Configuration is stored as YAML-encoded file, no need to use ruby code. 
Operations are performed on SSH connection with target server. 

![Build Status](http://img.shields.io/travis/sosedoff/shuttle.svg?style=flat)

![Gem Version](http://img.shields.io/gem/v/shuttle-deploy.svg?style=flat)

## Install

Install from Rubygems:

```
gem install shuttle-deploy
```

Or install manually (clone repo first):

```
rake install
```

Supported ruby versions:

- 1.8.7
- 1.9.2
- 1.9.3
- 2.0.0
- 2.1.0
- 2.1.2

## Structure

Deployment structure is very similar to capistrano.

Application files will be stored in `deploy_to` path that you specify in config. 
Directory structure:

- `releases` - Main directory to store all application releases
- `current` - Symbolic link to the latest release
- `shared` - Shared directory to store assets, configs, etc
- `scm` - Code repository directory
- `version` - File that contains current release number

Shared directory structure:

- `tmp` - Temporary files
- `pids` - Shared process IDs files
- `log` - Shared log files

## Process

Deployment flow consists of steps:

- Connect to remote server
- Prepare application structure (releases, shared dirs, etc)
- Clone or update git/svn repository code from specified branch
- Create a new release and checkout application code
- Perform strategy-defined tasks
- Make new release current
- Cleanup old releases

## Strategies

Available deployment strategies:

- `static`
- `wordpress`
- `ruby`
- `rails`
- `nodejs`

### Static Strategy

This is a default strategy that does not perform any application-related tasks. 
Example configuration:

```yaml
app:
  name: my-application
  git: git@github.com:my-site.git

target:
  host: my-host.com
  user: username
  password: password
  deploy_to: /home/deployer/www
```

### WordPress Strategy

This strategy is designed to deploy wordpress sites developed as a separate theme. 
It requires `subversion` installed on the server (will be automatically installed).

Define strategy:

```
app:
  strategy: wordpress
```

Wordpress applications are configured and deployed with `wp` cli utility. On a clean setup 
shuttle will attempt to install wp-cli and wordpress core first. CLI is installed from 
main github repository and latest stable tag. Wordpress core will install latest version.
To specify required versions, use wordpress section:

```
wordpress:
  core: 3.5.1
  cli: 0.9.1
```

Then, you'll need to define theme and wp related options:

```
wordpress:
  theme: my-theme
  site:
    title: "Site Title"
    url: "http://sample-site.com"
    admin_name: "admin"
    admin_email: "admin@admin.com"
    admin_password: "password"
```

Database options:

```
wordpress:
  mysql: 
    host: 127.0.0.1
    user: mysql-user
    password: mysql-password
    database: mysql-database
```

You can also provide a list of required plugins:

```
wordpress:
  plugins:
    - acf
    - acf: git://github.com/elliotcondon/acf.git
    - acf: http://my-site.com/acf.zip
    - acf: http://my-site.com/acf.tar.gz
```

For more detailed example, check `examples/wordpress.yml`

### Rails Strategy

Rails deployment strategy will deploy your basic application: install dependencies, 
migrate database, precompile assets and start web server. Most of the steps are automatic.

Define strategy first:

```yml
app:
  name: myapp
  strategy: rails
```

Then add a separate section:

```yml
rails:
  environment: production
  precompile_assets: true
  start_server: true
```

If using `start_server`, shuttle will try to start thin server. 
You can modify settings for thin:

```yml
thin:
  host: 127.0.0.1
  port: 9000
  servers: 5
```

You can also use `foreman` to run application:

```yml
rails:
  start_server: false

hooks:
  before_link_release:
    - "sudo bundle exec foreman export upstart /etc/init -a $DEPLOY_APP -u $DEPLOY_USER -p 9000 -l $DEPLOY_SHARED_PATH/log"
    - "sudo start $DEPLOY_APP || sudo restart $DEPLOY_APP"
```

## Deployment Config

Deployment config has a few main sections: `app` and `target`. 

### Application

Application section defines deployment strategy, source code location and other options:

```yml
app:
  name: my-app
  strategy: static
  git: https://site-url.com/repo.git
  branch: master
  keep_releases: 5
```

Options:

- `name` - Your application name
- `strategy` - Deployment strategy. Defaults to `static`
- `git` - Git repository url
- `branch` - Git repository branch. Defaults to `master`
- `keep_releases` - Number of releases to keep. Defaults to `10`

You can also use Subversion as a main source:

```yml
app:
  svn: http://site-url.com/repo.git
```

If your repository requires authentication, use url in the following format:

```
http://username:password@yourdomain.com/project
```

### Target

Target is a set of remote machine credentials:

```yml
target:
  host: yourdomain.com
  user: deployer
  password: password
  deploy_to: /home/deployer/myapp
```

Options:

- `host` - Remote server host or ip
- `user` - Remote server user account
- `password` - Optional password. Use passwordless authentication if possible.
- `deploy_to` - Primary directory where all releases will be stored

You can also define multiple targets per config if environments does not have any specific 
configuration settings:

```yml
targets:
  production:
    host: mydomain.com
    user: deployer
    deploy_to: /home/production/myapp
  staging:
    host: mydomain.com
    user: deployer
    deploy_to: /home/staging/myapp
```

### Deployment environment

During deployment shuttle sets a few environment variables:

- `DEPLOY_APP`          - Application name
- `DEPLOY_USER`         - Current deployment user
- `DEPLOY_PATH`         - Path to application releases
- `DEPLOY_RELEASE`      - New release number
- `DEPLOY_RELEASE_PATH` - Path to currently executing release
- `DEPLOY_CURRENT_PATH` - Path to current release (symlinked)
- `DEPLOY_SHARED_PATH`  - Path to shared resources
- `DEPLOY_SCM_PATH`     - Path to code repository

These could be used in hooks. Example:

```
hooks:
  before_link_release:
    - "cp $DEPLOY_SHARED_PATH/myconfig $DEPLOY_RELEASE_PATH/myconfig"
```

## Usage

To execute a new deploy, simply type (in your project folder):

```
shuttle deploy
```

Output will look like this:

```
Shuttle v0.2.0

-----> Connected to deployer@mysite.com
-----> Preparing application structure
-----> Fetching latest code
-----> Using branch 'master'
-----> Linking release
-----> Release v35 has been deployed

Execution time: 2s
```

If using multiple targets in config, you can specify which target to use with:

```
shuttle staging deploy
```

Specify a path to config with `-f` flag:

```
shuttle -f /path/to/config.yml deploy
```

To run in debug mode, add `-d` flag:

```
shuttle deploy -d
```
## Hooks

List of all available hooks that you can use to run custom commands:

- `before_setup`         - Before base application directories are created
- `after_setup`          - After application directories are created
- `before_checkout_code` - Before code update (git pull, etc)
- `after_checkout_code`  - After code has been updated
- `before_link_release`  - Before linking release
- `after_link_release`   - After release has been linked
- `before_rollback`      - Before rollback operation
- `after_rolback`        - After rollback operation

Each hook could include one or many bash commands.

## Tasks

Tasks are user-defined commands or a set of multiple commands that could be integrated
into hooks. The benefit of having tasks defined separate from the hooks is to 
make deployment steps more readable.

Here's an example a task:

```yaml
tasks:
  flush_cache:
    - bundle exec cache:clear

  reset_counters:
    - bundle exec counters:submit
    - bundle exec counters:reset

hooks:
  before_link_release:
    - task=flush_cache
    - task=reset_counters
```

Tasks could only be invoked from a hook, invoking a task from within another task
does not work and intended to keep things simple.

Commands in tasks are treated in the same way as commands in a hook, thus any failure
of a command within a hook that does not allow any failures will trigger a deployment
rollback. The only hook that allows failures is `after_link_release`, basically
release is already symlinked and if something goes wrong it will not affect anything.

Tasks are also a great way to split up groups of steps into smaller, more logical
chunks.

## Rollback

In case if you want to revert latest deploy, run:

```
shuttle rollback
```

Last release will be permanently destroyed and previous release will be symlinked
as current. If you wish to run some commands on rollback, you can specify a hook:

```yaml
hooks:
  before_rollback:
    - bash commands
  after_rollback:
    - bash commands
```

## Generators

You can generate deployment config with CLI:

```
shuttle generate static
```

## Test

To run project test suite execute:

```
bundle exec rake test
```

## License

The MIT License

Copyright (c) 2012-2014 Dan Sosedoff
