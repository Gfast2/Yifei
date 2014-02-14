//
//  Gfaststepper.cpp
//  Gfaststepper
//
//  Created by Su Gao on 13-12-23.
//  Copyright (c) 2013年 Su Gao. All rights reserved.
//

#include "Gfaststepper.h"

Gfaststepper::Gfaststepper(uint8_t puls, uint8_t direction){
    _puls = puls;
    _direction = direction;
    
    pinMode(_puls, OUTPUT);
    pinMode(_direction, OUTPUT);
}

void Gfaststepper::oneStep(uint8_t direction){
    //in order to speed up the excute, ignore the possibility direction use a number not be 1 or 0
    digitalWrite(_direction, direction);
    digitalWrite(_puls, HIGH);
    //Serial.println("Signal pulled high");
    delayMicroseconds(1); //tried works for this driver
    digitalWrite(_puls, LOW);
    //delayMicroseconds(_delayTime); //only one step don't need wait.
}

//long Gfaststepper::setSpeed(long speed);
