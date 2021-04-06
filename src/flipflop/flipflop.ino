/*
LED triggering for interleaved 405 / 470 nm illumination

Uses the exposure start trigger (or flash trigger, for rolling shutter cameras)
to alternate between turning on one or the other LED.
*/
const int CameraIn = 8;
const int LED1 = 4;
const int LED2 = 7;
int odd = 1;

void setup() {
  pinMode(CameraIn, INPUT);
  pinMode(LED1, OUTPUT);
  pinMode(LED2, OUTPUT);
}

void loop() {
  while(digitalRead(CameraIn) == LOW) { }
  
  if(odd) {
    digitalWrite(LED1, HIGH);
    odd = 0;
    
    while(digitalRead(CameraIn) == HIGH) { }
    
    digitalWrite(LED1, LOW);
  } else {
    digitalWrite(LED2, HIGH);
    odd = 1;
    
    while(digitalRead(CameraIn) == HIGH) { }
    
    digitalWrite(LED2, LOW);
  }
}
