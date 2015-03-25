# Docker container with SSH, PHP and Selenium meant for usage as Jenkins slave

This is a Docker container [sinso/jenkins-slave-php](https://registry.hub.docker.com/u/sinso/jenkins-slave-php/) based on [million12/behat-selenium](https://registry.hub.docker.com/u/million12/behat-selenium/) and [million12/php-app-ssh](https://registry.hub.docker.com/u/million12/php-app-ssh/). It maily combines the functionality of the last preceding containers and adds the possibility to configure public ssh keys (without using github)

Because it shares the same container as other running PHP apps (if based on million12/php-app), it can be used for continuous integration purposes, to easily build and run tests for TYPO3 Neos/Flow applications.

## Keys management

SSH keys are added from GitHub via GitHub API or can be set as an environment variable. The only thing you need to do is to provide your username (or usernames, coma-separated) via env variable `IMPORT_GITHUB_PUB_KEYS`. Of course you need to have your pubkey added on your GitHub account. To directly provide a public key just use the env variable `SSH_PUB_KEY`.

## Usage

`docker run -d -p 1122:22 --env="IMPORT_GITHUB_PUB_KEYS=user1,user2" sinso/jenkins-slave-php`

or

`docker run -d -p 1122:22 --env="SSH_PUB_KEY=ssh-rsa AAAAB3NzaC....0uSCQ==" sinso/jenkins-slave-php`

After container is launched, you can login:  
`ssh -p 1122 www@docker-host`

##### Fig example:  
```
dev:
  image: million12/php-app-ssh
  ports:
    - '1122:22'
  volumes_from:
    - webdata-container
  environment:
    IMPORT_GITHUB_PUB_KEYS: user1,user2,user3
    SSH_PUB_KEY: 'ssh-rsa AAAAB3NzaC....0uSCQ=='
```

## Credits

Thanks to the great work from Marcin ryzy Ryzycki <marcin@m12.io>
