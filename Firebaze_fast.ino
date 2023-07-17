#include <DNSServer.h> //Inclui as bibliotecas
#include <WiFiManager.h>  //Blibioteca para configurar o Wifi
#include <Stepper.h> //Blibioteca para motor de passo
#include "DHT.h"  //Blibioteca do sensor DHT
#include <Firebase_ESP_Client.h>   //Blibioteca para comunicação com a Firebase
#include "addons/TokenHelper.h"
#include "addons/RTDBHelper.h"

//////////////////////////////////////////PARÂMETROS/////////////////////////////////////////////////////////////////////////////////

//Motor de passo
const int stepsPerRevolution = 2048;

#define IN1 13
#define IN2 12
#define IN3 14
#define IN4 27

Stepper myStepper(stepsPerRevolution, IN1, IN3, IN2, IN4);

//Sensor DHT
#define DHTPIN 4
#define DHTTYPE DHT11

DHT dht(DHTPIN, DHTTYPE);

//Sensor de umidade do solo
#define umidadepinA 34
#define umidadepinD 35

//Sensor LDR
#define LIGHT_SENSOR_PIN 33
#define MAX_ADC_READING 2048
#define ADC_REF_VOLTAGE 3.3
#define REF_RESISTANCE 1100
#define LUX_CALC_SCALAR 12518931.7
#define LUX_CALC_EXPONENT -1.404966547

//Firebase
#define FIREBASE_HOST "interfon-17107-default-rtdb.firebaseio.com/" //URL da Conta
#define FIREBASE_KEY "AIzaSyAABnb-nNsBwyFmPsjHeu48BzIwbAPQSwo" //Chave de acesso

FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

unsigned long sendDataPrevMillis = 0;
bool signupOK = false;
int num = 0;

bool fireStatus = "false";      
bool fireStatus2 = "salse";

//Relé
int rele_solenoide = 15;
int rele_lampada = 25;

//////////////////////////////////////////SETUP/////////////////////////////////////////////////////////////////////////////////

void setup() {
  Serial.begin(115200);

  //Wifi
  WiFiManager wm;
  bool res;
  res = wm.autoConnect("AgroLink");
  if(!res) {
        Serial.println("Falha na conexão.");
    } 
    else {   
        Serial.println("Conectado.");
    }

  //Firebase
  config.api_key = FIREBASE_KEY;
  config.database_url = FIREBASE_HOST;

  if (Firebase.signUp(&config, &auth, "", "")){
    Serial.println("Firebase conectada.");
    signupOK = true;
  }
  
  config.token_status_callback = tokenStatusCallback;
   
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  //PinMode
  pinMode(DHTPIN, INPUT);
  pinMode(umidadepinA, INPUT);
  pinMode(umidadepinD, INPUT);
  pinMode(LIGHT_SENSOR_PIN, INPUT);

  pinMode(rele_solenoide, OUTPUT);      
  pinMode(rele_lampada, OUTPUT);
  pinMode(IN1, OUTPUT);      
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);      
  pinMode(IN4, OUTPUT);          

  //DHT
  dht.begin();

  //Motor de passo
  myStepper.setSpeed(15);
}

//////////////////////////////////////////LOOP/////////////////////////////////////////////////////////////////////////////////

void loop() {
  //Pegar dados da Firebase
  //Relé solenoide da água
  if (Firebase.RTDB.getBool(&fbdo, "led/verde")){
    if(fbdo.dataType() == "boolean"){
      if(fbdo.boolData() == 0){
        digitalWrite(rele_solenoide, HIGH);
      }
      if(fbdo.boolData() == 1){
        digitalWrite(rele_solenoide, LOW);
      }
     }
   }

   //Relé lâmpada
   if (Firebase.RTDB.getBool(&fbdo, "led/amarelo")){
    if(fbdo.dataType() == "boolean"){
      if(fbdo.boolData() == 0){
        digitalWrite(rele_lampada, HIGH);
      }
      if(fbdo.boolData() == 1){
        digitalWrite(rele_lampada, LOW);
      }
     }
   }

   //Sentido horário do motor
   if (Firebase.RTDB.getBool(&fbdo, "motor/horario")){
    if(fbdo.dataType() == "boolean"){
      if(fbdo.boolData() == 1){
        myStepper.step(10*stepsPerRevolution);
        delay(1000);
      }
      if(fbdo.boolData() == 0){
        digitalWrite(13, LOW);
        digitalWrite(12, LOW);
        digitalWrite(14, LOW);
        digitalWrite(27, LOW);
      }
     }
    }

   //Sentido anti-horário do motor
   if (Firebase.RTDB.getBool(&fbdo, "motor/anti")){
    if(fbdo.dataType() == "boolean"){
      if(fbdo.boolData() == 1){
        myStepper.step(-10*stepsPerRevolution);
        delay(1000);
      }
      if(fbdo.boolData() == 0){
        digitalWrite(13, LOW);
        digitalWrite(12, LOW);
        digitalWrite(14, LOW);
        digitalWrite(27, LOW);
      }
     }
    }

  //Sensor DHT
  float h = dht.readHumidity(); //Umidade relativa
  float t = dht.readTemperature();  //Temperatura em Celsius
  float f = dht.readTemperature(true);  //Temperatura em Fahrenheit

  if (isnan(h) || isnan(t) || isnan(f)) { //Verificar leitura DHT
    Serial.println(("Falha leitura sensor DHT.");
  }

  //Serial.print(F("Humidity: "));
  //Serial.print(h);
  //Serial.print(F("%  Temperature: "));
  //Serial.print(t);
  //Serial.print(F("°C "));
  //Serial.print(f);
  //Serial.println(F("°F "));

  //Sensor umidade do solo
  int umidadesolo = (4096-analogRead(umidadepinA))*100/2048;

  //Sensor de luminosidade
  float analogValue = analogRead(LIGHT_SENSOR_PIN);
  float resistorVoltage = analogValue / MAX_ADC_READING * ADC_REF_VOLTAGE; // Converter para Lux
  float ldrVoltage = ADC_REF_VOLTAGE - resistorVoltage;
  float ldrResistance = ldrVoltage/resistorVoltage * REF_RESISTANCE;
  float lux = LUX_CALC_SCALAR * pow(ldrResistance, LUX_CALC_EXPONENT);

  //Enviando dados 
  if (Firebase.ready() && signupOK && (millis() - sendDataPrevMillis > 1000 || sendDataPrevMillis == 0)){ // Tempo para atualização
    sendDataPrevMillis = millis();

  //Temperatura ambiente
  if (Firebase.RTDB.setInt(&fbdo, "Temperatura", t)){
    //Serial.println(t);
    //Serial.println("PATH: " + fbdo.dataPath());
    //Serial.println("TYPE: " + fbdo.dataType());
  }

  //Umidade do ambiente
  if (Firebase.RTDB.setInt(&fbdo, "Umidade", h)){
    //Serial.println(h);
    //Serial.println("PATH: " + fbdo.dataPath());
    //Serial.println("TYPE: " + fbdo.dataType());
  }
  
  //Umidade do solo
  if (Firebase.RTDB.setInt(&fbdo, "Umidade do solo", umidadesolo)){
    //Serial.println(umidadesolo);
    //Serial.println("PATH: " + fbdo.dataPath());
    //Serial.println("TYPE: " + fbdo.dataType());
  }

  //Luminosidade
  if (Firebase.RTDB.setInt(&fbdo, "Luminosidade", lux)){
    //Serial.println(lux);
    //Serial.println("PATH: " + fbdo.dataPath());
    //Serial.println("TYPE: " + fbdo.dataType());
  }
 }

}
