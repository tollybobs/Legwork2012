Legwork2012
===========

This is the source code for our 2012 (well, it was suppose to launch then anyway) website. Feel free to take a look around. If something in here inspires you or you stumble on something we could be doing better please get in touch. 

Thanks!

#Environment setup instructions

1. **Install VM dependencies**<br />
    Before setting up your local environment you will need VirtualBox, and Vagrant installed<br />
	https://www.virtualbox.org/<br />
	http://www.vagrantup.com/

2. **Clone repository and cd into directory** <br />
	`git clone git@github.com:legworkstudio/Legwork2012.git` <br />
	`cd Legwork2012`

3. **Edit file names** <br />
	change Vagrant.example to Vagrant<br />
	`mv Vagrant.example Vagrant`<br />
	change config/database.example.yml to config/database.yml<br />
	`mv config/database.example.yml config/database.yml`

4. **Build the virtual machine**<br />
	`vagrant up`<br />
	grab a cup of coffee, this may take a bit.<br />

5. **Set up Rails application**<br />
	`bundle install`<br />
	`rbenv rehash`<br />
	`rake db:create`<br />
	`rails s`

6. **Set up Heroku remotes**<br />
	you must be a collaborator for this step