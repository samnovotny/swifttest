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

internal let SAMPLES_PER_SECOND_MAP: Dictionary<Int, UInt16> = [128: 0x0000, 250: 0x0020, 490: 0x0040, 920: 0x0060, 1600: 0x0080, 2400: 0x00A0, 3300: 0x00C0]
internal let CHANNEL_MAP: Dictionary<Int, UInt16> = [0: 0x4000, 1: 0x5000, 2: 0x6000]
internal let PROGRAMMABLE_GAIN_MAP: Dictionary<Int, UInt16> = [6144: 0x0000, 4096: 0x0200, 2048: 0x0400, 1024: 0x0600, 512: 0x0800, 256: 0x0A00]

internal let samplesPerSecond = 1600
internal let programmableGain = 4096

internal let I2C_SMBUS_READ: UInt8 =   1
internal let I2C_SMBUS_WRITE: UInt8 =  0

internal let I2C_SMBUS_QUICK: UInt32 = 0
internal let I2C_SMBUS_BYTE: UInt32 = 1
internal let I2C_SMBUS_BYTE_DATA: UInt32 = 2
internal let I2C_SMBUS_WORD_DATA: UInt32 = 3

internal let REG_CONVERT:UInt8 = 0x00
internal let REG_CONFIG:UInt8 = 0x01

internal let I2C_SMBUS_BLOCK_MAX = 32


enum I2CError : Error {
    case ioctlError
    case readError
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
        print ("\(#function)")
        close(self.fd)
    }
    
    private func selectDevice() throws {
        let io = ioctl(self.fd, I2C_SLAVE, CInt(self.address))
        guard io != -1 else {throw I2CError.ioctlError}
    }
        
    private func getConfig(channel: Int) -> UInt16 {
        var config: UInt16 = 0x8000 | 0x0003 | 0x0100
        config |= SAMPLES_PER_SECOND_MAP[samplesPerSecond]!
        config |= PROGRAMMABLE_GAIN_MAP[programmableGain]!
        config |= CHANNEL_MAP[channel]!

        print("config = \(Int(config).hex16()),\(Int(config).binaryWord())")
        return config
    }

    private func setRegister(register: UInt8) throws {
        try selectDevice()
        try writeByte(byte: register)
    }
    
    func writeByte(byte: UInt8) throws {
         var ioctlData = i2c_smbus_ioctl_data(read_write: I2C_SMBUS_WRITE,
                                             command: 0,
                                             size: I2C_SMBUS_BYTE_DATA,
                                             byte: byte)
                
        let io = ioctl(self.fd, I2C_SMBUS, &ioctlData.data)
        guard io != -1 else {throw I2CError.writeError}
    }
    
    func writeWord(register: UInt8, word: UInt16) throws {
        try setRegister(register: register)
        var ioctlData = i2c_smbus_ioctl_data(read_write: I2C_SMBUS_WRITE,
                                             command: 0,
                                             size: I2C_SMBUS_WORD_DATA,
                                             word: word)
 
        let io = ioctl(self.fd, I2C_SMBUS, &ioctlData.data)
        guard io != -1 else {throw I2CError.writeError}
    }
    
    func readWord(register: UInt8) throws -> UInt16 {
        try setRegister(register: register)
        var ioctlData = i2c_smbus_ioctl_data(read_write: I2C_SMBUS_READ,
                                             command: 0,
                                             size: I2C_SMBUS_WORD_DATA,
                                             word: 0)
//        var ioctlData = i2c_smbus_ioctl_data(read_write: 255,
//                                             command: 255,
//                                             size: 0xffffffff,
//                                             word: 0)
        ioctlData.dump()
        let io = ioctl(self.fd, I2C_SMBUS, &ioctlData.data)
        guard io != -1 else {throw I2CError.readError}
        ioctlData.dump()

        return(ioctlData.word)
    }
    
    func getConfigRegister() throws {
        do {
            let config = try readWord(register: REG_CONFIG)
            print("Config = \(Int(config).hex16())")
        }
    }

    func readADC(channel: Int) throws -> Float {
        print ("\(#function) - \(channel)")
        let delay = (1.0 / Double(samplesPerSecond)) + 0.0001
        let config = getConfig(channel: channel)
        
        try writeWord(register: REG_CONFIG, word: config)
        Thread.sleep(forTimeInterval: delay)
        let value = try readWord(register: REG_CONVERT)
        let intValue = Int(value >> 4)
        print( "intValue(\(intValue)) = \(intValue.binaryWord())")
        
        let result = Float(intValue) / 2047.0 * Float(programmableGain) / 3300.0
        
        return (result)
    }
}

