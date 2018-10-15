# Trellis
[![Release](https://img.shields.io/github/release/roots/trellis.svg?style=flat-square)](https://github.com/roots/trellis/releases)
[![Build Status](https://img.shields.io/travis/roots/trellis.svg?style=flat-square)](https://travis-ci.org/roots/trellis)

Ansible playbooks for setting up a LEMP stack for WordPress.

- Local development environment with Vagrant
- High-performance production servers
- One-command deploys for your [Bedrock](https://roots.io/bedrock/)-based WordPress sites

## Cimo WordPress Server

This is my company hosting server with my current clients.

### Cimo Specific Documentation

#### Adding a new site

1. Create empty directory. Name with the site domain name (this is a convention only).
2. Create new bedrock project within new directory

   $ composer create-project roots/bedrock .

3. Create a new GitHub repo. Run commands inside the site directory. Also ensure
   Your github ssh key is added to your environment (optional).

   $ git init .
   $ ssh-add ~/.ssh/[github-key-name]
   $ hub create

   The remotes this command creates do not work with my ssh config. Remove the
   created remotes in next step.

4. Remove incorrect origin and add correct origin master.

   $ git remote remove origin
   $ git remote add origin cimo-github:cimocimocimo/domain.com.git

5. Initial git commit and push

   $ git add *
   $ git commit -m 'Initial project commit'
   $ git push --set-upstream origin master

6. Add the site config to the wordpress_sites.yml file in the appropriate ./group_vars/[environment] directory.

   - For a local development site you only need to add it to wordpress_sites.yaml in the devlopment directory.
   - Make sure to add passwords/salts to the vault.yaml using ansible-vault from the server root
   $ ansible-vault edit group_vars/[environment]/vault.yml

7. Run local and remote provisioning commands

   - Local command:
   $ vagrant halt && vagrant up && vagrant provision

   Do not use vagrant reload, it does not add the new domain name to the hosts
   file. A full halt and up are required for those changes.

   - Remote provision, for both staging and production environments:
   $ ansible-playbook server.yml -e env=[environment]

#### Deploy to an existing site on Production

1. Deploy latest code to tracked branch

   The tracked branch is set in group_vars/[environment]/wordpress_sites.yml
   in the key 'branch'.

   Add the ssh keys required for access to github and to the server. Then run
   this command from the root of the server directory.

   $ ./bin/deploy.sh [environment] [domain.name]

2. Push new uploads from development if needed.

   $ ansible-playbook uploads.yml -i hosts/[environment] \
     --extra-vars="site=[domain.name] mode=push"

   Note: Push for sending files to the remote server. Pull for pulling them down
   to the local development server.

3. Deploy DB changes if needed.

   $ vagrant ssh

   Commands to run in the vagrant instance.

   Change to the root of the site directory.

   $ cd /srv/www/[domain.name]/current

   Run wp-cli export command

   $ wp db export

   Upload and import the .sql file to the target database and server. I usually
   do this with Sequel Pro.

   Change the local development domain name to the production domain name in the
   database with wp-cli

   $ wp search-replace '[development.domain.name]' '[production.domain.name]'

ansible-playbook uploads.yml -i hosts/production --extra-vars="site=rodcointeriors.com mode=push"


## What's included

Trellis will configure a server with the following and more:

* Ubuntu 16.04 Xenial LTS
* Nginx (with optional FastCGI micro-caching)
* PHP 7.2
* MariaDB (a drop-in MySQL replacement)
* SSL support (scores an A+ on the [Qualys SSL Labs Test](https://www.ssllabs.com/ssltest/))
* Let's Encrypt integration for free SSL certificates
* HTTP/2 support (requires SSL)
* Composer
* WP-CLI
* sSMTP (mail delivery)
* MailHog
* Memcached
* Fail2ban
* ferm

## Documentation

Full documentation is available at [https://roots.io/trellis/docs/](https://roots.io/trellis/docs/).

## Requirements

Make sure all dependencies have been installed before moving on:

* [Virtualbox](https://www.virtualbox.org/wiki/Downloads) >= 4.3.10
* [Vagrant](https://www.vagrantup.com/downloads.html) >= 2.0.1

## Installation

The recommended directory structure for a Trellis project looks like:

```shell
example.com/      # → Root folder for the project
├── trellis/      # → Your clone of this repository
└── site/         # → A Bedrock-based WordPress site
    └── web/
        ├── app/  # → WordPress content directory (themes, plugins, etc.)
        └── wp/   # → WordPress core (don't touch!)
```

See a complete working example in the [roots-example-project.com repo](https://github.com/roots/roots-example-project.com).

1. Create a new project directory: `$ mkdir example.com && cd example.com`
2. Clone Trellis: `$ git clone --depth=1 git@github.com:roots/trellis.git && rm -rf trellis/.git`
3. Clone Bedrock: `$ git clone --depth=1 git@github.com:roots/bedrock.git site && rm -rf site/.git`

Windows user? [Read the Windows docs](https://roots.io/trellis/docs/windows/) for slightly different installation instructions. VirtualBox is known to have poor performance in Windows — use VMware or [see some possible solutions](https://discourse.roots.io/t/virtualbox-performance-in-windows/3932).

## Local development setup

1. Configure your WordPress sites in `group_vars/development/wordpress_sites.yml` and in `group_vars/development/vault.yml`
2. Run `vagrant up`

[Read the local development docs](https://roots.io/trellis/docs/local-development-setup/) for more information.

## Remote server setup (staging/production)

For remote servers, installing Ansible locally is an additional requirement. See the [docs](https://roots.io/trellis/docs/remote-server-setup/#requirements) for more information.

A base Ubuntu 16.04 server is required for setting up remote servers. OS X users must have [passlib](http://pythonhosted.org/passlib/install.html#installation-instructions) installed.

1. Configure your WordPress sites in `group_vars/<environment>/wordpress_sites.yml` and in `group_vars/<environment>/vault.yml` (see the [Vault docs](https://roots.io/trellis/docs/vault/) for how to encrypt files containing passwords)
2. Add your server IP/hostnames to `hosts/<environment>`
3. Specify public SSH keys for `users` in `group_vars/all/users.yml` (see the [SSH Keys docs](https://roots.io/trellis/docs/ssh-keys/))
4. Run `ansible-playbook server.yml -e env=<environment>` to provision the server

[Read the remote server docs](https://roots.io/trellis/docs/remote-server-setup/) for more information.

## Deploying to remote servers

1. Add the `repo` (Git URL) of your Bedrock WordPress project in the corresponding `group_vars/<environment>/wordpress_sites.yml` file
2. Set the `branch` you want to deploy
3. Run `./bin/deploy.sh <environment> <site name>`
4. To rollback a deploy, run `ansible-playbook rollback.yml -e "site=<site name> env=<environment>"`

[Read the deploys docs](https://roots.io/trellis/docs/deploys/) for more information.

## Contributing

Contributions are welcome from everyone. We have [contributing guidelines](https://github.com/roots/guidelines/blob/master/CONTRIBUTING.md) to help you get started.

## Gold sponsors

Help support our open-source development efforts by [contributing to Trellis on OpenCollective](https://opencollective.com/trellis).

<a href="https://kinsta.com/?kaid=OFDHAJIXUDIV"><img src="https://roots.io/app/uploads/kinsta.svg" alt="Kinsta" width="200" height="150"></a> <a href="https://www.harnessup.com/"><img src="https://roots.io/app/uploads/harness-software.svg" alt="Harness Software" width="200" height="150"></a> <a href="https://k-m.com/"><img src="https://roots.io/app/uploads/km-digital.svg" alt="KM Digital" width="200" height="150"></a> <a href="https://themeisle.com/"><img src="https://roots.io/app/uploads/sponsor-themeisle.svg" alt="ThemeIsle" width="200" height="150"></a>

## Community

Keep track of development and community news.

* Participate on the [Roots Discourse](https://discourse.roots.io/)
* Follow [@rootswp on Twitter](https://twitter.com/rootswp)
* Read and subscribe to the [Roots Blog](https://roots.io/blog/)
* Subscribe to the [Roots Newsletter](https://roots.io/subscribe/)
* Listen to the [Roots Radio podcast](https://roots.io/podcast/)
