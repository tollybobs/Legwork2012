Legwork2012
===========

This is the source code for our 2012 (well, it was suppose to launch then anyway) website. Feel free to take a look around. If something in here inspires you or you stumble on something we could be doing better please get in touch. 

Thanks!

#Environment setup instructions

1. Install VM dependencies
Before setting up your local environment you will need VirtualBox, and Vagrant installed

https://www.virtualbox.org/
http://www.vagrantup.com/

2. Clone repository and cd into directory

`git clone git@github.com:legworkstudio/Legwork2012.git`
`cd Legwork2012`

3. Edit file names

change Vagrant.example to Vagrant
`mv Vagrant.example Vagrant`

change config/database.example.yml to config/database.yml

4. Build the virtual machine

`vagrant up`
grab a cup of coffee, this may take a bit.

5. Set up Rails application

install dependencies
`bundle install`

`rbenv rehash`

create database
`rake db:create`

start server
`rails s`

6. Set up Heroku remotes

you must be a collaborator for this step