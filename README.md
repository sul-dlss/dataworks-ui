# README

This is the repository for the experimental prototype Blacklight application for DataWorks. 

* Local installation
After cloning the repository, you will need to run the following commands:

    $ bundle install
    $ yarn install
    $ rails db:migrate

* Solr
You will have to setup a Solr instance that includes the fields specified in the catalog controller.  As an example, you may look at the dwexp-demo Solr collection in the SUL DLSS Solr instance.

You can set the SOLR URL in the config/blacklight.yml file directly or set an environment variable for the Solr index you are using for your local installation.

* Starting the system locally

You can start the application locally using 
    $ bundle install

and then navigating to http://localhost:3000.
