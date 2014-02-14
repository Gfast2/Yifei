//
//  Gfaststepper.h
//  Gfaststepper
//
//  Created by Su Gao on 13-12-23.
//  Copyright (c) 2013年 Su Gao. All rights reserved.
//

#ifndef Gfaststepper_h
#define Gfaststepper_h


#include <stdlib.h>


#if ARDUINO >= 100
#include <Arduino.h>
#else
#include <WProgram.h>
#include <wiring.h>

#endif /* defined(Gfaststepper_h) */

#undef round


class Gfaststepper {
public:
    //Constructor
    Gfaststepper(uint8_t puls = 29, uint8_t direction = 30);
    

    //move one step belong the "direction"
    void oneStep(uint8_t direction=1);
    
    //set up the move speed. Unit: steps per second
    //long setSpeed(long speed);
    
    //echo the speed of the motor now
    //long showSpeed();
    
    //void run(); //TODO: make the thing works like the accelStepper.
    
private:
    //puls control pin of the driver
    uint8_t _puls;
    
    //direction control pin of the driver
    uint8_t _direction;
    
    //

};
#endif