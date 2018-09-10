//
//  SOYouTubeAPI.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 15/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//
//
//  SOYoutubeAPI.swift
//  SOYoutube
//
//  Created by Hitesh on 11/7/16.
//  Copyright © 2016 myCompany. All rights reserved.
//

import UIKit
import Foundation
import Alamofire

let API_KEY = "AIzaSyDL6z35KcfcPaXUjnrh9auyF7QvT0wBsbA"

class YouTubeServicesProvider: NSObject, VideoService {

    
    
    func fetchVideos(identifier: String, talentSource: Talent, knowledgeSource: knowledgeSource, offset: String, limit: UInt, callback: ((VideoServiceResult) -> Void)?) {
        var videoServiceTextSearchData = VideoServiceTextSearchData ()
        
        videoServiceTextSearchData.knowledgeSource = knowledgeSource
        videoServiceTextSearchData.talentSource = talentSource
        videoServiceTextSearchData.searchText = identifier 
        videoServiceTextSearchData.source = .general
            self.getVideoWithTextSearch(data: videoServiceTextSearchData) { (result) in
                callback?(result)
            }
    }
    
    var strNextPageToken = ""
    
    func getTopVideos(data: VideoServiceTopSearchData, callback: ((VideoServiceResult) -> Void)?) {
        var result = VideoServiceResult()
        
        //load Indicator
        if #available(iOS 9.0, *) {
            
            Alamofire.SessionManager.default.session.getAllTasks { (response) in
                response.forEach { $0.cancel() }
            }
        } else {
            // Fallback on earlier versions
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
            }
        }
        
        let contryCode = self.getCountryCode()
        var listVideo = VideoList()
        var videos = [Video]()
        let strURL = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&chart=mostPopular&maxResults=50&regionCode=\(contryCode)&key=\(API_KEY)"
        
        let urlString = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(urlString!).responseJSON(completionHandler: { (responseData) -> Void in
            
            
            let isSuccess = responseData.result.isSuccess
            if isSuccess {
                
                let resultsDict = responseData.result.value as! Dictionary<String, AnyObject>
                
                let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                
                
                for i in 0..<items.count {
                    
                    let snippetDict = items[i]["snippet"] as! Dictionary<String, AnyObject>
                    if !snippetDict["title"]! .isEqual("Private video") && !snippetDict["title"]! .isEqual("Deleted video"){
                        let statisticsDict = items[i]["statistics"] as! Dictionary<String, AnyObject>
                        
                        let title = snippetDict["title"] as! String
                        let subTilte = snippetDict["channelTitle"] as! String
                        let channelId = snippetDict["channelId"] as! String
                        let imageUrl = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["high"] as! Dictionary<String, AnyObject>)["url"] as! String
                        let videoId = items[i]["id"] as! String
                        let viewCount = statisticsDict["viewCount"] as! String
                        let publishedAt = snippetDict["publishedAt"] as! String
                        let video :Video = Video(withTitle: title, with: subTilte, with: channelId, with: imageUrl, with: videoId, with: viewCount, with: publishedAt)
                        videos.append(video)
                        
                    }
                }
                listVideo.videos = videos
                DispatchQueue.global(qos: .default).async {
                    result.videoList = listVideo
                    result.success = true
                    result.nextToken = self.strNextPageToken
                    callback?(result)
                    return
                }
            } else {
                result.error = .videosnotFound(message: "No se encontraron videos")
                callback?(result)
            }
        })
    }
    
    func getVideoWithTextSearch(data: VideoServiceTextSearchData, callback: ((VideoServiceResult) -> Void)?) {
        var result = VideoServiceResult()
        if #available(iOS 9.0, *) {
            Alamofire.SessionManager.default.session.getAllTasks { (response) in
                response.forEach { $0.cancel() }
            }
        } else {
            // Fallback on earlier versions
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
            })
        }
        
        let contryCode = self.getCountryCode()
        var listVideo = VideoList()
        var videos = [Video]()
        // PPFM: Aqui agregar el CHANNEL-ID para Youtube
        
        var strURL = String()
        
        if (data.channelId.count > 0) {
            strURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=20&channelId=\(data.channelId)&order=Relevance&q=\(data.searchText)&regionCode=\(contryCode)&type=video&key=\(API_KEY)"
            
        } else {
            strURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=20&order=Relevance&q=\(data.searchText)&regionCode=\(contryCode)&type=video&key=\(API_KEY)"
        }
        
        let urlString = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(urlString!).responseJSON(completionHandler: { (responseData) -> Void in
            
            let isSuccess = responseData.result.isSuccess
            if isSuccess {
                let resultsDict = responseData.result.value as! Dictionary<String, AnyObject>
                
                let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                
                let arrayViewCount = NSMutableArray()
                for i in 0..<items.count {
                    
                    let snippetDict = items[i]["snippet"] as! Dictionary<String, AnyObject>
                    
                    if !snippetDict["title"]! .isEqual("Private video") && !snippetDict["title"]! .isEqual("Deleted video") && items[i]["id"]!["videoId"]! != nil{
                        arrayViewCount.add(items[i]["id"]!["videoId"]! as! String)
                        
                        let title = snippetDict["title"] as! String
                        let subTilte = snippetDict["channelTitle"] as! String
                        let channelId = snippetDict["channelId"] as! String
                        let imageUrl = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["high"] as! Dictionary<String, AnyObject>)["url"] as! String
                        let videoId = items[i]["id"]!["videoId"]! as! String
                        let publishedAt = snippetDict["publishedAt"] as! String
                        
                        let video :Video = Video(withTitle: title, with: subTilte, with: channelId, with: imageUrl, with: videoId, with: "0", with: publishedAt)
                        videos.append(video)
                        
                    }
                }
                listVideo.videos = videos
                //Get video count
                
                if arrayViewCount.count > 0{
                    let videoUrlString = "https://www.googleapis.com/youtube/v3/videos?part=statistics&id=\(arrayViewCount.componentsJoined(by: ","))&key=\(API_KEY)"
                    
                    
                    Alamofire.request(videoUrlString).responseJSON(completionHandler: { (responseData) -> Void in
                        
                        let isSuccess = responseData.result.isSuccess//JSON(responseData.result.isSuccess)
                        if isSuccess {
                            let resultsDict = responseData.result.value as! Dictionary<String, AnyObject>
                            let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                            
                            for i in 0..<items.count {
                                
                                var video = videos[i]
                                let statisticsDict = items[i]["statistics"] as! Dictionary<String, AnyObject>
                                video.viewCount = statisticsDict["viewCount"] as! String
                                
                            }
                            DispatchQueue.global(qos: .default).async {
                                result.videoList = listVideo
                                result.success = true
                                result.nextToken = self.strNextPageToken
                                result.source = data.source
                                callback?(result)
                            }
                        }else{
                            DispatchQueue.global(qos: .default).async {
                                result.videoList = listVideo
                                result.success = false
                                result.nextToken = self.strNextPageToken
                                callback?(result)
                            }
                        }
                    })
                }else{
                    DispatchQueue.global(qos: .default).async {
                        result.videoList = listVideo
                        result.success = false
                        result.nextToken = self.strNextPageToken
                        callback?(result)
                    }
                }
            } else {
                
                DispatchQueue.global(qos: .default).async {
                    result.videoList = listVideo
                    result.success = false
                    result.nextToken = self.strNextPageToken
                    callback?(result)
                }
            }
        })
    }
    
    
    
    
    //MARK: - Search Top 50 Videos
    func getTopVideos(nextPageToken : String, showLoader : Bool, completion: @escaping (Array<Dictionary<String, AnyObject>>, Bool, String)-> ()){
        
        
        //load Indicator
        if #available(iOS 9.0, *) {
        
            Alamofire.SessionManager.default.session.getAllTasks { (response) in
                response.forEach { $0.cancel() }
            }
        } else {
            // Fallback on earlier versions
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler { (dataTasks, uploadTasks, downloadTasks) in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
            }
        }
        
        let contryCode = self.getCountryCode()
        var arrVideo: Array<Dictionary<String, AnyObject>> = []
        let strURL = "https://www.googleapis.com/youtube/v3/videos?part=snippet,statistics&chart=mostPopular&maxResults=50&regionCode=\(contryCode)&key=\(API_KEY)"
        
        let urlString = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(urlString!).responseJSON(completionHandler: { (responseData) -> Void in
            
            
            let isSuccess = responseData.result.isSuccess
            if isSuccess {
                
                let resultsDict = responseData.result.value as! Dictionary<String, AnyObject>
                
                let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                
                for i in 0..<items.count {
                    
                    let snippetDict = items[i]["snippet"] as! Dictionary<String, AnyObject>
                    if !snippetDict["title"]! .isEqual("Private video") && !snippetDict["title"]! .isEqual("Deleted video"){
                        let statisticsDict = items[i]["statistics"] as! Dictionary<String, AnyObject>
                        
                        
                        var videoDetailsDict = Dictionary<String, AnyObject>()
                        videoDetailsDict["videoTitle"] = snippetDict["title"]
                        videoDetailsDict["videoSubTitle"] = snippetDict["channelTitle"]
                        videoDetailsDict["channelId"] = snippetDict["channelId"]
                        videoDetailsDict["imageUrl"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["high"] as! Dictionary<String, AnyObject>)["url"]
                        videoDetailsDict["videoId"] = items[i]["id"]  as AnyObject//PVideoViewCount
                        videoDetailsDict["viewCount"] = statisticsDict["viewCount"] as AnyObject

                        arrVideo.append(videoDetailsDict )
                    }
                }
                DispatchQueue.global(qos: .default).async {
                    completion(arrVideo, true, self.strNextPageToken)
                }
            } else {
                
            }
        })
    }
    
    
    //MARK: -Search Video with text
    
    // callback: ((VideoServiceResult) -> Void)?)
    
    func getVideoWithTextSearch (searchText:String, nextPageToken:String, callback: ((Array<Dictionary<String, AnyObject>>, Bool, String)-> Void)?) {
        
        
        if #available(iOS 9.0, *) {
            Alamofire.SessionManager.default.session.getAllTasks { (response) in
                response.forEach { $0.cancel() }
            }
        } else {
            // Fallback on earlier versions
            Alamofire.SessionManager.default.session.getTasksWithCompletionHandler({ (dataTasks, uploadTasks, downloadTasks) in
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
            })
        }
        
        let contryCode = self.getCountryCode()
        var arrVideo: Array<Dictionary<String, AnyObject>> = []
        var arrVideoFinal: Array<Dictionary<String, AnyObject>> = []
        
        let strURL = "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=20&order=Relevance&q=\(searchText)&regionCode=\(contryCode)&type=video&key=\(API_KEY)"
        
        let urlString = strURL.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        Alamofire.request(urlString!).responseJSON(completionHandler: { (responseData) -> Void in
            
            let isSuccess = responseData.result.isSuccess
            if isSuccess {
                let resultsDict = responseData.result.value as! Dictionary<String, AnyObject>
                
                let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                
                let arrayViewCount = NSMutableArray()
                for i in 0..<items.count {
                    
                    let snippetDict = items[i]["snippet"] as! Dictionary<String, AnyObject>
                    
                    if !snippetDict["title"]! .isEqual("Private video") && !snippetDict["title"]! .isEqual("Deleted video") && items[i]["id"]!["videoId"]! != nil{
                        var videoUrlBase = "https://www.youtube.com/embed/"
                        var videoDetailsDict = Dictionary<String, AnyObject>()
                        arrayViewCount.add(items[i]["id"]!["videoId"]! as! String)
                        
                        videoDetailsDict["videoTitle"] = snippetDict["title"]
                        videoDetailsDict["videoSubTitle"] = snippetDict["channelTitle"]
                        videoDetailsDict["channelId"] = snippetDict["channelId"]
                        videoDetailsDict["imageUrl"] = ((snippetDict["thumbnails"] as! Dictionary<String, AnyObject>)["high"] as! Dictionary<String, AnyObject>)["url"]
                        videoDetailsDict["videoId"] = items[i]["id"]!["videoId"]! as AnyObject
                        videoDetailsDict["videoUrl"] = videoUrlBase.append(items[i]["id"]!["videoId"]! as! String) as AnyObject
                        arrVideo.append(videoDetailsDict)
                    }
                }
                
                //Get video count
                
                if arrayViewCount.count > 0{
                    let videoUrlString = "https://www.googleapis.com/youtube/v3/videos?part=statistics&id=\(arrayViewCount.componentsJoined(by: ","))&key=\(API_KEY)"
                    
                    
                    Alamofire.request(videoUrlString).responseJSON(completionHandler: { (responseData) -> Void in
                        
                        let isSuccess = responseData.result.isSuccess//JSON(responseData.result.isSuccess)
                        if isSuccess {
                            let resultsDict = responseData.result.value as! Dictionary<String, AnyObject>
                            let items: Array<Dictionary<String, AnyObject>> = resultsDict["items"] as! Array<Dictionary<String, AnyObject>>
                            
                            for i in 0..<items.count {
                                
                                var videoDetailsDict = arrVideo[i]
                                let statisticsDict = items[i]["statistics"] as! Dictionary<String, AnyObject>
                                videoDetailsDict["viewCount"] = statisticsDict["viewCount"]
                                arrVideoFinal.append(videoDetailsDict)
                            }
                            DispatchQueue.global(qos: .default).async {
                                callback?(arrVideoFinal, true, self.strNextPageToken)
                            }
                        }else{
                            DispatchQueue.global(qos: .default).async {
                                callback?(arrVideoFinal, false, self.strNextPageToken)
                            }
                        }
                    })
                }else{
                    DispatchQueue.global(qos: .default).async {
                        callback?(arrVideoFinal,  false, self.strNextPageToken)
                    }
                }
            } else {
                
                DispatchQueue.global(qos: .default).async {
                    callback?(arrVideoFinal, false, self.strNextPageToken)
                }
            }
        })
    }
    
    
    
    //MARK: Get Country code
    func getCountryCode() -> String {
        return "CO"
    }
}

