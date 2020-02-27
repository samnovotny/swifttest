//
//  I2CIo.swift
//  
//
//  Created by Sam Novotny on 24/02/2020.
//

import Foundation

internal let I2C_SLAVE: UInt = 0x703
internal let I2C_SLAVE_FORCE: UInt = 0x706
internal let I2C_SMBUS: UInt = 0x720

internal let I2C_SMBUS_READ: UInt8 =   1
internal let I2C_SMBUS_WRITE: UInt8 =  0

internal let REG_CONVERT:UInt8 = 0x00
internal let REG_CONFIG:UInt8 = 0x01

private struct i2c_smbus_ioctl_data {
    var read_write: UInt8
    var command: UInt8
    var size: Int32
    var data: UnsafeMutablePointer<UInt8>? //union: UInt8, UInt16, [UInt8]33
}

enum I2CError : Error {
    case ioctlError
    case writeError
    case readError
}

class I2CIo {
    
    let fd: Int32
    let address: Int
        
    init?(address: Int, device: String) {
        self.address = address
        self.fd = open(device, O_RDWR)
        guard self.fd > 0 else { return nil }
    }
    
    deinit {
        print ("\(#function)")
        close(self.fd)
    }
    
    private func selectDevice() throws {
        let io = ioctl(self.fd, I2C_SLAVE, CInt(self.address))
        guard io != -1 else {throw I2CError.ioctlError}
    }
        
    func readADC(channel: Int) throws -> Float {
        print ("\(#function) - \(channel)", terminator: " ")
        let delay = 0.001 // (1.0 / 1600.0) + 0.0001
        let channels = [0x4000, 0x5000, 0x6000]
        let config = 0x0003 | 0x0100 | 0x0080 | 0x0200 | 0x8000 | channels[channel]
        var data = [UInt8] (repeating: 0, count: 2)
 
        try selectDevice()

        data[0] = UInt8(config >> 8)
        data[1] = UInt8(config & 0xff)
        var ioctlData = i2c_smbus_ioctl_data(read_write: I2C_SMBUS_WRITE,
                                             command: REG_CONFIG,
                                             size: Int32(MemoryLayout.size(ofValue:data)),
                                             data: &data)
        var io = ioctl(self.fd, I2C_SMBUS, &ioctlData)
        guard io != -1 else {throw I2CError.writeError}
        
        Thread.sleep(forTimeInterval: delay)

        ioctlData = i2c_smbus_ioctl_data(read_write: I2C_SMBUS_READ,
                                         command: REG_CONVERT,
                                         size: Int32(MemoryLayout.size(ofValue:data)),
                                         data: &data)
        io = ioctl(self.fd, I2C_SMBUS, &ioctlData)
        guard io != -1 else {throw I2CError.readError}

        let intValue = Int(data[0] << 4) + Int(data[1] >> 4)
        print( "intValue(\(intValue)) = \(intValue.binaryWord())")
        
        let result = Float(intValue) / 2047.0 * 4096.0 / 3.3
        
        return (result)
    }
}

