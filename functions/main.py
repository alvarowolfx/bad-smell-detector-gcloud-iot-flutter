import base64
import logging
import os
import json

from flask import Response, Request
from google.cloud import bigquery
import firebase_admin
from firebase_admin import db, initialize_app, credentials

dataset_id = 'detector_dataset'
table_name = 'raw_data'
project_id = os.getenv('GCLOUD_PROJECT')
client = bigquery.Client()

initialize_app(options={
    'databaseURL': 'https://iot-cat-poop-detector.firebaseio.com/'
})

def insert_bigquery(data):    
    dataset_ref = client.dataset(dataset_id, project=project_id)    
    table_ref = dataset_ref.table(table_name)
    table = client.get_table(table_ref)

    rows_to_insert = [
        (
            data['air_quality'], 
            data['air_quality_ppm'], 
            data['device_id'], 
            data['humidity'], 
            data['methane'],
            data['methane_ppm'],
            data['temperature'],
            data['timestamp'],
        )
    ]    
    client.insert_rows(table,rows_to_insert)


def update_ref_firebase(device_id, data):
    ref = db.reference('/devices/{}'.format(device_id))
    ref.set(data)


def query_history_data(request):
    '''
    :param request:
    :type request: Request
    '''
    logging.info('[query_history_data] started.')

    deviceId = request.args.get('deviceId')

    logging.info('[query_history_data][client.query] started.')
    query = """
        SELECT
            TIMESTAMP_TRUNC(timestamp(d.timestamp), HOUR, 'America/Cuiaba') date_time,
            avg(d.temperature) as avg_temperature, 
            avg(d.methane) as avg_methane, 
            avg(d.humidity) as avg_humidity, 
            avg(d.air_quality) as avg_air_quality
        FROM
            `{}.{}.{}` d
        where 
            timestamp(d.timestamp) between timestamp_sub(current_timestamp, INTERVAL 7 DAY) and current_timestamp()
            and d.temperature between 0 and 100
            and d.methane between 0 and 5000
            and d.air_quality between 0 and 5000
            and d.device_id = '{}'
        GROUP BY
            date_time
        ORDER BY
            date_time
     """.format(project_id, dataset_id, table_name, deviceId)

    query_job = client.query(query)
    rows = query_job.result()

    logging.info('[query_history_data][client.query] ended.')

    logging.info('[query_history_data][to_json] started.')

    df = rows.to_dataframe()
    output = df.to_json(orient='records')
    resp = Response(response=output, status=200, mimetype="application/json")
    logging.info('[query_history_data][to_json] ended.')
    return resp


def pubsub_telemetry_handler(data, context):
    """Background Cloud Function to be triggered by Pub/Sub.
    Args:
         event (dict): The dictionary with data specific to this type of event.
         context (google.cloud.functions.Context): The Cloud Functions event
         context.
    """
    logging.info('[pubsub_telemetry_handler] started.')

    print('Received : {}'.format(data))
    print('Received context: {}'.format(context))

    logging.info('[pubsub_telemetry_handler][parse_data] started.')
    attributes = data['attributes']
    received_data = json.loads(base64.b64decode(data['data']).decode('utf-8'))
    received_data['timestamp'] = context.timestamp
    device_id = attributes['deviceId']
    logging.info('[pubsub_telemetry_handler][parse_data] ended.')

    if received_data['methane'] < 0 or received_data['air_quality'] < 0:
        logging.error('Invalid data received: %s', received_data)
        return

    logging.info('Received valid : %s', received_data)

    logging.info('[pubsub_telemetry_handler][update_ref_firebase] started.')
    update_ref_firebase(device_id, received_data)
    logging.info('[pubsub_telemetry_handler][update_ref_firebase] ended.')

    logging.info('[pubsub_telemetry_handler][insert_bigquery] started.')
    received_data["device_id"] = device_id
    insert_bigquery(received_data)
    logging.info('[pubsub_telemetry_handler][insert_bigquery] ended.')

    logging.info('[pubsub_telemetry_handler] finished.')
