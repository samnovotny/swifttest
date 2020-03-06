import SwiftyGPIO
import Foundation

internal let portString = "/dev/i2c-1"
internal let deviceAddress = 0x48


print ("\(#function)")

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPiPlusZero)

//
// Setup Relay
//
if let Relay = gpios[.P16] {
    Relay.direction = .OUT
    DispatchQueue.global(qos: .background).async {
        while true {
            Relay.value = (Relay.value + 1) % 2
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
}

let adc = I2CIo(address: deviceAddress, device: portString)

do {
    try adc?.getConfigRegister()
//    let res = try adc?.readADC(channel: 0)
//    print("adc(\(0)) = \(String(format: "%0.2f", res!))")
}
catch {
    print("ConfigRegister error \(error)")
}

//while true {
//    do {
//        for n in 0...2 {
//            if let value = try adc?.readADC(channel: n) {
//                print("adc(\(n)) = \(String(format: "%0.2f", value))")
//            }
//            
//        }
//    }
//    catch {
//        print("ADC error \(error)")
//    }
//    Thread.sleep(forTimeInterval: 5)
//}
