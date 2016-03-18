//
//  DetailViewController.swift
//  AssesmentSwift
//
//  Created by Farid Hamid on 3/17/16.
//  Copyright © 2016 ABC. All rights reserved.
//

import UIKit

public class DetailViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    public var dataArray: NSArray!
    public var longForm: String!

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Variations";
        self.tableView.estimatedRowHeight = 44.0;
        self.tableView.rowHeight = UITableViewAutomaticDimension;
        
        let rightButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: Selector("dismissModalView"))
        self.navigationItem.rightBarButtonItem = rightButton
    

        // Do any additional setup after loading the view.
    }

    func dismissModalView(){
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    

}

extension DetailViewController: UITableViewDataSource, UITableViewDelegate{
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numRows: NSInteger = ((self.dataArray) != nil) ? self.dataArray.count:0
        return numRows
        
    }
    
     public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("detailCell", forIndexPath: indexPath)
        
        cell.textLabel!.numberOfLines = 0;
        
        let rowDictionary = (self.dataArray[indexPath.row] as! NSDictionary)
        
        let longForm = rowDictionary["lf"] as! String
        let frequency = rowDictionary["freq"] as! NSInteger
        let since = rowDictionary["since"] as! NSInteger
        
        let constructString = String(format: "Longform: %@\nFrequency: %d\nSince: %d",longForm,frequency,since)
        
        cell.textLabel!.text = constructString;
        
        return cell
    }
    
    public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let header: String = ((self.longForm
            ) != nil) ? self.longForm:""
        return header
    }
    
}
