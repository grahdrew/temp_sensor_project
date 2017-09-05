//  TEMP SENSOR DATA READ
//  Project:  Temp Sensor group for Arduino Project
//  Course:  ENGR 114 Summer 2017
//  Group Members:  Marshall Reed, Jonathan Christian, Andy Graham, Mussie Bariagabir
//  Description:  This arduino code takes voltage readings from a thermistor, converts them to degrees Kelvin using Steinhart equation,
//                then prints them to the serial port for reading by MATLAB
//


int thermistorPin = A0;               // Initializes pin that the thermistor will be connected to
double thermistorReading;             // Initialize double thermistorReading for storing thermistor values
double seriesResistor = 9720;         // Value of the resistor used - measured with multimeter
double thermistorNominal = 10790;     // Resistance measured at 23.9 degrees C
double temperatureNominal = 23.9;     // Temperature for nominal resistance value during calibration
double bCoefficient = 3950;           // The beta coefficient of the termistor (usually 3000-4000)
double steinhart;                     // Initialize double steinhart for calculating Steinhart-Hart equation
double tempK;                         // Initialize double tempK for storing thermistor values converted into Kelvin
double resistance;                    // Initialize double resistance for storing converted thermistor value
String strTempK;                      // Initialize String strTempK for storing tempK value as a string

void setup() 
{
  // put your setup code here, to run once:
  Serial.begin(9600);                 // setup serial port to 9600 baud rate
}

void loop() 
{
  // use analogRead function to read thermistor input and store in thermistorReading variable
  // analogRead function samples at a max rate of 100 microseconds each
  thermistorReading = analogRead(thermistorPin);
  // convert raw thermistorReading into resistance
  // this specific coding conversion comes from the thermistor supplier 
  resistance = 1023 / thermistorReading - 1;
  resistance = seriesResistor / resistance;

  // to convert the resistance to a voltage, we need to use the Steinhart-Hart equation with 
  // simplified B term (due to lack of known variables)
  // This equation is not exact but provides good data for the temperatures that the thermistor
  // is being used for.
  // 1/T = 1/To + 1/B*ln(R/Ro)
  steinhart = resistance / thermistorNominal;     // (R/Ro)
  steinhart = log(steinhart);                     // ln(R/Ro)
  steinhart /= bCoefficient;                      // 1/B * ln(R/Ro)
  steinhart += 1.0/(temperatureNominal + 273.15); // 1/To + 1/B * ln(R/Ro)
  steinhart = 1.0 / steinhart;                    // invert
  tempK = steinhart;                              // steinhart output is Kelvin

  strTempK = String(tempK, 2);                    // convert tempK into a String with two decimal places
  
  Serial.println(strTempK);                       // print the Kelvin value                        
  // wait 100 microsceonds or repeat 10x per second (change to modify sampling rate)
  delay(100);
}
