## CentOS 6.8 based Customizable Apache Container - 363 MB - Updated 11/29/2016

***This container is built from appcontainers/centos:6***

># Description:

This container has 2 variants of which are built from appcontainers/centos:6, and appcontainers/debian_jessie, respectively. Both base OS's are slightly modified bare bones of CentOS 6.8, and Debian 8 Jessie Minimal Installations.
The images all reside on both the docker hub as well as the quay registry. If you would prefer to use the images distributed from quay.io, just simply append quay.io to the front of the namespace/repository designation as such in the examples quay.io/appcontainers/centos, and quay.io/appcontainers/debian. Modifications to the minimal installations of the base images can be found by looking at the appcontainers/centos, and appcontainers/debian repositories located below:

[appcontainers/centos on the Docker Hub](https://registry.hub.docker.com/u/appcontainers/centos) \
[appcontainers/centos on the Quay Registry](https://quay.io/repository/appcontainers/centos)

[appcontainers/debian on the Docker Hub](https://registry.hub.docker.com/u/appcontainers/debian>) \
[appcontainers/debian on the Quay Registry](https://quay.io/repository/appcontainers/debian)

This containers purpose is to get a customizable Apache instance up and running with a single docker run statement. The container is built with environment variables that allow the user to plug in custom values which will allow the container to configure itself on first run. This will give the user a fully customized experience just as if you set up Apache on your own from scratch.

__NOTE: The following documentation will reference the latest tag, referring to CentOS, if you would like to run Debian instead, just add the tag :debian to the image name instead of using either the default (latest) or centos.__  

&nbsp;  

># You Tube Demo:

https://www.youtube.com/watch?v=O1JxHnkLhEw

&nbsp;  

># Container Variables:

The container is built to allow several configurable variables to be passed in at run time. The values are as follows:

- APP_NAME - This is the fully qualified domain name such as example.com. This should be passed without any prefix such as www.
- APACHE_SVRALIAS - This is exactly what it sounds like, the apache file ServerAlias Directive data.
- MODE - A toggle to tell the container to just run as a persistent data volume with no services or run as a normal standalone apache server.
- ENV - Variable to hold the environment, currently it serves no other purpose but is there in case it's needed
- TERMTAG - Environment variable to hold the highlighted bash shell tag. Currently set to the repo name, but can be change from within the container via TERMTAG="Whatever You Want"

__NOTE: If you have connected the server to a data volume that already contains a Apache instance, or has a pre-generated certificate, then when a new Apache container is fired off using those volumes, it will detect those existing files, and will NOT perform any reconfiguration on either the existing Apache instance, nor create a new SSL cert. It will use the existing ones in place. This is assuming that the Apache install folder, and certificate are named the same as the APP_NAME variable passed.__

&nbsp;

># MODE Values:

+ Standalone - Start a local Apache instance, and run all apache/php services in the container.
+ DataVol - This mode will uninstall the mod_rewrite, mod_ssl, mod_env, php php-common, php-cli, php-mysql and httpd packages. This mode is intended to be used solely as a data volume, allowing another instance to connect to the installed directory structure of the application for persistent storage.

&nbsp;

># Running the Container:

```bash
docker run -d -it --name apache -h apache -p 80:80 -p 443:443 appcontainers/apache:centos
```

*This will assume the following*

+ ENV = dev
+ TERMTAG = Apache
+ MODE = standalone
+ APP_NAME  = apache.local
+ APACHE_SVRALIAS = www.apache.local localhost

Setting any of the above values will tell the container to replace the default values already set within the container with the values that are supplied at runtime. For example, if you pass in -e APP_NAME=mysite.com then Apache will be pre configured for mysite.com. The project folder located in /var/www/html will be named mysite.com, and Apache will be set to listen for requests to mysite.com etc.. Additionally SSL Self Signed certs are generated in the /etc/pki/tls directory (centos) or the /etc/ssl directory (debian), and mysite.com is auto configured to listen for both HTTP/HTTPS requests.. To test the container, you simply can run it, hit the IP via a standard http or https request, and you will be presented with a php info page showing you the status of PHP and all of the PHP modules that are pre installed.

### Running the container in standalone mode, with customized variable values:

```bash
docker run -d -it \
--name apache \
-h apache \
-p 80:80 \
-p 443:443 \
--restart=always \
-e APP_NAME='testapp.com' \
-e APACHE_SVRALIAS='www.testapp.com localhost' \
-e ENV=production \
-e TERMTAG=APACHE \
-e MODE=standalone \
appcontainers/apache:centos
```

This example will start a new container named Apache, It will configure apache for the testapp.com site, additionally a self signed SSL cert will be generated generated, and the site will be configured to be accessible via HTTP/HTTPS listening on port 80 and 443 respectively within the container. Host port 80 will be mapped to the Apache container port 80, and host port 443 will be mapped to the Apache container port 443. The restart policy will be set to always, meaning that if the container crashes unexpectedly, it will automatically kick itself back off. Mode is set to standalone, meaning that Apache will run fully within the single container. At this point your app is fully configured and you need just to go the default URL via HTTP/HTTPS. The default URL will either be the IP address or the FQDN of the host running the container. You can either hit the IP address of the host on port 80/443, put a host file entry in mapping the host IP with testapp.com, allowing you to hit testapp.com directly from a browser, or if the container is running locally, then you can hit it via localhost, 127.0.0.1, or by the container IP which can be obtained with a `docker inspect apache | grep IP`.

### Running the container in "Datavol" or "datavol" mode, with customized variable values:

As named above, the intention of the datavol mode is to set up a shell of the Apache directory structure that will be set as persistent storage. The idea is that the /var/www/html, and /etc/pki/tls (or /etc/ssl), directories will be flagged as persistent. A second actual front end instance container will then be run, connected to the persistent volume and will perform the configuration of the Apache application. This configuration will allow you to remove the Apache container in order to upgrade to a new one or reset it in the future, without loosing any of your Apache project data.

__Note: When the Apache container initially runs, it checks for the existence of both the Apache directory and an existing certificate, and if detected, it skips either existing or both of the Apache configuration steps, or certificate creation steps respectively. Each of these checks are independent of each other, meaning that if a Apache directory is detected, but no certificate is detected, then it will skip only the Apache configuration piece, but will generate a new certificate. These checks are dependent upon the Apache folder, and certificate being named the same as the APP_NAME variable. Example, if APP_NAME=example.com, then the check will search for the /var/www/html/example.com directory, and then check for an existing certificate in either /etc/pki/tls/certs/example.com.crt on CentOS, or /etc/ssl/certs/example.com.crt on debian. The checks are based on the initial configuration of the application via the very first original container run, which does perform both of those configurations.__

```bash
docker run \
--name apache_data \
-h apache_data \
-v /var/www/html \
-v /etc/pki/tls \
-e MODE="datavol" \
-e ENV=production \
-e TERMTAG=APACHE-DATA \
appcontainers/apache:centos \

docker run -d -it \
--name apache \
-h apache \
-p 80:80 \
-p 443:443 \
--volumes-from apache_data \
--restart=always \
-e MODE=remote \
-e APP_NAME='testapp.com' \
-e APACHE_SVRALIAS='www.testapp.com localhost' \
-e ENV=production \
-e TERMTAG=APACHE \
appcontainers/apache:centos
```

__Note: This mode removes all httpd/php/ packages from the datavol container. It is intended to be used a persistent storage only, and not actually run any application services. The Apache front end container will use the data volumes directory structure as it's own, mapping the data volume /var/www/html and /etc/pki/tls respectively from the data volume container as it's own /var/www/html, and /etc/pki/tls directories. This will allow the user to have the option of completely removing the Apache front end container entirely, and replace it with another (even another distribution) without removing or erasing any of the actual data stored in /var/www/html or /etc/pki/tls. If switching distributions, from centos to debian, the certificate will be reissued, as centos uses /etc/pki/tls and debian uses /etc/ssl as the directory to store certificates.__

&nbsp;

># Access the new Install :

#### Simply Navigate to the IP address of the host/container via a standard http or https request, and you will be presented with a php info page showing you the status of PHP and all of the PHP modules that are pre installed. (80/443 default). You also could put a host file entry in mapping the host IP with the configured $APP_NAME, allowing you to hit that URL directly from a browser, or if the container is running locally, then you can hit it via localhost, 127.0.0.1, or by the container IP which can be obtained with a `docker inspect apache | grep IP`.

#### Once the container is up and running you can attach to the container via `docker exec -it apache bash`, navigate to the /var/www/html/$APP_NAME directory and either git clone your project into the folder, or create a new project within the folder to use the container yourself. Alternatively you can copy an existing project on your local machine via `docker cp /path/to/your/project apache:/var/www/html/$APP_NAME`. Lastly if an apache restart (restarting the entire container) is not convenient, then you can launch the container appending the command `/bin/bash` to the end of any of the docker run statements above, and then simply attach to the container via `docker attach apache` (hit enter twice), which will make the container act like a standard VM, allowing you to stop and start services normally. When you are finished in either the attached or exceed container, do not type exit (which would shut down the container), but instead use the detach key combination of `CTL P` + `CTL Q`.

&nbsp;

># Launching the Container via docker-compose:

Copy the text below and paste it into a file named docker-compose.yml. Then you can navigate to the directory and provided that you have docker-compose installed, just issue the following command in order to launch off the application stack:

`docker-compose up -d`

__NOTE: If you need assistance setting up docker-compose please visit [http://www.appcontainers.com](http://www.appcontainers.com/installing-and-deploying-containers-using-docker-compose/) to watch the tutorial or read about the installation process.__

>## Centos:

```bash
webdata:
  image: appcontainers/apache:centos
  hostname: webdata
  stdin_open: true
  tty: true
  volumes:
  * /var/www
  * /etc/pki/tls
  environment:
  * MODE=datavol
  command: sleep 1

web:
  image: appcontainers/apache:centos
  hostname: apache
  stdin_open: true
  tty: true
  restart: always
  ports:
  * "80:80"
  * "443:443"
  volumes_from:
  * webdata
  environment:
  * TERMTAG=APACHE
  * ENV=production
  * MODE=standalone
  * APP_NAME=apachetest.com
  * APACHE_SVRALIAS=www.apachetest.com localhost
```

>## Debian:

```bash
webdata:
  image: appcontainers/apache:debian
  hostname: webdata
  stdin_open: true
  tty: true
  volumes:
  * /var/www
  * /etc/ssl
  environment:
  * MODE=datavol
  command: sleep 1

web:
  image: appcontainers/apache:debian
  hostname: apache
  stdin_open: true
  tty: true
  restart: always
  ports:
  * "80:80"
  * "443:443"
  volumes_from:
  * webdata
  environment:
  * TERMTAG=APACHE
  * ENV=production
  * MODE=standalone
  * APP_NAME=apachetest.com
  * APACHE_SVRALIAS=www.apachetest.com localhost
```

__NOTE: This image is now set to generate a SSL key/cert Pair on first run. This cert is not shared with anyone else, and is also only self signed, which will allow for HTTPS connections, but will not be a valid trusted certificate. If you wish to use a valid trusted certificate, then place your own key/cert in /etc/pki/tls/private, and /etc/pki/tls/certs, respectively, and change the Apache configuration accordingly in /etc/httpd/conf.d/$APP_NAME.conf if the certificate name has been changed from its default value.__

__NOTE: These values change to /etc/ssl/private, /etc/ssl/certs, and /etc/apache2/apache2.conf respectively for builds running debain/centos__

&nbsp;

># Dockerfile Change-log:

    06/11/2016 - Upgraded to latest OS versions.
    12/14/2015 - Added auto Apache restart so it doesn't have to be launched in /bin/bash
    08/10/2015 - Upgrade to CentOS 6.7
    07/08/2015 - Update Apache with New Templates, and base off new images.
    05/21/2015 - Datavol Mode Added, Check for existing index.php file
    05/06/2015 - Configuration script changes to output more information, included php info page in default web dir.
    05/01/2015 - Apache Container Created

&nbsp;

># Verification

```bash
------------------------
Test Standalone Version
------------------------
docker run -it \
--name apache \
-h apache \
-p 80:80 \
-p 443:443 \
-e APP_NAME='testsite.com' \
-e APACHE_SVRALIAS='www.testsite.com localhost' \
-e ENV=production \
-e TERMTAG=APACHE \
appcontainers/apache

------------------------
Test Datavol
------------------------
# Launch the following, then remove the Apache container, and run another Apache web container only, leaving the datavolume in tact.

docker run -it \
--name apache_data \
-h apache_data \
-v /var/www/html \
-v /etc/pki/tls \
-e MODE="datavol" \
-e TERMTAG=WEBDATA \
appcontainers/apache

docker run -it \
--name apache \
-h apache \
-p 80:80 \
-p 443:443 \
--volumes-from apache_data \
-e APP_NAME='testsite.com' \
-e APACHE_SVRALIAS='www.testsite.com localhost' \
-e TERMTAG=APACHE \
appcontainers/apache

-------------------------------------
Test docker-compose front end upgrade
-------------------------------------
docker-compose up -d

echo "<?php echo 'Test DataVol'; ?>" > /var/www/html/testsite.com/test.php

docker kill apache_web_1
docker rm apache_web_1

docker run -it \
--name apache_web_1 \
-h apache_web_1 \
-p 80:80 \
-p 443:443 \
--volumes-from apache_webdata_1 \
-e APP_NAME='apachetest.com' \
-e APACHE_SVRALIAS='www.apachetest.com localhost' \
-e TERMTAG=APACHE \
appcontainers/apache
```
