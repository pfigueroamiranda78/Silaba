
//
//  ROGoogleTranslate.swift
//  ROGoogleTranslate
//
//  Created by Robin Oster on 20/10/16.
//  Copyright © 2016 prine.ch. All rights reserved.
//
import Foundation

let API_KEY_TRANSLATOR = "AIzaSyDL6z35KcfcPaXUjnrh9auyF7QvT0wBsbA"

/// MARK: - ROGoogleTranslate
/// Offers easier access to the Google Translate API
open class GoogleTranslator: TranslatorService {
    
    
    ///
    /// Translate a phrase from one language into another
    ///
    /// - parameter params:   ROGoogleTranslate Struct contains all the needed parameters to translate with the Google Translate API
    /// - parameter callback: The translated string will be returned in the callback
    ///
    
    
    func translate(inputData: TranslateSearchData, callback:((TranslateServiceResult) -> Void)?) {
        
        var result = TranslateServiceResult()
        
        guard
            let urlEncodedText = inputData.text.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            
            let freeUrl = URL(string: "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(inputData.source)&tl=\(inputData.target)&dt=t&q=\(urlEncodedText)") else {
                
                result.error = .notTranslation(message: "Error al utilizar la URL libre de Google")
                callback?(result)
                return

            }
        
        let httprequest = URLSession.shared.dataTask(with: freeUrl, completionHandler: { (data, response, error) in
            
            guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200 else {
                result.error = .notTranslation(message: (error?.localizedDescription)!)
                callback?(result)
                return
            }
            
            guard
                
                let data            = data,
                let translatedData: Data = data.dropFirst().dropFirst().dropFirst().dropFirst() as Data?,
                let translatedText = String(data:translatedData, encoding: String.Encoding.utf8) as String?
            
                else {
                    result.error = .notTranslation(message: "Error al traducir")
                    callback?(result)
                    return
            }
            let arr = translatedText.components(separatedBy: ",")
            result.translated = arr[0]
            
            guard
                let urlEncodedText2 = inputData.text2.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
                
                let freeUrl2 = URL(string: "https://translate.googleapis.com/translate_a/single?client=gtx&sl=\(inputData.source)&tl=\(inputData.target)&dt=t&q=\(urlEncodedText2)") else {
                    
                    result.error = .notTranslation(message: "Error al utilizar la URL libre de Google")
                    callback?(result)
                    return
                    
            }
            
            let httprequest2 = URLSession.shared.dataTask(with: freeUrl2, completionHandler: { (data, response, error) in
                
                guard error == nil, (response as? HTTPURLResponse)?.statusCode == 200 else {
                    result.error = .notTranslation(message: (error?.localizedDescription)!)
                    callback?(result)
                    return
                }
                
                guard
                    
                    let data            = data,
                    let translatedData: Data = data.dropFirst().dropFirst().dropFirst().dropFirst() as Data?,
                    let translatedText = String(data:translatedData, encoding: String.Encoding.utf8) as String?
                    
                    else {
                        result.error = .notTranslation(message: "Error al traducir")
                        callback?(result)
                        return
                }
                let arr = translatedText.components(separatedBy: ",")
                result.translated2 = arr[0]
                callback?(result)
                
            })
            httprequest2.resume()
           
        })
        
       
        httprequest.resume()
    }
}
