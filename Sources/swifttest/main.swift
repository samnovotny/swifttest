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

////
//// Setup Button 1
////
//if let Button1 = gpios[.P5] {
//    print("Button 1 set!")
//    Button1.onRaising {
//        gpio in
//        Buzzer?.value = 1
//        repeat {
//            Thread.sleep(forTimeInterval: 0.25)
//        } while gpio.value == 1
//        Buzzer?.value = 0
//    }
//}
//
////
//// Setup Button 2
////
//if let Button2 = gpios[.P6] {
//    print("Button 2 set!")
//    Button2.onRaising {
//        gpio in
//        LED2?.value = 1
//        repeat {
//            Thread.sleep(forTimeInterval: 0.25)
//        } while gpio.value == 1
//        LED2?.value = 0
//    }
//}

//
// Boring loop forever
//
while true {
    Thread.sleep(forTimeInterval: 1)
}
