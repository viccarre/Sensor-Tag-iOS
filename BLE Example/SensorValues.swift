//
//  SensorValues.swift
//  BLE Example
//
//  Created by Victor Carreño on 11/22/15.
//  Copyright © 2015 Victor Carreño. All rights reserved.
//

import UIKit
import CoreBluetooth

class SensorValues: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var titleLabel : UILabel!
    var statusLabel : UILabel!

    var ambientTemperatureLabel: UILabel!
    var humidityLabel: UILabel!

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

        navigationController?.navigationBar.barTintColor = UIColor(red: 217.0/255.0, green: 30.0/255.0, blue: 24.0/255.0, alpha: 1.0)



        if let navigationBar = self.navigationController?.navigationBar {


            // Set up title label
            titleLabel = UILabel()
            titleLabel.text = "RedTag 📶 "
            titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
            titleLabel.sizeToFit()
            titleLabel.center = CGPoint(x: self.view.frame.midX, y: titleLabel.bounds.midY)
            titleLabel.textColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
            navigationBar.addSubview(titleLabel)

            // Set up status label
            statusLabel = UILabel()
            statusLabel.textAlignment = NSTextAlignment.Center
            statusLabel.text = "Loading..."
            statusLabel.font = UIFont(name: "HelveticaNeue-Light", size: 12)
            statusLabel.sizeToFit()
            statusLabel.textColor = UIColor(red: 236.0/255.0, green: 240.0/255.0, blue: 241.0/255.0, alpha: 1.0)
            statusLabel.frame = CGRect(x: self.view.frame.origin.x, y: titleLabel.frame.maxY, width: self.view.frame.width, height: statusLabel.bounds.height)
            navigationBar.addSubview(statusLabel)

            //Initialize central manager on load
            centralManager = CBCentralManager(delegate: self, queue: nil)

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")!

        if(indexPath.row == 0){

            ambientTemperatureLabel = UILabel()
            ambientTemperatureLabel.text = "00.00"
            ambientTemperatureLabel.sizeToFit()

            ambientTemperatureLabel.center = CGPoint(x: self.view.frame.width-40, y: cell.frame.height/2)
            cell.addSubview(ambientTemperatureLabel)
            cell.textLabel?.text = "IR Temperature Sensor"

        }

        if(indexPath.row == 1){

            humidityLabel = UILabel()
            humidityLabel.text = "00.00"
            humidityLabel.sizeToFit()

            humidityLabel.center = CGPoint(x: self.view.frame.width-40, y: cell.frame.height/2)
            cell.addSubview(humidityLabel)
            cell.textLabel?.text = "Humidity Sensor"
            
        }


        return cell
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

            //Check for data characteristic
            if thisCharacteristic.UUID == HumidityDataUUID{
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }

            if thisCharacteristic.UUID == HumidityConfigUUID{
                //Enable Humidity Sensor
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
            /*
            m_tmpAmb = (double)((qint16)rawT)/128.0;
            */

            let ambientTemperature = Double(dataArray[1])/128

            // Display on the temp label
            ambientTemperatureLabel.text = NSString(format: "%.2f", ambientTemperature) as String
        }

        if characteristic.UUID == HumidityDataUUID{
            let dataBytes = characteristic.value
            let dataLenght = dataBytes!.length
            var dataArray = [Int16](count: dataLenght, repeatedValue: 0)
            dataBytes!.getBytes(&dataArray, length: dataLenght * sizeof(Int16))

            /*
            //-- calculate relative humidity [%RH] --
            v = -6.0 + 125.0/65536 * (double)rawH; // RH= -6 + 125 * SRH/2^16
            */

            let ambientHumidity = -6.0 + 125.0/65536 * Double(dataArray[1])
            // Display on the temp label
            humidityLabel.text = NSString(format: "%.2f", ambientHumidity) as String

        }
    }
    
    
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.statusLabel.text = "Disconnected"
        central.scanForPeripheralsWithServices(nil, options: nil)
    }

}