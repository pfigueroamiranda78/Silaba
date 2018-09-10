//
//  Post.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 3/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

class Poste {
    
    private var _username: String!
    private var _userImg: String!
    private var _postText: String!
    private var _postKey: String!
    private var _imageUrl: String!
    private var _comentarios = [Poste]()
    public var DataImgUser: Data!
    public var DataImgPost: Data!
    public var Classification: String!
    
    var username: String {
        return _username
    }
    
    var userImg: String {
        return _userImg
    }
    
    var postText: String {
        return _postText
    }
    
    var postKey: String {
        return _postKey
    }
    
    var comentarios: [Poste] {
        return _comentarios
    }
    
    var imageUrl : String {
        if _imageUrl != nil {
            return _imageUrl
        } else {
            return ""
        }
    }
    
    init(postText: String, username: String, userImg: String) {
        _postText = postText
        _userImg = userImg
        _username = username
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        _postKey = postKey
        
        if let username = postData["username"] as? String {
            _username = username
        }
        
        if let userImg = postData["userImg"] as? String {
            _userImg = userImg
        }
        
        if let postText = postData["postText"] as? String {
            _postText = postText
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            _imageUrl = imageUrl
        }
        
        if let comentario = postData["Comentarios"] as? Dictionary<String, AnyObject> {
            for (key, value) in comentario {
                let comment = Poste(postKey: key, postData: (value as? Dictionary<String, AnyObject>)!)
                _comentarios.append(comment)
            }
            _comentarios.sort(by: {$0._postKey < $1._postKey})
        }
    }
    
    func clean() {
        self._comentarios.removeAll()
    }
    
}
