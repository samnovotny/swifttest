import SwiftyGPIO
import Foundation

print("Hello, Swift world!")

let gpios = SwiftyGPIO.GPIOs(for:.RaspberryPiPlusZero)

//
// Setup Relay
//
if let Relay = gpios[.P16] {
    print("Relay set!")
    Relay.direction = .OUT
    DispatchQueue.global(qos: .background).async {
        while true {
            Relay.value = (Relay.value + 1) % 2
            Thread.sleep(forTimeInterval: 0.5)
        }
    }
}

let adc = ADS1015()
print("adc = \(adc.readADC(adcChannel: 1))")

while true {
    print("adc = \(adc.readADC(adcChannel: 1))")
    Thread.sleep(forTimeInterval: 1)
}
