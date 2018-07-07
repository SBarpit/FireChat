//
//  WebService.swift
//  Flash Chat
//
//  Created by Arpit Srivastava on 06/07/18.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import Foundation
import SwiftyJSON

enum WebServices { }



extension WebServices {
    
    
    static func searchGify(val:String,success:@escaping (GiphyMode) ->(), failure: @escaping (Error) ->()){
        
        let request = WebServices.getRequest(val)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            
            if (error != nil) {
                
                print(error as Any)
            }else{
                do {
//                    let val = try JSON(data:data!)
//                    print(val)
                    let mdata =  try JSONDecoder().decode(GiphyMode.self, from: data!) as? GiphyMode
                    success(mdata!)
                }
                catch {
                    print("Error")
                }
                
            }
            
            
        }).resume()
        
        
        
    }
    
    static func getRequest(_ search:String) -> NSMutableURLRequest{
        return NSMutableURLRequest(url: NSURL(string: "https://api.giphy.com/v1/gifs/search?q=\(search)&api_key=aJXo6fMYFTHUHeL6C2zAvhhlunL5Ea0L")! as URL,
                                   cachePolicy: .useProtocolCachePolicy,
                                   timeoutInterval: 10.0)
    }
    
}
//MARK:- Error Codes
//==================
struct error_codes {
    static let success = 200
    
}
