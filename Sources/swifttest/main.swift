//import SwiftyGPIO
import Foundation

internal let portString = "/dev/i2c-1"
internal let deviceAddress = 0x48


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

let adc = I2CIo(address: deviceAddress, device: portString)

while true {
    if let value = try? adc?.readWord() {
        print("adc = \(value)")
    }
    Thread.sleep(forTimeInterval: 1)
}
