//
//  ViewController.swift
//  roboarm
//
//  Created by Subrahmanya Sai Krishna Teja on 9/29/21.
//

//Imports
import UIKit
import CoreBluetooth //bluetooth module

//globals
var names = Array<CBPeripheral>()
var selector = -1
// array to store the slider values
var sliderAngles:[String] = []
class ViewController: UIViewController, CBPeripheralDelegate{
    
    var connectedPeripheral: CBPeripheral!
    
    var angleChar: CBCharacteristic!
    //instance creation
    @IBOutlet weak var connectionLabel: UILabel!
    var centralManager: CBCentralManager!
    @IBOutlet weak var angleOne: UILabel!
    @IBOutlet weak var angleTwo: UILabel!
    @IBOutlet weak var angleThree: UILabel!
    @IBOutlet weak var angleFour: UILabel!
    @IBOutlet weak var angleFive: UILabel!
    @IBOutlet weak var angleSix: UILabel!
    @IBOutlet weak var bleTable: UITableView!
    
    @IBAction func sliderOnee(_ sender: UISlider) {
        sender.isContinuous = false
        angleOne.text =  "E E angle (A): " + String(Int(sender.value))
        writeToBLE(withCharacteristic: angleChar, withValue: String("A" + String(Int(sender.value)) + "\n").data(using: .utf8)!)
    }
    
    @IBAction func sliderTwo(_ sender: UISlider) {
        sender.isContinuous = false
        angleTwo.text = "Wrist angle (B): " + String(Int(sender.value))
        writeToBLE(withCharacteristic: angleChar, withValue: String("B" + String(Int(sender.value)) + "\n").data(using: .utf8)!)
    }
    
    @IBAction func sliderThree(_ sender: UISlider) {
        sender.isContinuous = false
        angleThree.text = "Elbow angle (C): " + String(Int(sender.value))
        writeToBLE(withCharacteristic: angleChar, withValue: String("C" + String(Int(sender.value)) + "\n").data(using: .utf8)!)
    }
    
    @IBAction func sliderFour(_ sender: UISlider) {
        sender.isContinuous = false
        angleFour.text = "Shoulder angle (D): " + String(Int(sender.value))
        writeToBLE(withCharacteristic: angleChar, withValue: String("D" + String(Int(sender.value)) + "\n").data(using: .utf8)!)
    }
    
    @IBAction func sliderFive(_ sender: UISlider) {
        sender.isContinuous = false
        angleFive.text = "Waist angle (E): " + String(Int(sender.value))
        writeToBLE(withCharacteristic: angleChar, withValue: String("E" + String(Int(sender.value)) + "\n").data(using: .utf8)!)
    }
    
    @IBAction func sliderSix(_ sender: UISlider) {
        sender.isContinuous = false
        angleSix.text = "Speed of motors (F): " + String(Int(sender.value))
        writeToBLE(withCharacteristic: angleChar, withValue: String("F" + String(Int(sender.value)) + "\n").data(using: .utf8)!)
    }
    
    @IBAction func bleList(_ sender: Any) {
        bleTable.isHidden = false
        //UI Table instances
        bleTable.dataSource = self
        bleTable.delegate = self
    
    }
    
    @IBAction func disconnect(_ sender: Any) {
        if connectedPeripheral != nil{
            centralManager?.cancelPeripheralConnection(connectedPeripheral)
            connectedPeripheral = nil
            connectionLabel.text = ""
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // Bluetooth instance
        centralManager = CBCentralManager(delegate: self, queue: nil)
        bleTable.isHidden = true
    }
}

extension ViewController: CBCentralManagerDelegate{
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state{
            
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            print("central.state is .poweredOn")
            centralManager.scanForPeripherals(withServices: nil,options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
            print("scanning peripherals")
        @unknown default:
            print("Unknown state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber){
       //dont stop the scan here - doing so will no detect any devices
        if peripheral.name != nil{
            print(peripheral.name)
            //loading all the names in names array
            names.append(peripheral)
        }
    }
    
    //Ble Connected
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected")
        connectionLabel.text! = "Connected to: " + peripheral.name!
        centralManager.stopScan()
        self.connectedPeripheral = peripheral //save the peripheral
        connectedPeripheral.delegate = self
        print(peripheral.name)
        connectedPeripheral.discoverServices(nil)
    }
        
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let services = connectedPeripheral.services{
            for service in services {
                print("service found")
                print(services.description)
                connectedPeripheral.discoverCharacteristics(nil, for: service)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let characteristics = service.characteristics{
            for characteristic in characteristics {
                print("found chars")
                print(characteristics.description)
                angleChar = characteristic
            }
        }
    }
    
    private func writeToBLE(withCharacteristic characteristic: CBCharacteristic, withValue value: Data){
        if characteristic.properties.contains(.writeWithoutResponse) && connectedPeripheral != nil {
            connectedPeripheral.writeValue(value, for: characteristic, type: .withoutResponse)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource{
    
    // delegate functions
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        print(cell.textLabel!.text)
        selector = indexPath.row
        tableView.isHidden = true
        
        //Ble Connection
        centralManager.connect(names[selector], options: nil)
    }
    
    
    
    // Datasource functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return names.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = names[indexPath.row].name!
            cell.textLabel?.textAlignment = NSTextAlignment.center
            cell.backgroundColor = .gray
            cell.alpha = 0.7
            return cell
        }
}
