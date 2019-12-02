//
//  ViewController.swift
//  Expandable
//
//  Created by Gabriel Theodoropoulos on 28/10/15.
//  Copyright © 2015 Appcoda. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    var cellDescriptors: [NSMutableArray]!
    
    var visibleRowsPerSection = [[Int]]()
    
    
    
    func loadCellDescriptors (){
        if let path = Bundle.main.path(forResource: "CellDescriptor", ofType: "plist") {
            cellDescriptors = NSMutableArray(contentsOfFile: path) as? [NSMutableArray]
        }
        
        getIndicesOfVisibleRows()
        
        tblExpandable.reloadData()
    }
    
    
    func getIndicesOfVisibleRows() {
        
        visibleRowsPerSection.removeAll()
        
        for currentSectionCells in cellDescriptors {
            var visibleRows = [Int]()
            for row in 0...((currentSectionCells as! [[String: Any]]).count - 1) {
                let dic = currentSectionCells[row] as! [String : Any]
                if dic["isVisible"] as! Bool == true {
                    visibleRows.append(row)
                    
                }
            }
            visibleRowsPerSection.append(visibleRows)
        }
        print(visibleRowsPerSection.count)
    }
    
    
    func getCellDescriptorForIndexPath(indexPath: IndexPath) -> [String: Any] {
        
        let indexOfVisibleRow = visibleRowsPerSection[indexPath.section][indexPath.row]
        
        let cellDescriptor = cellDescriptors[indexPath.section][indexOfVisibleRow] as! [String: Any]
        
        return cellDescriptor
        
    }
    
    
    
    // MARK: IBOutlet Properties
    
    @IBOutlet weak var tblExpandable: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        loadCellDescriptors()
        configureTableView()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Custom Functions
    
    func configureTableView() {
        tblExpandable.delegate = self
        tblExpandable.dataSource = self
        
        tblExpandable.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tblExpandable.frame.width, height: 10))
        
        tblExpandable.register(UINib(nibName: "NormalCell", bundle: nil), forCellReuseIdentifier: "idCellNormal")
        tblExpandable.register(UINib(nibName: "TextfieldCell", bundle: nil), forCellReuseIdentifier: "idCellTextfield")
        tblExpandable.register(UINib(nibName: "DatePickerCell", bundle: nil), forCellReuseIdentifier: "idCellDatePicker")
        tblExpandable.register(UINib(nibName: "SwitchCell", bundle: nil), forCellReuseIdentifier: "idCellSwitch")
        tblExpandable.register(UINib(nibName: "ValuePickerCell", bundle: nil), forCellReuseIdentifier: "idCellValuePicker")
        tblExpandable.register(UINib(nibName: "SliderCell", bundle: nil), forCellReuseIdentifier: "idCellSlider")
    }
    
    
    // MARK: UITableView Delegate and Datasource Functions
    
   
    func numberOfSections(in tableView: UITableView) -> Int {
        if cellDescriptors != nil {
            print("\(cellDescriptors.count) section created")
            return cellDescriptors.count
            
        } else {
            return 0
        }
    }
    
       
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        visibleRowsPerSection[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath: indexPath)
        
        let cell = tableView.dequeueReusableCell(withIdentifier: currentCellDescriptor["cellIdentifier"] as! String, for: indexPath) as! CustomCell
        
        if currentCellDescriptor["cellIdentifier"] as! String == "idCellNormal" {
            if let primaryTitle = currentCellDescriptor["primaryTitle"] {
                cell.textLabel?.text = primaryTitle as? String
            }
            
            if let secondaryTitle = currentCellDescriptor["secondaryTitle"] {
                cell.detailTextLabel?.text = secondaryTitle as? String
            }
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellTextfield" {
            cell.textField.placeholder = currentCellDescriptor["primaryTitle"] as? String
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellSwitch" {
            cell.lblSwitchLabel.text = currentCellDescriptor["primaryTitle"] as? String
            
            let value = currentCellDescriptor["value"] as? String
            cell.swMaritalStatus.isOn = (value == "true") ? true : false
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellValuePicker" {
            cell.textLabel?.text = currentCellDescriptor["primaryTitle"] as? String
        }
        else if currentCellDescriptor["cellIdentifier"] as! String == "idCellSlider" {
            let value = currentCellDescriptor["value"] as! String
            cell.slExperienceLevel.value = (value as NSString).floatValue
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Personal"
        case 1:
            return "Preferences"
        default:
            return "Work Experience"
        }
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let currentCellDescriptor = getCellDescriptorForIndexPath(indexPath: indexPath)
        switch currentCellDescriptor["cellIdentifier"] as! String {
        case "idCellNormal":
            return 60.0
        case "idCellDatePicker":
            return 270.0
        default:
            return 44.0
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let indexOfTappedRow = visibleRowsPerSection[indexPath.section][indexPath.row]
        
        let dict = cellDescriptors[indexPath.section][indexOfTappedRow] as! NSMutableDictionary
        if dict["isExpandable"] as! Bool == true {
            var shouldExpandAndShowSubRows = false
            if dict["isExpanded"] as! Bool == false {
                // In this case the cell should expand.
                shouldExpandAndShowSubRows = true
            }
            dict.setValue(shouldExpandAndShowSubRows, forKey: "isExpanded")
            
            for i in (indexOfTappedRow + 1)...(indexOfTappedRow + (dict["additionalRows"] as! Int)) {
                (cellDescriptors[indexPath.section][i] as AnyObject).setValue(shouldExpandAndShowSubRows, forKey: "isVisible")
            }
        }
        
        getIndicesOfVisibleRows()
        tblExpandable.reloadSections(NSIndexSet(index: indexPath.section) as IndexSet, with: UITableView.RowAnimation.fade)
    }
    
}

