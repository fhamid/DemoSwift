//
//  ViewController.swift
//  AssesmentSwift
//
//  Created by Farid Hamid on 3/17/16.
//  Copyright © 2016 ABC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    var shortForm: NSString!
    var hud: MBProgressHUD!
    var dataDictionary: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Acronym Search";
        self.tableView.estimatedRowHeight = 44.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func search(sender: AnyObject) {
        if let text = self.textField.text where !text.isEmpty
        {
            self.shortForm = self.textField.text?.stringByReplacingOccurrencesOfString(" ", withString: "")
            self.fetchData()
        }else{
            self.showAlertWithMessage("Empty string, Please enter an acronym")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    private func fetchData(){
        
        let requestString = "http://www.nactem.ac.uk/software/acromine/dictionary.py?sf=\(self.shortForm)"
        let request = NSURLRequest(URL: NSURL(string:requestString)!)
        let op = AFHTTPRequestOperation.init(request: request)
        op.responseSerializer = AFHTTPResponseSerializer()
        self.showHudDisplayWithMessage("Searching...")
        op.setCompletionBlockWithSuccess({[weak self](operation: AFHTTPRequestOperation!, responseObject: AnyObject!) -> Void in
            
            do {
                let dataArray = try NSJSONSerialization.JSONObjectWithData((responseObject as! NSData), options: NSJSONReadingOptions.AllowFragments)
                if (dataArray.count > 0){
                    self?.dataDictionary = dataArray.objectAtIndex(0) as! NSDictionary;
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.tableView.reloadData()
                        self?.hideHudDisplay()
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue()) {
                        self?.hideHudDisplay()
                        self?.showAlertWithMessage("No Data Available")
                    }
                }
            }
            catch let error as NSError {
                dispatch_async(dispatch_get_main_queue()) {
                    self?.hideHudDisplay()
                    self?.showAlertWithMessage("Error Parsing Data! - \(error.description)")
                }
                
            }
            
            }) {[weak self](operation: AFHTTPRequestOperation, error: NSError) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    self?.hideHudDisplay()
                    self?.showAlertWithMessage("Network Error! - \(error.description)")
                }
                
            }
        
        
        NSOperationQueue.mainQueue().addOperation(op)
        
    }
    
    private func showAlertWithMessage(msg: String){
        let alertController = UIAlertController(title: "Error", message: msg, preferredStyle: .Alert)
        let OKAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            
        }
        alertController.addAction(OKAction)
        self.presentViewController(alertController, animated: true) {
        }
    }
    
    private func showHudDisplayWithMessage(msg: String){
        dispatch_async(dispatch_get_main_queue()) {
            self.view.endEditing(true)
            self.hud = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            self.hud.mode = MBProgressHUDMode.Indeterminate
            self.hud.backgroundView.style = .Blur
            self.hud.label.text = msg
        }
    }
    private func hideHudDisplay(){
        if self.hud != nil{
            self.hud.hideAnimated(true)
        }
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate{

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows: NSInteger = ((self.dataDictionary) != nil) ? (self.dataDictionary["lfs"] as! NSArray).count:0
        return numRows
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("theCell", forIndexPath: indexPath) 
        
        cell.textLabel!.numberOfLines = 0;
        
        let rowDictionary = ((self.dataDictionary["lfs"] as! NSArray)[indexPath.row] as! NSDictionary);
        
        let longForm = rowDictionary["lf"] as! String
        let frequency = rowDictionary["freq"] as! NSInteger
        let since = rowDictionary["since"] as! NSInteger
        let variations = (rowDictionary["vars"] as! NSArray).count
        
        let constructString = String(format: "Longform: %@\nFrequency: %d\nSince: %d\nVariations: %d",longForm,frequency,since,variations)
        
        if variations > 0 {
            cell.accessoryType = .DisclosureIndicator
        }
        cell.textLabel!.text = constructString;
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let header: String = ((self.dataDictionary) != nil) ? (self.dataDictionary["sf"] as! String):""
        return header
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let rowDictionary = ((self.dataDictionary["lfs"] as! NSArray)[indexPath.row] as! NSDictionary);
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewControllerWithIdentifier("detailViewController") as! DetailViewController
        vc.dataArray = (rowDictionary["vars"] as! NSArray)
        vc.longForm = rowDictionary["lf"] as! String
        vc.modalTransitionStyle = .CoverVertical
        let nc = UINavigationController(rootViewController: vc)
        self.presentViewController(nc, animated: true) { () -> Void in
            
        }
    }
    
}