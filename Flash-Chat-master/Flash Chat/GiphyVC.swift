//
//  ViewController.swift
//  Flash Chat
//
//  Created by Arpit Srivastava on 06/07/18.
//  Copyright © 2018 London App Brewery. All rights reserved.
//
import UIKit
//import GiphyCoreSDK
//import SDWebImage
//import ListPlaceholder
//import SDLoader
import SVProgressHUD


protocol GetGifDelegate{
    func giphy(_ url:String)
}

class GiphyVC: UIViewController {
    
    // MARK:- IBOUTLETS
    // ================
    
    @IBOutlet weak var searchtextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK:- PROPERTIES
    //===================
    
    var gifyData = [String]()
    var model:GiphyMode!
    var delegate:GetGifDelegate!
    // let sdLoader = SDLoader()
    
    // MARK:- LIFE CYCLE METHODS
    // =========================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetUp()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK:- PRIVATE METHODS
    // ======================
    
    private func initialSetUp(){
        searchButton.addTarget(self, action: #selector(searchButtonAction), for: .touchUpInside)
        searchtextField.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK:- OBJEC METHODS
    // ====================
    
    @objc func searchButtonAction() {
        
        self.view.endEditing(true)
        let querry = self.searchtextField.text
        let newString = querry?.replacingOccurrences(of: " ", with: "+", options: .literal, range: nil)
        SVProgressHUD.show()
        WebServices.searchGify(val: newString!, success: { (model) in
            self.model = model
            print(model.data[0].images.original.url)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            SVProgressHUD.dismiss()
            
        }) { (e:Error) in
            print(e.localizedDescription)
        }
        
    }
}


// MARK:- TABLE VIEW DATASOURCE AND DELEGATE
// =========================================

extension GiphyVC:UITableViewDelegate,UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if model == nil {
            return 1
        }else{
            return model.data.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GiphyCell", for: indexPath) as! GiphyCell
        if model == nil {
            cell.giphyImages.image = UIImage.gif(name: "loading")
        }else{
        let url = URL(string: model.data[indexPath.row].images.original.url)
        if let data = try? Data(contentsOf: url!)
        {
            cell.giphyImages.image = UIImage.gif(data: data)
        }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate.giphy(model.data[indexPath.row].images.original.url)
        self.navigationController?.popViewController(animated: true)
        //self.dismiss(animated: true, completion: nil)
    }
}

// MARK:- TEXTFIELD DELEGATE METHODS
// =================================

extension GiphyVC:UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchButtonAction()
        textField.endEditing(true)
        return true
    }
}

// MARK:- TABLEVIEW CELL CLASS
// ===========================
class GiphyCell:UITableViewCell{
    
    @IBOutlet weak var giphyImages: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
