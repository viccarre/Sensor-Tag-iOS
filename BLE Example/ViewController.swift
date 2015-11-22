//
//  ViewController.swift
//  BLE Example
//
//  Created by Victor Carreño on 11/11/15.
//  Copyright © 2015 Victor Carreño. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate{

    var titleLabel : UILabel!
    var statusLabel : UILabel!
    var tempLabel : UILabel!

    // BLE
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!

    // IR Temp UUIDs
    let IRTemperatureServiceUUID = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")
    let IRTemperatureDataUUID   = CBUUID(string: "F000AA01-0451-4000-B000-000000000000")
    let IRTemperatureConfigUUID = CBUUID(string: "F000AA02-0451-4000-B000-000000000000")


    //Humidity UUIDs
    let HumidityServiceUUID      = CBUUID(string: "F000AA20-0451-4000-B000-000000000000")
    let HumidityDataUUID        = CBUUID(string: "F000AA21-0451-4000-B000-000000000000")
    let HumidityConfigUUID      = CBUUID(string: "F000AA22-0451-4000-B000-000000000000")



    override func viewDidLoad() {
        super.viewDidLoad()

        //View Controller setup

        // Set up title label
        titleLabel = UILabel()
        titleLabel.text = "RedTag 📶 "
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        titleLabel.sizeToFit()

        titleLabel.center = CGPoint(x: self.view.frame.midX, y: titleLabel.bounds.midY+28)
        self.view.addSubview(titleLabel)

        // Set up status label
        statusLabel = UILabel()
        statusLabel.textAlignment = NSTextAlignment.Center
        statusLabel.text = "Loading..."
        statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        statusLabel.sizeToFit()
        statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: titleLabel.frame.maxY, width: self.view.frame.width, height: statusLabel.bounds.height)
        self.view.addSubview(statusLabel)

        // Set up temperature label
        tempLabel = UILabel()
        tempLabel.text = "00.00"
        tempLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 72)
        tempLabel.sizeToFit()
        tempLabel.center = self.view.center
        self.view.addSubview(tempLabel)

        //Initialize central manager on load
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //Check status of BLE Hardware
    func centralManagerDidUpdateState(central: CBCentralManager) {

        if central.state == CBCentralManagerState.PoweredOn{

            //Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            self.statusLabel.text = "Searching for BLE Devices 👀"
        }
        else{

            // Can have different conditions for all states if needed - print generic message for now
            print("Bluetooth switched off or not initialized")
        }
    }

    //Check out the discovered peripherals to find sensor Tag
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {

        let deviceName = "CC2650 SensorTag"
        let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString

        print(nameOfDeviceFound)

        if(nameOfDeviceFound == deviceName){
            //Update Status Label
            self.statusLabel.text = "Sensor Tag Found 😃"

            //Stop scanning
            self.centralManager.stopScan()
            //Set as the peripheral to use and establish connection
            self.sensorTagPeripheral = peripheral
            self.sensorTagPeripheral.delegate = self
            self.centralManager.connectPeripheral(peripheral, options: nil)

        }else{
            self.statusLabel.text = "Sensor Tag NOT Found ☹️"
        }
    }

    //Discover Peripheral Services
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {

        self.statusLabel.text = "Discovering Tag Services 👓"
        peripheral.discoverServices(nil)
    }

    //Check if the service discovered is a valid IR Temperature Service
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {

        self.statusLabel.text = "Looking for a peripheral services 👓"

        for service in peripheral.services! {
            let thisService = service as CBService
            if service.UUID == IRTemperatureServiceUUID{
                //Discover Characteristics if IR Temperature Service
                peripheral.discoverCharacteristics(nil , forService: thisService)
            }

            if service.UUID == HumidityServiceUUID{
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
            print(thisService.UUID)
        }
    }

    //Enable notification and sensor for each characteristic of valid service
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {

        //update status label
        self.statusLabel.text = "Enabling Sensors ⚙"

        //0x01 data byte to enable sensor
        var enableValue = 1
        let enableBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))

        print(service)
        //check the UUID of each characteristic to find config and data characteristics
        for characteristics in service.characteristics!{
            let thisCharacteristic = characteristics as CBCharacteristic
            print(thisCharacteristic)
            //check for data characteristic
            if thisCharacteristic.UUID == IRTemperatureDataUUID{
                //Enable Sensor Notification
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }

            //Check for config characteristic
            if thisCharacteristic.UUID == IRTemperatureConfigUUID{
                //Enable Sensor
                self.sensorTagPeripheral.writeValue(enableBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }

            if thisCharacteristic.UUID == HumidityDataUUID{
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }

            if thisCharacteristic.UUID == HumidityConfigUUID{
                self.sensorTagPeripheral.writeValue(enableBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }
        }

    }

    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {

        self.statusLabel.text = "Connected 😉"

        //print(characteristic)

        if characteristic.UUID == IRTemperatureDataUUID {
            // Convert NSData to array of signed 16 bit values
            let dataBytes = characteristic.value
            let dataLength = dataBytes!.length
            var dataArray = [Int16](count: dataLength, repeatedValue: 0)
            dataBytes!.getBytes(&dataArray, length: dataLength * sizeof(Int16))

            // Element 1 of the array will be ambient temperature raw value
            let ambientTemperature = Double(dataArray[1])/128

            // Display on the temp label
            self.tempLabel.text = NSString(format: "%.2f", ambientTemperature) as String
        }

        if characteristic.UUID == HumidityDataUUID{
            print("Humidity")
            print(characteristic.value)
        }
    }



    // If disconnected, start searching again
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.statusLabel.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
    }

}

