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

private struct i2c_smbus_ioctl_data {
    var read_write: UInt8
    var command: UInt8
    var size: Int32
    var data: UnsafeMutablePointer<UInt8>? //union: UInt8, UInt16, [UInt8]33
}

enum I2CError : Error {
    case ioctlError
    case writeError
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
        close(self.fd)
    }
    
    private func selectDevice() throws {
        let io = ioctl(self.fd, I2C_SLAVE, CInt(self.address))
        guard io != -1 else {throw I2CError.ioctlError}
    }
    
    func writeByte(byte: UInt8) throws {
        try selectDevice()
        var data = byte
        var ioctlData = i2c_smbus_ioctl_data(read_write: I2C_SMBUS_WRITE,
                                             command: 0,
                                             size: Int32(MemoryLayout.size(ofValue:data)),
                                             data: &data)
        let io = ioctl(self.fd, I2C_SMBUS, &ioctlData)
        guard io != -1 else {throw I2CError.writeError}
    }
    
    func readWord() throws -> Int {
        try selectDevice()
        var word = [UInt8] (repeating: 0, count: 2)
        var ioctlData = i2c_smbus_ioctl_data(read_write: I2C_SMBUS_READ,
                                             command: 0,
                                             size: Int32(MemoryLayout.size(ofValue:word)),
                                             data: &word) 
        let io = ioctl(self.fd, I2C_SMBUS, &ioctlData)
        guard io != -1 else {throw I2CError.writeError}
        let value = Int(word[1] << 8) + Int(word[0])
        return (value)
    }
}

