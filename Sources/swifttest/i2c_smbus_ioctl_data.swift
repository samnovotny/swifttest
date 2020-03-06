//
//  i2c_smbus_ioctl_data.swift
//  swifttest
//
//  Created by Sam Novotny on 04/03/2020.
//

import Foundation

struct i2c_smbus_ioctl_data {
    private var buffer = [UInt8] (repeating:0, count: 14)
    var data = [UInt8] (repeating: 0, count: I2C_SMBUS_BLOCK_MAX + 2)
    var word: UInt16 {
        set {
            data[0] = UInt8(newValue >> 8)
            data[1] = UInt8(newValue & 0xff)
        }
        get {
            return UInt16(data[0] << 8) + UInt16(data[1])
        }
    }
    var byte: UInt8 {
        set {
            data[0] = newValue
        }
        get {
            return data[0]
        }
    }

    
    init(read_write: UInt8, command: UInt8, size: UInt32, word: UInt16) {
        initCore(read_write: read_write, command: command, size: size)
        self.word = word
    }
    
    init(read_write: UInt8, command: UInt8, size: UInt32, byte: UInt8) {
        initCore(read_write: read_write, command: command, size: size)
        self.byte = byte
    }
    
    mutating func initCore(read_write: UInt8, command: UInt8, size: UInt32) {
        // set read/write byte
        buffer[0] = read_write
        
        // set command
        buffer[1] = command
        
        // Padding
        buffer[2] = 0x01
        buffer[3] = 0x00

        // set size
        var i: UInt32 = size
        let intData = Data(bytes: &i, count: MemoryLayout<UInt32>.size)
        var offset = 4
        for byte in intData {
            buffer[offset] = byte
            offset += 1
        }
        
        // set pointer to data array
        var pointerToData = UnsafeMutablePointer<UInt8> (&self.data)
        let pointer = Data(bytes: &pointerToData, count: MemoryLayout<UnsafeMutablePointer<UInt8>>.size)
        for byte in pointer {
            buffer[offset] = byte
            offset += 1
        }
        
        
    }
    
    func dump() {
        print("Sent structure: ", terminator: "")
        for b in buffer {
            print(Int(b).hex8() ,terminator: " ")
        }
        print()
        print("Buffer: \(Int(self.data[0]).hex8()) \(Int(self.data[1]).hex8())")
    }
}
