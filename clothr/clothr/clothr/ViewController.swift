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
var productName: NSString = "men's clothing"
var products = [Any]()


class ViewController: UIViewController {
    
    var saved = [Any]()
    
   
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var searchProduct: UIButton!
    @IBOutlet weak var searchField: UITextField!
    //-----------------------------------------initial load for swipe screen--------------------------------//
    override func viewDidLoad() {
        
        //products.append("HI")
        super.viewDidLoad()
        searchField.delegate=self
        // Do any additional setup after loading the view, typically from a nib.
        
        loadData(productName)
        print(productName)
//        let thisProduct: PSSProduct? = products[imageIndex] as? PSSProduct
//        print("viewdidLoad: " + (thisProduct?.name)! as Any)
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(wasDragged(gestureRecognizer:)))
        image.addGestureRecognizer(swipeGesture)
    }
    
//------------------------------------load swiping image-----------------------------------//
    
    func loadData(_ search:NSString)
    {
        let buffer = helperfunctions()
        buffer.fillProductBuffer(search as String!)
        
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
//---------------------------------get image for swiping function--------------------------------//
    func get_image(_ imageView:UIImageView)
    {
        if(imageIndex>=products.count-1)
        {
            imageIndex=0
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
//        print("HI")
        let labelpoint = gestureRecognizer.translation(in: view)
        image.center = CGPoint(x: view.bounds.width / 2 + labelpoint.x , y: view.bounds.height / 2 + labelpoint.y)
        
        if gestureRecognizer.state == .ended {
            if image.center.x < (view.bounds.width / 2 - 100) {
                print("NOT Interested")
                get_image(image)

            }

            if image.center.x > (view.bounds.width / 2 + 100) {
                print("Interested in clothing item")
                let thisProduct: PSSProduct? = products[imageIndex-1] as? PSSProduct
                saved.append(thisProduct as Any)
                checker+=1
                get_image(image)
            }

            image.center = CGPoint(x: view.bounds.width/2 , y: view.bounds.height/2 )
        }
    }
//-----------------------------------------encode data for saved page--------------------------------//

    @IBAction func saveProducts(_ sender: Any) {
        //let thisProduct: PSSProduct? = saved[0] as? PSSProduct
        let encodedData = NSKeyedArchiver.archivedData(withRootObject: saved)
        let defaults = UserDefaults.standard
        defaults.set(encodedData, forKey: "products")
        print("saved")
    }

//------------------------------------------search for what user whats---------------------------------//
   
    @IBAction func searchPressed(_ sender: Any) {
        
            imageIndex=0
            products.removeAll()
//        DispatchQueue.main.async(execute: {
            loadData(searchField.text! as NSString)
//        })
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

}

//------------------------------------------extension for search field---------------------------------------//
extension ViewController : UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}

