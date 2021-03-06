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
    var temperatureLabel: UILabel!

    //Accelerometer Labels
    var xAxisLabel: UILabel!
    var yAxisLabel: UILabel!
    var zAxisLabel: UILabel!

    //Gyroscope Labels
    var xAxisGyroLabel: UILabel!
    var yAxisGyroLabel: UILabel!
    var zAxisGyroLabel: UILabel!

    //Magnetometer Labels
    var xAxisMagnetometerLabel: UILabel!
    var yAxisMagnetometerLabel: UILabel!
    var zAxisMagnetometerLabel: UILabel!

    //Simple Keys Labels
    var buttonOnOff: UILabel!
    var buttonOne: UILabel!

    //Digital Buttons to I/O service
    var grenLED: UIButton!
    var redLED: UIButton!
    var buzzer: UIButton!

    //IOCharacteristic
    var IOCharacteristic: CBCharacteristic!

    // BLE
    var centralManager : CBCentralManager!
    var sensorTagPeripheral : CBPeripheral!

    // IR Temp UUIDs
    let IRTemperatureServiceUUID    = CBUUID(string: "F000AA00-0451-4000-B000-000000000000")
    let IRTemperatureDataUUID       = CBUUID(string: "F000AA01-0451-4000-B000-000000000000")
    let IRTemperatureConfigUUID     = CBUUID(string: "F000AA02-0451-4000-B000-000000000000")

    //Humidity UUIDs
    let HumidityServiceUUID         = CBUUID(string: "F000AA20-0451-4000-B000-000000000000")
    let HumidityDataUUID            = CBUUID(string: "F000AA21-0451-4000-B000-000000000000")
    let HumidityConfigUUID          = CBUUID(string: "F000AA22-0451-4000-B000-000000000000")

    //Motion UUIDs
    let MovementServiceUUID         = CBUUID(string: "F000AA80-0451-4000-B000-000000000000")
    let MovementDataUUID            = CBUUID(string: "F000AA81-0451-4000-B000-000000000000")
    let MovementConfigUUID          = CBUUID(string: "F000AA82-0451-4000-B000-000000000000")

    //Ambient Light Sensor
    let AmbientLightServiceUUID     = CBUUID(string: "F000AA70-0451-4000-B000-000000000000")
    let AmbientLightDataUUID        = CBUUID(string: "F000AA71-0451-4000-B000-000000000000")
    let AmbientLightConfigUUID      = CBUUID(string: "F000AA72-0451-4000-B000-000000000000")

    //Simple Key
    let SimpleKeyServiceUUID        = CBUUID(string: "FFE0")
    let SimpleKeyDataUUID           = CBUUID(string: "FFE1")

    //I/O Service
    let IOServiceUUID               = CBUUID(string: "F000AA64-0451-4000-B000-000000000000")
    let IODataUUID                  = CBUUID(string: "F000AA65-0451-4000-B000-000000000000")
    let IOConfigUUID                = CBUUID(string: "F000AA66-0451-4000-B000-000000000000")



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
        return 8
    }


    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell: UITableViewCell = tableView.dequeueReusableCellWithIdentifier("cell")!

        if(indexPath.row == 0){

            temperatureLabel = UILabel()
            temperatureLabel.text = "00.00"
            temperatureLabel.sizeToFit()

            temperatureLabel.center = CGPoint(x: self.view.frame.width-40, y: cell.frame.height/2)
            cell.addSubview(temperatureLabel)
            cell.textLabel?.text = "🌡 Temperature Sensor"
            
        }

        if(indexPath.row == 1){

            humidityLabel = UILabel()
            humidityLabel.text = "00.00"
            humidityLabel.sizeToFit()

            humidityLabel.center = CGPoint(x: self.view.frame.width-40, y: cell.frame.height/2)
            cell.addSubview(humidityLabel)
            cell.textLabel?.text = "💧 Humidity Sensor"
            
        }

        if(indexPath.row == 2){

            ambientTemperatureLabel = UILabel()
            ambientTemperatureLabel.text = "00.00"
            ambientTemperatureLabel.sizeToFit()

            ambientTemperatureLabel.center = CGPoint(x: self.view.frame.width-40, y: cell.frame.height/2)
            cell.addSubview(ambientTemperatureLabel)
            cell.textLabel?.text = "☀️ IR Temperature Sensor"

        }

        if(indexPath.row == 3){

            let title: UILabel! = UILabel()
            title.text = "Accelerometer"
            title.sizeToFit()
            title.center = CGPoint(x: 70, y: 20)
            cell.addSubview(title)

            xAxisLabel = UILabel()
            xAxisLabel.text = "00000"
            xAxisLabel.sizeToFit()
            xAxisLabel.center = CGPoint(x: self.view.frame.origin.x + 40, y: 50)
            cell.addSubview(xAxisLabel)

            yAxisLabel = UILabel()
            yAxisLabel.text = "00000"
            yAxisLabel.sizeToFit()
            yAxisLabel.center = CGPoint(x: self.view.frame.midX, y: 50)
            cell.addSubview(yAxisLabel)


            zAxisLabel = UILabel()
            zAxisLabel.text = "00000"
            zAxisLabel.sizeToFit()
            zAxisLabel.center = CGPoint(x: self.view.frame.width - 40, y: 50)
            cell.addSubview(zAxisLabel)
            
        }

        if(indexPath.row == 4){

            let title: UILabel! = UILabel()
            title.text = "Gyroscope"
            title.sizeToFit()
            title.center = CGPoint(x: 70, y: 20)
            cell.addSubview(title)

            xAxisGyroLabel = UILabel()
            xAxisGyroLabel.text = "00000"
            xAxisGyroLabel.sizeToFit()
            xAxisGyroLabel.center = CGPoint(x: self.view.frame.origin.x + 40, y: 50)
            cell.addSubview(xAxisGyroLabel)

            yAxisGyroLabel = UILabel()
            yAxisGyroLabel.text = "00000"
            yAxisGyroLabel.sizeToFit()
            yAxisGyroLabel.center = CGPoint(x: self.view.frame.midX, y: 50)
            cell.addSubview(yAxisGyroLabel)


            zAxisGyroLabel = UILabel()
            zAxisGyroLabel.text = "00000"
            zAxisGyroLabel.sizeToFit()
            zAxisGyroLabel.center = CGPoint(x: self.view.frame.width - 40, y: 50)
            cell.addSubview(zAxisGyroLabel)
            
        }

        if(indexPath.row == 5){

            let title: UILabel! = UILabel()
            title.text = "Magnetometer"
            title.sizeToFit()
            title.center = CGPoint(x: 70, y: 20)
            cell.addSubview(title)

            xAxisMagnetometerLabel = UILabel()
            xAxisMagnetometerLabel.text = "00000"
            xAxisMagnetometerLabel.sizeToFit()
            xAxisMagnetometerLabel.center = CGPoint(x: self.view.frame.origin.x + 40, y: 50)
            cell.addSubview(xAxisMagnetometerLabel)

            yAxisMagnetometerLabel = UILabel()
            yAxisMagnetometerLabel.text = "00000"
            yAxisMagnetometerLabel.sizeToFit()
            yAxisMagnetometerLabel.center = CGPoint(x: self.view.frame.midX, y: 50)
            cell.addSubview(yAxisMagnetometerLabel)


            zAxisMagnetometerLabel = UILabel()
            zAxisMagnetometerLabel.text = "00000"
            zAxisMagnetometerLabel.sizeToFit()
            zAxisMagnetometerLabel.center = CGPoint(x: self.view.frame.width - 40, y: 50)
            cell.addSubview(zAxisMagnetometerLabel)
            
        }

        if indexPath.row == 6{


            let title: UILabel! = UILabel()
            title.center = CGPoint(x: 20, y: 20)
            title.text = "Simple Keys Service"
            title.sizeToFit()
            cell.addSubview(title)

            buttonOnOff = UILabel()
            buttonOnOff.center = CGPoint(x: 20, y: 50)
            buttonOnOff.text = "Button On/Off: not pressed"
            buttonOnOff.sizeToFit()
            cell.addSubview(buttonOnOff)

            buttonOne = UILabel()
            buttonOne.center = CGPoint(x: 20, y: 80)
            buttonOne.text = "Button One: not pressed"
            buttonOne.sizeToFit()
            cell.addSubview(buttonOne)
        }

        if indexPath.row == 7{

            redLED = UIButton()
            redLED.center = CGPoint(x: 20, y: 10)
            redLED.setTitle("Red LED", forState: UIControlState.Normal)
            redLED.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            redLED.setTitleColor(UIColor.greenColor (), forState: UIControlState.Highlighted)
            redLED.addTarget(self, action: "redLedPressed", forControlEvents: UIControlEvents.TouchDown)
            redLED.addTarget(self, action: "buttonReleased", forControlEvents: UIControlEvents.TouchUpInside)
            redLED.sizeToFit()
            cell.addSubview(redLED)

            grenLED = UIButton()
            grenLED.center = CGPoint(x: 20, y: 40)
            grenLED.setTitle("Green LED", forState: UIControlState.Normal)
            grenLED.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            grenLED.setTitleColor(UIColor.greenColor(), forState: UIControlState.Highlighted)
            grenLED.addTarget(self, action: "greenLedPressed", forControlEvents: UIControlEvents.TouchDown)
            grenLED.addTarget(self, action: "buttonReleased", forControlEvents: UIControlEvents.TouchUpInside)
            grenLED.sizeToFit()
            cell.addSubview(grenLED)

            buzzer = UIButton()
            buzzer.center = CGPoint(x: 20, y: 70)
            buzzer.setTitle("Buzzer", forState: UIControlState.Normal)
            buzzer.setTitleColor(UIColor.blueColor(), forState: UIControlState.Normal)
            buzzer.setTitleColor(UIColor.greenColor(), forState: UIControlState.Highlighted)
            buzzer.addTarget(self, action: "buzzerPressed", forControlEvents: UIControlEvents.TouchDown )
            buzzer.addTarget(self, action: "buttonReleased", forControlEvents: UIControlEvents.TouchUpInside)
            buzzer.sizeToFit()
            cell.addSubview(buzzer)
        }


        return cell
    }

    func redLedPressed(){
        
        if IOCharacteristic != nil{
            var valueToWrite = 1
            let writeValueIO = NSData(bytes: &valueToWrite, length: sizeof(UInt8))
            self.sensorTagPeripheral.writeValue(writeValueIO, forCharacteristic: IOCharacteristic, type: CBCharacteristicWriteType.WithResponse)
        }
    }

    func greenLedPressed(){

        if IOCharacteristic != nil{
            var valueToWrite = 2
            let writeValueIO = NSData(bytes: &valueToWrite, length: sizeof(UInt8))
            self.sensorTagPeripheral.writeValue(writeValueIO, forCharacteristic: IOCharacteristic, type: CBCharacteristicWriteType.WithResponse)
        }
    }

    func buzzerPressed(){

        if IOCharacteristic != nil{
            var valueToWrite = 4
            let writeValueIO = NSData(bytes: &valueToWrite, length: sizeof(UInt8))
            self.sensorTagPeripheral.writeValue(writeValueIO, forCharacteristic: IOCharacteristic, type: CBCharacteristicWriteType.WithResponse)
        }
    }

    func buttonReleased(){

        if IOCharacteristic != nil{
            var valueToWrite = 0
            let writeValueIO = NSData(bytes: &valueToWrite, length: sizeof(UInt8))
            self.sensorTagPeripheral.writeValue(writeValueIO, forCharacteristic: IOCharacteristic, type: CBCharacteristicWriteType.WithResponse)
        }
    }

    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {

        if indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5 {
            return 70
        }
        if indexPath.row == 6 || indexPath.row == 7 {
            return 110
        }

        return 44
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
        print((advertisementData as NSDictionary))
        print((advertisementData as NSDictionary).objectForKey(CBAdvertisementDataManufacturerDataKey))


        if (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataManufacturerDataKey) != nil{

            let newData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? NSDictionary
            if newData != nil {

                print(newData?.objectForKey("id"))
            }

        }


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

            if service.UUID == MovementServiceUUID{
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }

            if service.UUID == AmbientLightServiceUUID{
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
            if service.UUID == SimpleKeyServiceUUID{
                peripheral.discoverCharacteristics(nil, forService: thisService)
            }
            if service.UUID == IOServiceUUID{
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
        //print(service)

        //check the UUID of each characteristic to find config and data characteristics
        for characteristics in service.characteristics!{

            let thisCharacteristic = characteristics as CBCharacteristic
            //print(thisCharacteristic)

            if thisCharacteristic.UUID == IRTemperatureDataUUID{
                //Enable Sensor Notification
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
                //print(thisCharacteristic)
            }
            if thisCharacteristic.UUID == IRTemperatureConfigUUID{
                //Enable Sensor
                self.sensorTagPeripheral.writeValue(enableBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }

            if thisCharacteristic.UUID == HumidityDataUUID{
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
            if thisCharacteristic.UUID == HumidityConfigUUID{
                //Enable Humidity Sensor
                self.sensorTagPeripheral.writeValue(enableBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }

            if thisCharacteristic.UUID == MovementDataUUID{
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
            if thisCharacteristic.UUID == MovementConfigUUID{

                //Enble Accelerometer
                /*
                enable Accelerometer Mask = 0x0038, 56 decimal
                enable Gyroscope Mask = 0x0007, 7 decimal
                enable Magnetometer Mask = 0x0040, 64 decimal
                
                enable all Movement Sensors = 0x007F, 127 decimal
                */
                var enableMove = 127
                let enableBytesMove = NSData(bytes: &enableMove, length: sizeof(UInt16))
                self.sensorTagPeripheral.writeValue(enableBytesMove, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)

            }

            if thisCharacteristic.UUID == AmbientLightDataUUID{
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }
            if thisCharacteristic.UUID == AmbientLightConfigUUID{
                self.sensorTagPeripheral.writeValue(enableBytes, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }

            if thisCharacteristic.UUID == SimpleKeyDataUUID{
                self.sensorTagPeripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
            }

            if thisCharacteristic.UUID == IODataUUID{

                var valueToWrite = 0
                let writeValueIO = NSData(bytes: &valueToWrite, length: sizeof(UInt8))
                self.sensorTagPeripheral.writeValue(writeValueIO, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)

                IOCharacteristic = thisCharacteristic

            }
            if thisCharacteristic.UUID == IOConfigUUID{

                var enableValueIO = 1
                let enableBytesIO = NSData(bytes: &enableValueIO, length: sizeof(UInt8))
                self.sensorTagPeripheral.writeValue(enableBytesIO, forCharacteristic: thisCharacteristic, type: CBCharacteristicWriteType.WithResponse)
            }

        }

    }

    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {

        self.statusLabel.text = "Connected 😉"



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

            //print(dataArray)
        }

        if characteristic.UUID == HumidityDataUUID{
            let dataBytes = characteristic.value
            let dataLenght = dataBytes!.length
            var dataArray = [UInt16](count: dataLenght, repeatedValue: 0)
            dataBytes!.getBytes(&dataArray, length: dataLenght * sizeof(UInt16))

            /*
            //-- calculate relative humidity [%RH] --
            v = -6.0 + 125.0/65536 * (double)rawH; // RH= -6 + 125 * SRH/2^16
            */

            let ambientHumidity = -6.0 + 125.0/65536 * Double(dataArray[1])
            // Display on the temp label
            humidityLabel.text = NSString(format: "%.2f", ambientHumidity) as String

            /*
            //-- calculate temperature [deg C] --
            v = -46.85 + 175.72/65536 *(double)(qint16)rawT;
            */
            let ambientTemperature = -46.85 + 175.72/65536.0 * Double(dataArray[0])
            temperatureLabel.text = NSString(format: "%.2f", ambientTemperature) as String
        }

        if characteristic.UUID == MovementDataUUID{

            let dataBytes = characteristic.value
            let dataLenght = dataBytes!.length
            var dataArray = [Int16](count: dataLenght, repeatedValue: 0)
            dataBytes!.getBytes(&dataArray, length: dataLenght * sizeof(Int16))

            //print(dataArray)

            //Gyroscope: 0, 1, 2
            xAxisGyroLabel.text = NSString(format: "%.0f", Double(dataArray[0]) / (65536.0 / 500.0)) as String
            yAxisGyroLabel.text = NSString(format: "%.0f", Double(dataArray[1]) / (65536.0 / 500.0)) as String
            zAxisGyroLabel.text = NSString(format: "%.0f", Double(dataArray[2]) / (65536.0 / 500.0)) as String

            //Accelerometer: 3, 4, 5
            xAxisLabel.text = NSString(format: "%.3f", Double(dataArray[3]) * 2.0 / 32768.0) as String
            yAxisLabel.text = NSString(format: "%.3f", Double(dataArray[4]) * 2.0 / 32768.0) as String
            zAxisLabel.text = NSString(format: "%.3f", Double(dataArray[5]) * 2.0 / 32768.0) as String

            //Magnetometer: 6, 7, 8
            xAxisMagnetometerLabel.text = NSString(format: "%.0f", Double(dataArray[6]) * 4912.0 / 32760.0) as String
            yAxisMagnetometerLabel.text = NSString(format: "%.0f", Double(dataArray[7]) * 4912.0 / 32760.0) as String
            zAxisMagnetometerLabel.text = NSString(format: "%.0f", Double(dataArray[8]) * 4912.0 / 32760.0) as String

        }

        if characteristic.UUID == AmbientLightDataUUID{

            let dataBytes = characteristic.value
            let dataLenght = dataBytes!.length
            var dataArray = [UInt16](count: dataLenght, repeatedValue: 0)
            dataBytes!.getBytes(&dataArray, length: dataLenght * sizeof(UInt16))
            
        }

        if characteristic.UUID == SimpleKeyDataUUID{


            let dataBytes = characteristic.value
            let dataLenght = dataBytes!.length
            var dataArray = [UInt16](count: dataLenght, repeatedValue: 0)
            dataBytes!.getBytes(&dataArray, length: dataLenght * sizeof(UInt16))

            if(dataArray[0] == 0){
                buttonOne.textColor = UIColor.blackColor()
                buttonOnOff.textColor = UIColor.blackColor()
                buttonOne.text = "Button One: not pressed"
                buttonOnOff.text = "Button On/Off: not pressed"

            }
            if(dataArray[0] == 1){
                buttonOne.textColor = UIColor.redColor()
                buttonOne.text = "Button One: pressed"

                //Send local notification if app goes to background mode
                let notification = UILocalNotification()
                notification.fireDate = NSDate().dateByAddingTimeInterval(0.0)
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.alertBody = "Button One pressed"
                notification.soundName =  UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(notification)

            }
            if(dataArray[0] == 2){
                //print("On/Off Button pressed")
                buttonOnOff.textColor = UIColor.redColor()
                buttonOnOff.text = "Button On/Off: pressed"

                //Send local notification if app goes to background mode
                let notification = UILocalNotification()
                notification.fireDate = NSDate().dateByAddingTimeInterval(0.0)
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.alertBody = "Button On/Off pressed"
                notification.soundName =  UILocalNotificationDefaultSoundName
                UIApplication.sharedApplication().scheduleLocalNotification(notification)
            }
            if(dataArray[0] == 3){
                buttonOne.textColor = UIColor.redColor()
                buttonOnOff.textColor = UIColor.redColor()
                buttonOnOff.text = "Button On/Off: pressed"
                buttonOnOff.text = "Button On/Off: pressed"
            }

        }

    }
    
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        self.statusLabel.text = "Disconnected"
        print("Disconnected")
        central.scanForPeripheralsWithServices(nil, options: nil)
    }

}
