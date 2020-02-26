//
//  ADS1015.swift
//  swifttest
//
//  Created by Sam Novotny on 23/02/2020.
//
import SwiftyGPIO
import Foundation

let I2cChannel = 1
let I2cAddress = 0x48

class ADS1015 {
    
    var i2cAddress: Int
    var ic2ADC: I2CInterface?
    
    init(address: Int = 0x48) {
        self.i2cAddress = address
        let adcs = SwiftyGPIO.hardwareI2Cs(for:.RaspberryPiPlusZero)
        self.ic2ADC = adcs?[I2cChannel]
    }
    
    func readADC(adcChannel: Int) -> Float {
        if let adc = self.ic2ADC {
            adc.writeByte(self.i2cAddress, value: 0)
            Thread.sleep(forTimeInterval: 0.5)
            let value = adc.readWord(self.i2cAddress, command: 0) >> 4
            return(Float(value))
        }
        else {
            print("No ADC!")
            return(-1.0)
        }
    }
}
