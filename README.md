# Bad Smell detector using Arduino, Google Cloud IoT Core, Python Cloud Functions and Flutter App

### Setup Google cloud tools and project

* Install beta components:
    * `gcloud components install beta`
* Authenticate with Google Cloud:
    * `gcloud auth login`
* Create cloud project — choose your unique project name:
    * `gcloud projects create YOUR_PROJECT_NAME`
* Set current project
    * `gcloud config set project YOUR_PROJECT_NAME`

### Create IoT Core resources

* Add permissions for IoT Core
    * `gcloud projects add-iam-policy-binding YOUR_PROJECT_NAME --member=serviceAccount:cloud-iot@system.gserviceaccount.com --role=roles/pubsub.publisher`
* Create PubSub topic for device data:
    * `gcloud beta pubsub topics create telemetry`
* Create PubSub subscription for device data:
    * `gcloud beta pubsub subscriptions create --topic telemetry telemetry-sub`
* Create device registry:
    * `gcloud beta iot registries create weather-station-registry --region us-central1 --event-pubsub-topic=telemetry-topic`

### Upload firmware with PlatformIO Tools

Follow the installation instructions on https://platformio.org/get-started to install PlatformIO Tools.

* `platformio run -e esp32`

### Provision and config

* `./firmware/generate_key_pair.sh`
* `./firmware/register_device.sh`
* Fill firmware/src/ciotc_config.h with the project info and private key got from the command
    * `openssl ec -in ec_private.pem -noout -text`

### Setup BigQuery Dataset and Table

Here we will use it to store all of ours collected sensor data to run some queries and to build reports later using Data Studio. To start let’s create a Dataset and a Table store our data. To do this, open the BigQuery Web UI, and follow the instructions:

* Access [bigquery.cloud.google.com](https://bigquery.cloud.google.com)
* Click the down arrow icon and click on “Create new dataset”.
* Name you Dataset “detector_dataset".

### Setup Firebase, deploy functions and webapp

* Open Firebase Console and associate with Google Cloud Project
* Go to Database and enable it.