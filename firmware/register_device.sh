GCLOUD_PROJECT="iot-cat-poop-detector"
LOCATION="us-central1"
DEVICE_ID="collector-mark-one"
REGISTRY="poop-detector-registry"

#gcloud config set project $GCLOUD_PROJECT
gcloud iot devices create $DEVICE_ID  \
--region=$LOCATION \
--registry=$REGISTRY \
--project=$GCLOUD_PROJECTx \
 --public-key path=ec_public.pem,type=es256-pem