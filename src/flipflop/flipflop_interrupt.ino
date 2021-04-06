/* Excitation LED Control v0.1
 * 2019/11/06
MIT License

Copyright (c) 2019 André Marques-Smith

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Modified by Petr Znamenskiy
*/


// Teensy 2.0 has the LED on pin 11
// Teensy++ 2.0 has the LED on pin 6
// Teensy 3.x / Teensy LC have the LED on pin 13
const int ledPin = 13;
const int bluePin = 4;
const int uvPin = 7;
const int tglobalPin = 2;
int blueState = HIGH;

// the setup() method runs once, when the sketch starts

void setup() {
  // initialize the digital pin as an output.
  pinMode(ledPin, OUTPUT);
  pinMode(bluePin, OUTPUT);
  pinMode(uvPin, OUTPUT);
  pinMode(tglobalPin, INPUT);
  attachInterrupt(digitalPinToInterrupt(tglobalPin), tglobalChanged, CHANGE);
}

// called whenever tglobal changes (LOW > HIGH or HIGH > LOW)
void tglobalChanged() {
  int tglobal = digitalRead(tglobalPin);

  // if we have a rising edge of tglobal
  if (tglobal == HIGH) { // start of exposure
    
    // trigger excitation state
    if (blueState == HIGH) {
      digitalWrite(bluePin, HIGH);
      blueState = LOW;
    }
    else {
      digitalWrite(uvPin, HIGH);
      blueState = HIGH;
    }
  }
  else { // end of exposure
    // turn-off excitation
    if (blueState == LOW) {
      digitalWrite(bluePin, LOW);
    }
    else {
      digitalWrite(uvPin, LOW);
    }
  }
  
  digitalWrite(ledPin, tglobal);
}

// the loop() method runs over and over again,
// as long as the board has power

void loop() {
  
}
