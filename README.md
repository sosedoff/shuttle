# Shuttle

Shuttle is a minimalistic application deployment tool designed for small applications 
and one-server deployments. Configuration is stored as YAML-encoded file, no need to use ruby code. 
Operations are performed on SSH connection with target server. 

*Under heavy development*

## Install

Clone repository and run:

```
rake install
```

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

Deployment flow is split into steps:

- Establish connection with target server
- Prepare application structure. It'll create all required directories or skip if they already exist.
- Clone repository or check out latest code. Submodules will be automatically updated as well.
- Switch to specified branch (`master` by default)
- Create a new release directory and checkout application code
- Perform strategy-related tasks. 
- Create a symbolic link to the latest release
- Clean up old releases (default count: 5)

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
  strategy: static
  git: git@github.com:my-site.git

target:
  host: my-host.com
  user: username
  password: password
  deploy_to: /home/deployer/www
```

### Wordpress Strategy

This strategy is designed to deploy wordpress sites developed as a separate theme. It requires `subversion` installed on the server (will be automatically installed). 

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
-----> Cleaning up old releases: 1

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

## Test

To run project test suite execute:

```
bundle exec rake test
```

## License

Copyright (c) 2012-2013 Dan Sosedoff.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
