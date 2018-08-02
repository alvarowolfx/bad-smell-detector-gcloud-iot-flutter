/*****************************************************************************
 * Copyright 2018 Google
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *****************************************************************************/
#include <CloudIoTCore.h>
#include <WiFiClientSecure.h>
#include <rBase64.h>
#include <time.h>
#include <Ticker.h>
#include <aJSON.h>
#include <DHT.h>
#include "ciotc_config.h"
#include <TroykaMQ.h>

#define MQTT_MAX_PACKET_SIZE 512
#include <PubSubClient.h>

const char *host = "mqtt.googleapis.com";
const int httpsPort = 8883;

WiFiClientSecure client;
PubSubClient mqttClient(client);
String pwd;
String jwt;
CloudIoTCoreDevice device(project_id, location, registry_id, device_id,
                          private_key_str);

// TM1637 Module connection pins (Digital Pins)
/*#define CLK 12
#define DIO 14
TM1637Display display(CLK, DIO);*/

Ticker tickerRenewToken;
Ticker tickerSendTelemetry;
Ticker tickerUpdateSensors;
Ticker tickerWifiLed;

#define mq4SensorPin 34   // MQ 4 - PIN 34
#define mq135SensorPin 33 // MQ 135 - PIN 33
#define dhtPin 4          // DHT 11 - PIN 4
#define LED_PIN 5         // BUILTIN LED
#define WIFI_LED_PIN 18   // Blue led

DHT dht;
MQ135 mq135(mq135SensorPin);
MQ4 mq4(mq4SensorPin);

float humidity;
float temperature;
int methane;
int airQuality;
float methanePPM;
float airQualityPPM;

bool firstConnection = true;
bool firstCallback = true;
int failedCount = 0;

String getJwt()
{
    jwt = device.createJWT(time(nullptr));
    return jwt;
}

// Gets the google cloud iot http endpoint path.
String get_path(const char *project_id, const char *location,
                const char *registry_id, const char *device_id)
{
    return String("projects/") + project_id + "/locations/" + location +
           "/registries/" + registry_id + "/devices/" + device_id;
}

String get_config_topic(const char *device_id)
{
    return String("/devices/") + device_id + "/config";
}

String get_events_topic(const char *device_id)
{
    return String("/devices/") + device_id + "/events";
}

String get_state_topic(const char *device_id)
{
    return String("/devices/") + device_id + "/state";
}

String get_client_id()
{
    return get_path(project_id, location, registry_id, device_id);
}

/*void showValue(int value)
{
    display.showNumberDec(value, false, 4, 0);
}*/

void sendTelemetry(const char *data)
{
    String eventsTopic = get_events_topic(device_id);
    bool ok = mqttClient.publish(eventsTopic.c_str(), data);
    if (!ok)
    {
        Serial.println("Failed to send telemetry");
    }
}

void renewJwt()
{
    getJwt();
}

void sendPeriodicTelemetry()
{
    Serial.println("Send periodic telemetry");
    aJsonObject *root = aJson.createObject();
    if (root != NULL)
    {
        //aJson.addStringToObject(root, "type", "rect");
        aJson.addNumberToObject(root, "methane", methane);
        aJson.addNumberToObject(root, "air_quality", airQuality);
        aJson.addNumberToObject(root, "methane_ppm", methanePPM);
        aJson.addNumberToObject(root, "air_quality_ppm", airQualityPPM);
        aJson.addNumberToObject(root, "humidity", humidity);
        aJson.addNumberToObject(root, "temperature", temperature);
        //aJson.addBooleanToObject(root, "interlace", false);

        char *jsonString = aJson.print(root);
        Serial.println(jsonString);
        sendTelemetry(jsonString);
        return;
    }
}

void updateSensors()
{
    humidity = dht.getHumidity();
    temperature = dht.getTemperature();

    methane = mq4.readMethane();
    methanePPM = mq4.readRatio();

    airQuality = mq135.readCO2();
    airQualityPPM = mq135.readRatio();
}

void callback(char *topic, uint8_t *payload, unsigned int length)
{
    Serial.print("Message received: ");
    Serial.println(topic);

    Serial.print("payload: ");
    char val[length];
    for (int i = 0; i < length; i++)
    {
        Serial.print((char)payload[i]);
        val[i] = (char)payload[i];
    }
    Serial.println();

    if (firstCallback)
    {
        firstCallback = false;
        return;
    }

    // int ret = rbase64.decode(val);
    int ret = 0;
    if (ret == 0)
    {
        // we got '1' -> on
        if (val[0] == '1')
        {
            Serial.println("High");
            digitalWrite(LED_PIN, HIGH);
            updateSensors();
            sendPeriodicTelemetry();
        }
        else
        {
            // we got '0' -> on
            Serial.println("Low");
            digitalWrite(LED_PIN, LOW);
        }
    }
    else
    {
        Serial.println("Error decoding");
    }
}

void blinkWifi()
{
    digitalWrite(WIFI_LED_PIN, !digitalRead(WIFI_LED_PIN));
}

void mqtt_connect()
{
    /* Loop until reconnected */
    while (!client.connected())
    {
        Serial.println("MQTT connecting ...");
        String pass = getJwt();
        Serial.println(pass.c_str());
        const char *user = "unused";
        String clientId = get_client_id();
        Serial.println(clientId.c_str());
        if (mqttClient.connect(clientId.c_str(), user, pass.c_str()))
        {
            Serial.println("connected");
            String configTopic = get_config_topic(device_id);
            Serial.println(configTopic.c_str());
            mqttClient.setCallback(callback);
            mqttClient.subscribe(configTopic.c_str(), 0);

            tickerWifiLed.detach();
            tickerWifiLed.attach_ms(2000, blinkWifi);
        }
        else
        {
            tickerWifiLed.detach();
            tickerWifiLed.attach_ms(300, blinkWifi);
            Serial.print("failed, status code =");
            Serial.print(mqttClient.state());
            Serial.println(" try again in 5 seconds");
            /* Wait 5 seconds before retrying */
            delay(5000);
            failedCount++;
            if (failedCount > 5)
            {
                ESP.restart();
            }
        }
    }
}

void reconectWiFi()
{
    if (WiFi.status() == WL_CONNECTED)
    {
        return;
    }

    tickerWifiLed.detach();
    tickerWifiLed.attach_ms(500, blinkWifi);

    WiFi.begin(ssid, password);
    int count = 0;
    while (WiFi.status() != WL_CONNECTED)
    {
        delay(100);
        Serial.print(".");
        count++;
        if (count > 100)
        {
            break;
        }
    }

    Serial.println();
    Serial.print("Connected to the network ");
    Serial.print(ssid);
    Serial.println("IP address: ");
    Serial.println(WiFi.localIP());

    tickerWifiLed.detach();
    tickerWifiLed.attach_ms(2000, blinkWifi);
}

// Arduino functions
void setup()
{
    Serial.begin(115200);
    //display.setBrightness(0x0f);
    pinMode(LED_PIN, OUTPUT);
    pinMode(WIFI_LED_PIN, OUTPUT);

    dht.setup(dhtPin);
    mq135.calibrate();
    mq4.calibrate();

    WiFi.mode(WIFI_STA);
    reconectWiFi();

    configTime(0, 0, "pool.ntp.org", "time.nist.gov");
    Serial.println("Waiting on time sync...");
    while (time(nullptr) < 1510644967)
    {
        delay(10);
    }

    // FIXME: Avoid MITM, validate the server.
    client.setCACert(root_cert);
    mqttClient.setServer(host, httpsPort);
    mqttClient.setCallback(callback);

    tickerRenewToken.attach(60 * 30, renewJwt);                // Every 30 minutes
    tickerSendTelemetry.attach(60 * 5, sendPeriodicTelemetry); // Every 5 minutes
    tickerUpdateSensors.attach(30, updateSensors);             // Every 30 seconds
}

void loop()
{
    if (!mqttClient.connected())
    {
        mqtt_connect();
        if (firstConnection)
        {
            updateSensors();
            sendPeriodicTelemetry();
            firstConnection = false;
        }
    }

    reconectWiFi();

    mqttClient.loop();

    // I had some issues on the PubSubClient without some delay
    delay(10);

    /*Serial.print("Methane: ");
    Serial.println(methane);
    Serial.print("AirQuality: ");
    Serial.println(airQuality);
    Serial.print("Methane PPM: ");
    Serial.println(methanePPM);
    Serial.print("AirQuality PPM: ");
    Serial.println(airQualityPPM);
    Serial.print("Temperature: ");
    Serial.println(temperature);
    Serial.print("Humidity: ");
    Serial.println(humidity);
    //showValue(methane);
    delay(1000);
    //showValue(airQuality);
    //delay(5000);*/
}
