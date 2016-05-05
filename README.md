# Docker Scripts for TIBCO BusinessWorks™ Container Edition 
The TIBCO BusinessWorks™ Container Edition (BWCE) Docker image is a highly extensible docker base image for running TIBCO BusinessWorks™ Container Edition applications. This image can be customized for supported third-party drivers, OSGI bundles, integration with application configuration management systems, application certificate management etc.

TIBCO BusinessWorks(TM) Container Edition allows customers to build microservices with an API-first approach and deploy them to cloud-native platforms such as [Cloud Foundry(TM)](http://pivotal.io/platform) and [Kubernetes](http://kubernetes.io/). By elegantly right-sizing TIBCO ActiveMatrix BusinessWorks(TM), it brings visual application development and integration capabilities to any enterprise platform as a service.

To know more about TIBCO BusinessWorks™ Container Edition, visit [Documentation](https://docs.tibco.com/products/tibco-businessworks-container-edition-2-0-0)

These Docker scripts are subject to the license shared as part of the repository. Review the license before using or downloading these scripts.

##Prerequisite
  * Access to [TIBCO™ eDelivery](https://edelivery.tibco.com)
  * [Docker](https://docs.docker.com/engine/installation/)
    
##Download TIBCO BusinessWorks™ Container Edition
Download appropriate TIBCO BusinessWorks™ Container Edition 2.0.0 artifacts from [TIBCO™ eDelivery](https://edelivery.tibco.com/storefront/eval/tibco-businessworks-container-edition/prod11654.html). It contains TIBCO BusinessWorks™ Container Edition runtime (bwce_cf.zip).
     
##Create TIBCO BusinessWorks™ Container Edition Base Docker Image
   1. Clone this repository onto your local machine.
   2. Locate the bwce_cf.zip file from the downloaded artifacts and run [createDockerImage.sh](createDockerImage.sh). This will create the BWCE base docker image.

##Extend TIBCO BusinessWorks™ Container Edition Base Docker Image
You can customize the base docker image for supported third-party drivers e.g. Oracle JDBC driver, OSGified bundles or to add runtime of supported Plug-ins in BWCE runtime. It can also be customized for application certificate management as well as to integrate with application configuration management services.
* **Provision suppprted JDBC drivers**:
     * Run **bwinstall[.exe] help** from `<BWCE_HOME>/bin` and follow instructions to add the driver to your BWCE installation.
     * Copy the appropriate driver OSGi bundle from `<BWCE_HOME>/config/drivers/shells/<driverspecific runtime>/runtime/plugins/` to the `<Your-local-docker-repo>/resources/addons/jars` folder. 
* **Provision [OSGi](https://www.osgi.org) bundle jar(s)**: Copy OSGified bundle jar(s) into `<Your-local-docker-repo>/resources/addons/jars`
* **Application Configuration Management**: TIBCO BusinessWorks™ Container Edition supports [Consul](https://www.consul.io/) configuration mechanism out of the box. Refer https://docs.tibco.com/pub/bwce/2.0.0/doc/html/GUID-3AAEE4AD-8701-4F4E-AD7B-2416A9DDA260.html for further details. To add support for other systems, update `<Your-local-docker-repo>/java-code/ProfileTokenResolver.java`. This class has a dependecy on Jackson(2.6.x) JSON library. You can pull these dependencies from the installation `<BWCE_HOME>/system/shared/com.tibco.bw.tpcl.com.fasterxml.jackson` or download it from the web.
* **Certificate Management**: There are use cases where you need to use certificates into your application to connect to different systems. For example, a certificate to connect to TIBCO Enterprise Message Service. Bundling certificates with your application is not a good idea as you would need to rebuild your application when the certificates expire. To avoid that, you can copy your certificates into the `<Your-local-docker-repo>/resources/addons/certs` folder. Once the certificates expire, you can simply copy the new certificates into the base docker image without rebuilding your application. Just build your application with the base docker image. To access the certificates from your application, use the environment variable [BW_KEYSTORE_PATH]. For example, #BW_KEYSTORE_PATH#/mycert.jks.
*  **Provision TIBCO BusinessWorks™ Container Edition Plug-in Runtime**: For Plug-ins created using [TIBCO ActiveMatrix BusinessWorks™ Plug-in Development Kit](https://docs.tibco.com/products/tibco-activematrix-businessworks-plug-in-development-kit-6-1-1), the Plug-in runtime must be added to the base docker image. To add the Plug-in runtime into your base docker image:
  * [Install Plug-In](https://docs.tibco.com/pub/bwpdk/6.1.1/doc/html/GUID-0FB70A84-DBF6-4EE6-A6C8-28AC5E4FF1FF.html) if not already installed.
  * Navigate to the `<TIBCO-HOME>/bwce/palettes/<plugin-name>/<plugin-version>` directory and  zip the `lib` and `runtime` folders into `<plugin-name>.zip` file. Copy `<plugin-name>.zip` to `<Your-local-docker-repo>/resources/addons/plugins` folder.
  * Copy any OSGi bundles required by Plug-in e.g. driver bundles into `<Your-local-buildpack-repo>/resources/addons/jars`

Run [createDockerImage.sh](createBuildpack.sh) to create the BWCE base docker image.
     
##Test TIBCO BusinessWorks™ Container Edition Base Docker Image
  * Navigate to the [examples/HTTP](/examples/HTTP) directory and update the base docker image in [Dockerfile](/examples/HTTP/Dockerfile) to your BWCE base docker image.
  * From the [examples/HTTP](/examples/HTTP) directory, build BWCE application: `docker build -t bwce-http-app .`
  * Run the BWCE application: `docker run -P -e MESSAGE='Welcome to BWCE 2.0 !!!' bwce-http-app`
  * Find the port number mapped to 8080 using `docker ps` and send a request to `http://<DOCKER-HOST-IP>:<HOST-PORT>`. It should return 'Welcome to BWCE 2.0 !!!' message. In case of failure, inspect the logs.

##License
These buildpack scripts are released under [3-clause BSD](License.md) license.
     
