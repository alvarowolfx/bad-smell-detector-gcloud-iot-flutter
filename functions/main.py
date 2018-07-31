import base64
import logging
import os
import json

import pandas as pd
from pandas_gbq import to_gbq
import firebase_admin
from firebase_admin import db, initialize_app, credentials

dataset_id = 'detector_dataset'
table_name = 'raw_data'
project_id = os.getenv('GCLOUD_PROJECT')

initialize_app(options={
    'databaseURL': 'https://iot-cat-poop-detector.firebaseio.com/'
})


def insert_bigquery(data):
    df = pd.DataFrame.from_records([data])
    to_gbq(df, '{}.{}'.format(dataset_id, table_name),
           project_id, if_exists='append')


def update_ref_firebase(device_id, data):
    ref = db.reference('/devices/{}'.format(device_id))
    ref.set(data)


def pubsub_telemetry_handler(data, context):
    """Background Cloud Function to be triggered by Pub/Sub.
    Args:
         event (dict): The dictionary with data specific to this type of event.
         context (google.cloud.functions.Context): The Cloud Functions event
         context.
    """

    print('Received : {}'.format(data))
    print('Received context: {}'.format(context))

    attributes = data['attributes']
    received_data = json.loads(base64.b64decode(data['data']).decode('utf-8'))
    received_data['timestamp'] = context.timestamp
    device_id = attributes['deviceId']

    if received_data['methane'] < 0 or received_data['air_quality'] < 0:
        logging.error('Invalid data received: %s', received_data)
        return

    logging.info('Received valid : %s', received_data)

    update_ref_firebase(device_id, received_data)
    received_data["device_id"] = device_id
    insert_bigquery(received_data)
