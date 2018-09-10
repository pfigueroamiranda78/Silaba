//
//  Reto.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 4/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

import Foundation

class Reto {
    
    private var _id: String!
    private var _lat: Double!
    private var _lon: Double!
    private var _add: String!
    private var _des: String!
    private var _username: String!
    private var _userImg: String!
    private var _userId: String!
    private var _imageUrl: String!
    public var DataImgUser: Data!
    public var DataImgReto: Data!
    public var _Tag: String!
    
    init(RetoId: String, retoData: Dictionary<String, AnyObject>) {
        _id = RetoId
        
        if let userid = retoData["userid"] as? String {
            _userId = userid
        }
        
        if let username = retoData["username"] as? String {
            _username = username
        }
        
        if let userImg = retoData["userImg"] as? String {
            _userImg = userImg
        }
        
        if let retoDesc = retoData["DesReto"] as? String {
            _des = retoDesc
        }
        
        if let retoAddr = retoData["AddrReto"] as? String {
            _add = retoAddr
        }
        
        if let retoLat = retoData["LatReto"] as? Double {
            _lat = retoLat
        }
        
        if let retoLon = retoData["LonReto"] as? Double {
            _lon = retoLon
        }
        
        if let imageUrl = retoData["imageUrl"] as? String {
            _imageUrl = imageUrl
        }
        
        if let Tag = retoData["Tag"] as? String {
            _Tag = Tag
        }
    }
    
    var tag:String {
        if (_Tag == nil) {
            return ""
        }
        return _Tag
    }
    
    var userid: String {
        return _userId
    }
    
    var username: String {
        return _username
    }
    
    var userImg: String {
        return _userImg
    }
    
    var id: String {
        return _id
    }
    
    var latitude: Double {
        return _lat
    }
    
    var longitude: Double {
        return _lon
    }
    
    var address: String {
        return _add
    }
    
    var description : String {
        return _des
    }
    
    var imageUrl : String {
        if _imageUrl != nil {
            return _imageUrl
        } else {
            return ""
        }
    }
    
    ///////////////////////////////////////////////////////////////////////
    ///  This function converts decimal degrees to radians              ///
    ///////////////////////////////////////////////////////////////////////
    func deg2rad(deg:Double) -> Double {
        return deg * .pi / 180
    }
    
    ///////////////////////////////////////////////////////////////////////
    ///  This function converts radians to decimal degrees              ///
    ///////////////////////////////////////////////////////////////////////
    func rad2deg(rad:Double) -> Double {
        return rad * 180.0 / .pi
    }
    
    ////////////////////////////////////////////////////////////////////////////////
    ///                                                                          ///
    ///  This routine calculates the distance between two points (given the      ///
    ///  latitude/longitude of those points). It is being used to calculate      ///
    ///  the distance between two location using GeoDataSource(TM)               ///
    ///  products.                                                               ///
    ///                                                                          ///
    ///  Definitions:                                                            ///
    ///    South latitudes are negative, east longitudes are positive            ///
    ///                                                                          ///
    ///  Passed to function:                                                     ///
    ///    lat1, lon1 = Latitude and Longitude of point 1 (in decimal degrees)   ///
    ///    lat2, lon2 = Latitude and Longitude of point 2 (in decimal degrees)   ///
    ///    unit = the unit you desire for results                                ///
    ///           where: 'M' is statute miles (default)                          ///
    ///                  'K' is kilometers                                       ///
    ///                  'N' is nautical miles                                   ///
    ///                                                                          ///
    ///  Worldwide cities and other features databases with latitude longitude   ///
    ///  are available at https://www.geodatasource.com                           ///
    ///                                                                          ///
    ///  For enquiries, please contact sales@geodatasource.com                   ///
    ///                                                                          ///
    ///  Official Web site: https://www.geodatasource.com                         ///
    ///                                                                          ///
    ///  GeoDataSource.com (C) All Rights Reserved 2016                          ///
    ///                                                                          ///
    ////////////////////////////////////////////////////////////////////////////////
    func distanceTo(Latitude lat2:Double, Longitude lon2:Double, Unit unit:String) -> Double {
        let theta = _lon - lon2
        var dist = sin(deg2rad(deg: _lat)) * sin(deg2rad(deg: lat2)) + cos(deg2rad(deg: _lat)) * cos(deg2rad(deg: lat2)) * cos(deg2rad(deg: theta))
        dist = acos(dist)
        dist = rad2deg(rad: dist)
        dist = dist * 60 * 1.1515
        if (unit == "K") {
            dist = dist * 1.609344
        }
        else if (unit == "N") {
            dist = dist * 0.8684
        }
        return dist
    }
}
