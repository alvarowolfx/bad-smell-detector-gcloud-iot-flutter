import base64
import json
from collections import namedtuple
from main import pubsub_telemetry_handler

test_data = {
    "data": {
        "methane": 1.0,
        "air_quality": 357.0,
        "methane_ppm": 4294967295.42949672954294967295429496729542949672954294967295,
        "air_quality_ppm": 0.55245,
        "humidity": 39.00000,
        "temperature": 34.00000
    },
    "attributes": {
        "deviceId": "collector-mark-one"
    }
}

context = {
    "timestamp": "Mon Jul 30 00:52:31 -04 2018"
}

contextObject = namedtuple('Context', context.keys())(*context.values())

test_data['data'] = base64.encodestring(json.dumps(test_data['data']))

pubsub_telemetry_handler(test_data, contextObject)
