//
//  ViewController.swift
//  clothr
//
//  Created by Czar Vince Gabriel Cabral on 10/21/17.
//  Sam Singh
//  Andrew Gu(i)terres
//  Gilbert Aragon
//  Kianna Mark
//
//  Copyright © 2017 cmps115. All rights reserved.
//

import UIKit
import Parse

var imageIndex: NSInteger=0
var checker: NSInteger=0
var check: NSInteger=0
var productName: NSString = "men's shirt"
var products = [Any]()
var productBuffer = [Any]()
var xCenter = CGFloat(0)
var yCenter = CGFloat(0)

class ViewController: UIViewController {
    
    
    var savedImages = [Any]()
    var savedNames = [Any]()
    var savedPrices = [Any]()
    var savedURL = [Any]()
    var saleBool = [String]()
    var pagingIndex=[String: NSNumber]() //dictionary with search term as a key, paging index as value
    var searchIndex: NSNumber=0
    var bufferIndex: NSInteger=0
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var searchProduct: UIButton!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var thumbImage: UIImageView!
    
    //-----------------------------------------initial load for swipe screen--------------------------------//
    override func viewDidLoad() {
        super.viewDidLoad()
        searchField.delegate=self
        // Do any additional setup after loading the view, typically from a nib.
        loadUserStorage()
        let when = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.loadData(productName)
        }
        
        //updateUserStorage()
        // set the x and y variable to be equal to the center of the image
        xCenter = image.center.x
        yCenter = image.center.y
        
        // hide the back button
        self.navigationItem.setHidesBackButton(true, animated: false)
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(showDetails(gestureRecognizer:)))
        doubleTap.numberOfTapsRequired=2
        image.addGestureRecognizer(doubleTap)
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        image.addGestureRecognizer(swipeGesture)
    }

@objc func showDetails(gestureRecognizer: UIPanGestureRecognizer)
{
    let encodedProduct = NSKeyedArchiver.archivedData(withRootObject: products[imageIndex-1])
    let defaults = UserDefaults.standard
    defaults.set(encodedProduct, forKey: "product")
    performSegue(withIdentifier: "showDetails", sender: self)
}
    
//---------------------------load paging index and saved stuff--------------------------//
    func loadUserStorage()
    {
        let query = PFQuery(className:"storages")
        query.whereKey("user", equalTo:PFUser.current()?.username as Any)
        print(PFUser.current()?.username as Any)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        self.loadUserObject(object.objectId!)
                    }
                }
            } else {
                // Log details of the failure
                print("Error loading ")
            }
            }
    }

//---------------------------grabs user paging info and saved arrays-----------------------//
    
    func loadUserObject(_ id: String)
    {
        let query = PFQuery(className:"storages")
        query.getObjectInBackground(withId: id)
        {
            (query: PFObject?, error: Error?) -> Void in
            if error != nil
            {
                print("error")
            } else if let user=query
            {
                self.savedImages=user["savedProductImages"] as! [Any]
                self.savedNames=user["savedProductNames"] as! [Any]
                self.savedPrices=user["savedProductPrices"] as! [Any]
                self.savedURL=user["savedProductURL"] as! [Any]
                self.saleBool=user["saleBooleans"] as! [String]
                self.pagingIndex=user["pagingIndexes"] as! [String : NSNumber]
            }
        }
    }
//-----------------------------updating paging info and saved arrays-----------------------//

    func updateUserStorage()
    {
        let query = PFQuery(className:"storages")
        query.whereKey("user", equalTo:PFUser.current()?.username as Any)
        print(PFUser.current()?.username as Any)
        query.findObjectsInBackground {
            (objects: [PFObject]?, error: Error?) -> Void in
            
            if error == nil {
                // The find succeeded.
                print("Successfully retrieved \(objects!.count) scores.")
                // Do something with the found objects
                if let objects = objects {
                    for object in objects {
                        self.updateUserObject(object.objectId!)
                    }
                }
            } else {
                // Log details of the failure
                print("Error loading ")
            }
        }
    }
    
//-----------------------------updtaing paging info and saved arrays helper------------------//
    
    func updateUserObject(_ id: String)
    {
        let query = PFQuery(className:"storages")
        query.getObjectInBackground(withId: id) {
            (userData: PFObject?, error: Error?) -> Void in
            if error != nil {
                print(error as Any)
            } else if let userData = userData {
                userData["savedProductImages"] = self.savedImages
                userData["savedProductNames"] = self.savedNames
                userData["savedProductURL"] = self.savedURL
                userData["savedProductPrices"] = self.savedPrices
                userData["pagingIndexes"] = self.pagingIndex
                userData["saleBooleans"] = self.saleBool
                userData.saveInBackground()
            }
        }
    }
//------------------------------------load swiping image-----------------------------------//
    
    func loadData(_ search:NSString)
    {
        productName=search
        if let pagingCheck=pagingIndex[productName as String!]
        {
            print("paging check: ")
            print(pagingCheck)
            searchIndex=pagingCheck //sets searching index to index saved in dictionary for searched product
        } else
        {
            print(productName)
            pagingIndex[productName as String!]=0
            updateUserStorage()
        }
        print(pagingIndex[productName as String!] as Any)
        print("Search index: ")
        print(searchIndex)
        let buffer = helperfunctions()
        
        buffer.fillProductBuffer(search as String!, searchIndex)
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            if let data = UserDefaults.standard.object(forKey: "name") as? NSData {
                products = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [Any]
            }
            let thisProduct: PSSProduct? = products[imageIndex] as? PSSProduct
            print("loadData: " + (thisProduct?.name)! as Any)
            self.get_image(self.image)
        }
        //        print("loadData: " + (thisProduct?.name)! as Any)
        //        get_image(image)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//---------------------------------load extra products in product array--------------------------------//

    func loadExtraBuffer(_ search: NSString)
    {
        productName=search
        if let pagingCheck=pagingIndex[productName as String!]
        {
            searchIndex = (pagingCheck.intValue+searchIndex.intValue+10) as NSNumber
        }
        
        let buffer = helperfunctions()
        
        buffer.fillProductBuffer(search as String!, searchIndex)
        
        let when = DispatchTime.now() + 2
        DispatchQueue.main.asyncAfter(deadline: when) {
            if let data = UserDefaults.standard.object(forKey: "name") as? NSData {
                productBuffer = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [Any]
            }
//            let thisProduct: PSSProduct? = products[products.count-1] as? PSSProduct
//            print("loadData: " + (thisProduct?.name)! as Any)
//            print(productBuffer.count)
            products+=productBuffer
            print(products.count)
            print(products[11])
        }
    }
    
//---------------------------------get image for swiping function--------------------------------//
    func get_image(_ imageView:UIImageView)
    {
        if(imageIndex==products.count-5)
        {
            //imageIndex=0
            loadExtraBuffer(productName)
        }
        let thisProduct: PSSProduct? = products[imageIndex] as? PSSProduct
        let url = thisProduct?.image.url
        let session = URLSession.shared
        
        let task = session.dataTask(with: url!, completionHandler: {
            (
            data, response, error) in
            if data != nil
            {
                let image = UIImage(data: data!)
                if(image != nil)
                {
                    DispatchQueue.main.async(execute: {
                        imageView.image = image
                        imageView.contentMode = .scaleAspectFit
                    })
                }
            }
        })
        
        task.resume()
        imageIndex+=1
    }
//------------------------------------function to check if pic is drag--------------------------------//
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        let labelpoint = gestureRecognizer.translation(in: view)
        image.center = CGPoint(x: xCenter + labelpoint.x , y: yCenter + labelpoint.y)
        
//------------------------------------function scale and drag photo--------------------------------//
        
        let xFromCenter = view.bounds.width / 2 - image.center.x
        
        //rotation and scaling
        var rotation = CGAffineTransform(rotationAngle: xFromCenter / 200)
        let scale = min(75 / abs(xFromCenter),1)
        var scaledAndRotate = rotation.scaledBy(x: scale, y: scale)
        
        image.transform = scaledAndRotate

        
 //------------------------------------adding the thumbs up or down--------------------------------//
        
        let xForThumb = image.center.x - searchProduct.center.x
        
        // dragged to right else left
        if xForThumb > 0 {
            thumbImage.image = #imageLiteral(resourceName: "thumbs-up")
            thumbImage.tintColor = UIColor.green
            
        }else {
            
            
            thumbImage.image = #imageLiteral(resourceName: "thumbs-down")
            thumbImage.tintColor = UIColor.red
        }

        thumbImage.alpha = abs(xForThumb) / image.center.x

        if gestureRecognizer.state == .ended {
            if image.center.x < (view.bounds.width / 2 - 100) {
                print("NOT Interested")
//                let thisProduct: PSSProduct? = products[imageIndex-1] as? PSSProduct
//                print(thisProduct?.colors[0] as Any)
//                let color = thisProduct?.colors
//                //print(color![0])
//                let thiscolorarray: PSSProductColor? = color![0] as? PSSProductColor
//                let pcolor: PSSColor? = thiscolorarray?.canonicalColors[0] as? PSSColor
//                print(pcolor?.colorID as Any)
//                print(thiscolor?.colorID as Any)
                get_image(image)
            }

            if image.center.x > (view.bounds.width / 2 + 100) {
                print("Interested in clothing item")
                let thisProduct: PSSProduct? = products[imageIndex-1] as? PSSProduct
                savedImages.append(thisProduct?.image.url.absoluteString as Any)
                savedNames.append(thisProduct?.name as Any)
                savedPrices.append(thisProduct?.regularPriceLabel as Any)
                savedURL.append(thisProduct?.buyURL.absoluteString as Any)
                if(thisProduct?.isOnSale())!
                {
                    saleBool.append((thisProduct?.salePriceLabel)!)
                } else
                {
                    saleBool.append("-1")
                }
                checker+=1
                get_image(image)
            }

            // put rotation and image back to center
            rotation = CGAffineTransform(rotationAngle: 0)
            scaledAndRotate = rotation.scaledBy(x: 1, y: 1)
            image.transform = scaledAndRotate
            
            thumbImage.alpha = 0
            
            image.center = CGPoint(x: xCenter , y: yCenter)
            
        }
    }
//-----------------------------------------save data for saved page--------------------------------//

    @IBAction func saveProducts(_ sender: Any) {
        if pagingIndex[productName as String!] == nil
        {
            pagingIndex[productName as String!]=0
        } else
        {
            print(pagingIndex[productName as String] as Any)
            pagingIndex[productName as String] = Int(truncating: pagingIndex[productName as String]!) + imageIndex as NSNumber  //saves the previous paging offset
            //pagingIndex[productName as String] = pagingIndex[productName as String]?.intValue + imageIndex  //saves the previous paging offset
            print(pagingIndex[productName as String] as Any)
        }
        updateUserStorage()
        encodeData()
    }
    
//-----------------------------------------encode data for saveProducts()------------------------------//
    func encodeData()
    {
        let encodedImages = NSKeyedArchiver.archivedData(withRootObject: savedImages)
        let encodedNames = NSKeyedArchiver.archivedData(withRootObject: savedNames)
        let encodedPrices = NSKeyedArchiver.archivedData(withRootObject: savedPrices)
        let encodedURL = NSKeyedArchiver.archivedData(withRootObject: savedURL)
        let encodedSales = NSKeyedArchiver.archivedData(withRootObject: saleBool)
        let defaults = UserDefaults.standard
        defaults.set(encodedImages, forKey: "images")
        defaults.set(encodedNames, forKey: "names")
        defaults.set(encodedPrices, forKey: "prices")
        defaults.set(encodedURL, forKey: "url")
        defaults.set(encodedSales, forKey: "sales")
        print("saved")
    }

//------------------------------------------search for what user wants---------------------------------//
   
    @IBAction func searchPressed(_ sender: Any) {
        products.removeAll()
        if pagingIndex[productName as String!] == nil
        {
            pagingIndex[productName as String!]=0
        } else
        {
            print(pagingIndex[productName as String] as Any)
            pagingIndex[productName as String] = Int(truncating: pagingIndex[productName as String]!) + imageIndex as NSNumber  //saves the previous paging offset
            //pagingIndex[productName as String] = pagingIndex[productName as String]?.intValue + imageIndex  //saves the previous paging offset
            print(pagingIndex[productName as String] as Any)
        }
        
        
        //        print(pagingIndex[searchField.text as! String] as Any)
        //            imageIndex=0
        //            products.removeAll()
        //        DispatchQueue.main.async(execute: {
        loadData(searchField.text! as NSString)
        //        })
        imageIndex=0
        
        let when = DispatchTime.now() + 2 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            //loadData(searchField.text! as NSString)
            let thisProduct: PSSProduct? = products[imageIndex] as? PSSProduct
            print("searchPressed: " + (thisProduct?.name)! as Any)
            //productName=searchField.text! as NSString
            //self.get_image(self.image)
        }
    
       
    }
    
//------------------------------------------search field functions---------------------------------------//

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchField.resignFirstResponder()
    }
    
    // removes the navbar
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
        loadUserStorage()
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
}

//------------------------------------------extension for search field---------------------------------------//
extension ViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

