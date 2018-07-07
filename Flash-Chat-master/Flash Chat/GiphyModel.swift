//
//  GiphyModel.swift
//  Flash Chat
//
//  Created by Arpit Srivastava on 06/07/18.
//  Copyright © 2018 London App Brewery. All rights reserved.
//

import Foundation
import SwiftyJSON


// MARK:- DECODEABLE PROTOCOL
// ==========================

struct GiphyMode:Decodable {
    var data:[Result]
}

struct Result:Decodable{
    var images:Images
}

struct Images:Decodable {
    
    var original:Orignal
}

struct Orignal:Decodable {
    
    var url:String
}
