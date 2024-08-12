void setup() {
  // put your setup code here, to run once:
  Serial.begin(9600);
  pinMode(21, OUTPUT);
}


void loop() {
  // put your main code here, to run repeatedly:
  Serial.println("Setting pin 21 high");
  digitalWrite(21, HIGH);
  delay(1000);
  Serial.println("Setting pin 21 low");
  digitalWrite(21, LOW);
  delay(1000);
}