//
//  SinglePostViewDelegate.swift
//  Photostream
//
//  Created by Mounir Ybanez on 19/01/2017.
//  Copyright © 2017 Mounir Ybanez. All rights reserved.
//

import UIKit

extension SinglePostViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = presenter.postData as? PostListCollectionCellItem
        prototype.configure(with: item, isPrototype: true)
        let size = CGSize(width: listLayout.itemSize.width, height: prototype.dynamicHeight)
        return size
    }
}

extension SinglePostViewController: PostListCollectionCellDelegate {
    
    func didTapHashTag(cell: PostListCollectionCell, hashTag theTag: String) {
        guard let index = collectionView?.indexPath(for: cell)?.section else {
                return
        }
        presenter.presentPostFromTagg(at: index, with: theTag)
    }
    
    func didTapMentionTag(cell: PostListCollectionCell, mentionTag theMention: String) {
        guard let index = collectionView?.indexPath(for: cell)?.section else {
                return
        }
        presenter.presentUserTimelineFromTag(at: index, with: theMention)
        
    }
    
    func didTapIdentifier(cell: PostListCollectionCell) {
        guard let index = collectionView?.indexPath(for: cell)?.section else {
                return
        }
    }
    

    func setTalentSource(at index: Int, with type: Talent, with knowledgeSource: knowledgeSource) {
        presenter.presentVideoController(with: type, with: knowledgeSource)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func showWikiText(withTitle wikiTitle: String, withText wikiText: String, withImage image: URL?) {
        let alert = UIAlertController(title: wikiTitle, message: wikiText, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        let imageView = UIImageView(frame: CGRectMake(220, 10, 30, 30))
        if (image != nil) {
            imageView.sd_setImage(with: image) { (image, error, sdimagetpyecache , URL) in
                imageView.image = image
            }
        }
        alert.view.addSubview(imageView)
        alert.addAction(okAction)
        controller!.present(alert, animated: true, completion: nil)
    }
    
    func setKnowledgeSource(at index: Int?, withTalent talent:Talent, withKnowledgeSourcePrimary: knowledgeSource, withRecognized recognized:String) {
        let knowledgeSourcePicker = UIAlertController()
        knowledgeSourcePicker.title = "¿Cuál deseas ver?"
        knowledgeSourcePicker.message = " Sílaba intentará buscar información de acuerdo con el tema que selecciones."
        
        if (withKnowledgeSourcePrimary == knowledgeSource.videos) {
            knowledgeSourcePicker.addAction(UIAlertAction(title: "Recomendados por Sílaba",
                                                          style: UIAlertActionStyle.default,
                                                          handler: {(alert: UIAlertAction!) in self.setTalentSource(at: index!, with: talent, with: knowledgeSource.recommend  )}))
            knowledgeSourcePicker.addAction(UIAlertAction(title: "Publicados por ",
                                                          style: UIAlertActionStyle.default,
                                                          handler: {(alert: UIAlertAction!) in self.setTalentSource(at: index!, with: talent, with: knowledgeSource.silabers)}))
            knowledgeSourcePicker.addAction(UIAlertAction(title: "General",
                                                          style: UIAlertActionStyle.default,
                                                          handler: {(alert: UIAlertAction!) in self.setTalentSource(at: index!, with: talent, with: knowledgeSource.general)}))
            knowledgeSourcePicker.addAction(UIAlertAction(title: "Cancelar",
                                                          style: UIAlertActionStyle.cancel,
                                                          handler: {(alert: UIAlertAction!) in knowledgeSourcePicker.dismiss(animated: true, completion: {})}))
            present(knowledgeSourcePicker, animated: true)
            return
        }
        
        if (withKnowledgeSourcePrimary == knowledgeSource.wikipedia) {
            WikipediaNetworking.appAuthorEmailForAPI = "pedro.figueroa@silaba.org"
            let language_wikipedia = WikipediaLanguage("es")
            
            _ = Wikipedia.shared.requestOptimizedSearchResults(language: language_wikipedia, term: recognized) { (searchResults, error) in
                guard error == nil else {
                    knowledgeSourcePicker.addAction(UIAlertAction(title: "No disponible",
                                                                  style: UIAlertActionStyle.cancel,
                                                                  handler: {(alert: UIAlertAction!) in knowledgeSourcePicker.dismiss(animated: true, completion: {})}))
                    return
                    
                }
                guard let searchResults = searchResults else {
                    knowledgeSourcePicker.addAction(UIAlertAction(title: "No disponible",
                                                                  style: UIAlertActionStyle.cancel,
                                                                  handler: {(alert: UIAlertAction!) in knowledgeSourcePicker.dismiss(animated: true, completion: {})}))
                    return
                }
                
                var maxArticles: Int = 5
                
                for articlePreview in (searchResults.results) {
                    if (maxArticles == 0) {
                        continue
                    }
                    
                    
                    maxArticles = maxArticles - 1
                    knowledgeSourcePicker.addAction(UIAlertAction(title: articlePreview.displayTitle,
                                                                  style: UIAlertActionStyle.default,
                                                                  handler: {(alert: UIAlertAction!) in self.showWikiText(withTitle: articlePreview.displayTitle, withText: articlePreview.displayText, withImage: articlePreview.imageURL)}))
                    
                }
                
                knowledgeSourcePicker.addAction(UIAlertAction(title: "Cancelar",
                                                              style: UIAlertActionStyle.cancel,
                                                              handler: {(alert: UIAlertAction!) in knowledgeSourcePicker.dismiss(animated: true, completion: {})}))
                self.present(knowledgeSourcePicker, animated: true)
                return
            }
        }
        if (withKnowledgeSourcePrimary == knowledgeSource.traduction) {
            var translator : TranslatorService
            translator = GoogleTranslator()
            let translateSearchData = TranslateSearchData (source: "es", target: "en", text: recognized, text2: recognized)
            
            translator.translate(inputData: translateSearchData) { (result) in
                
                if (result.error != nil) {
                    knowledgeSourcePicker.addAction(UIAlertAction(title: "No disponible",
                                                                  style: UIAlertActionStyle.cancel,
                                                                  handler: {(alert: UIAlertAction!) in knowledgeSourcePicker.dismiss(animated: true, completion: {})}))
                }
                knowledgeSourcePicker.addAction(UIAlertAction(title: "Inglés",
                                                              style: UIAlertActionStyle.default,
                                                              handler: {(alert: UIAlertAction!) in self.showWikiText(withTitle: "Traducción al inglés", withText: result.translated!, withImage: nil)}))
                
                let translateSearchDataFr = TranslateSearchData (source: "es", target: "fr", text: recognized, text2: recognized)
                
                translator.translate(inputData: translateSearchDataFr) { (result) in
                    
                    if (result.error != nil) {
                        knowledgeSourcePicker.addAction(UIAlertAction(title: "No disponible",
                                                                      style: UIAlertActionStyle.cancel,
                                                                      handler: {(alert: UIAlertAction!) in knowledgeSourcePicker.dismiss(animated: true, completion: {})}))
                    }
                    knowledgeSourcePicker.addAction(UIAlertAction(title: "Francés",
                                                                  style: UIAlertActionStyle.default,
                                                                  handler: {(alert: UIAlertAction!) in self.showWikiText(withTitle: "Traducción al francés", withText: result.translated!, withImage: nil)}))
                    
                    knowledgeSourcePicker.addAction(UIAlertAction(title: "Cancelar",
                                                                  style: UIAlertActionStyle.cancel,
                                                                  handler: {(alert: UIAlertAction!) in knowledgeSourcePicker.dismiss(animated: true, completion: {})}))
                    
                    self.present(knowledgeSourcePicker, animated: true)
                    return
                }
            }
            
            
            
            
        }
        if (withKnowledgeSourcePrimary == knowledgeSource.opendata) {
            knowledgeSourcePicker.addAction(UIAlertAction(title: "No disponible",
                                                          style: UIAlertActionStyle.cancel,
                                                          handler: {(alert: UIAlertAction!) in knowledgeSourcePicker.dismiss(animated: true, completion: {})}))
            self.present(knowledgeSourcePicker, animated: true)
            return
            
        }
        
        if (withKnowledgeSourcePrimary == knowledgeSource.realityAugmented) {
            knowledgeSourcePicker.addAction(UIAlertAction(title: "No disponible",
                                                          style: UIAlertActionStyle.cancel,
                                                          handler: {(alert: UIAlertAction!) in knowledgeSourcePicker.dismiss(animated: true, completion: {})}))
            self.present(knowledgeSourcePicker, animated: true)
            return
        }
        
    }
    
    
    func setKnowledgeSource(at index: Int?, withTalent talent:Talent, withRecognized recognized:String) {
        let knowledgeSourcePicker = UIAlertController()
        knowledgeSourcePicker.title = "¿Dónde deseas buscar sobre "+talent.id+" con "+recognized+"?"
        knowledgeSourcePicker.message = " Selecciona una fuente desde donde buscar.."
        knowledgeSourcePicker.addAction(UIAlertAction(title: "Videos sobre ",
                                                      style: UIAlertActionStyle.default,
                                                      handler: {(alert: UIAlertAction!) in self.setKnowledgeSource(at: index!, withTalent:talent, withKnowledgeSourcePrimary: knowledgeSource.videos, withRecognized :recognized  )}))
        knowledgeSourcePicker.addAction(UIAlertAction(title: "Wikipedida",
                                                      style: UIAlertActionStyle.default,
                                                      handler: {(alert: UIAlertAction!) in self.setKnowledgeSource(at: index!, withTalent:talent, withKnowledgeSourcePrimary: knowledgeSource.wikipedia, withRecognized :recognized  )}))
        knowledgeSourcePicker.addAction(UIAlertAction(title: "Datos abiertos",
                                                      style: UIAlertActionStyle.default,
                                                      handler: {(alert: UIAlertAction!) in self.setKnowledgeSource(at: index!, withTalent:talent, withKnowledgeSourcePrimary: knowledgeSource.opendata, withRecognized :recognized  )}))
        knowledgeSourcePicker.addAction(UIAlertAction(title: "Realidad aumentada",
                                                      style: UIAlertActionStyle.default,
                                                      handler: {(alert: UIAlertAction!) in self.setKnowledgeSource(at: index!, withTalent:talent, withKnowledgeSourcePrimary: knowledgeSource.realityAugmented, withRecognized: recognized  )}))
        knowledgeSourcePicker.addAction(UIAlertAction(title: "Cancelar",
                                                      style: UIAlertActionStyle.cancel,
                                                      handler: {(alert: UIAlertAction!) in knowledgeSourcePicker.dismiss(animated: true, completion: {
                                                        
                                                      })}))
        
        present(knowledgeSourcePicker, animated: true)
        
    }
    
    func didTapShare(cell: PostListCollectionCell) {
        guard let isLiked = presenter.postData?.isLiked else {
            return
        }
        
        cell.toggleShare(share: isLiked) { [weak self] in
            self?.presenter.toggleShare()
        }
            
    }
    
    
    func didTapVideo(cell: PostListCollectionCell) {
        guard let index = collectionView![cell]?.section,
            let post = presenter.postData else {
            return
        }
        
        setKnowledgeSource(at: index, withTalent: post.talent, withRecognized: post.identifier)
    }
    
    func didTapPhoto(cell: PostListCollectionCell) {
        presenter.likePost()
    }
    
    func didTapHeart(cell: PostListCollectionCell) {
        guard let isLiked = presenter.postData?.isLiked else {
            return
        }
        
        cell.toggleHeart(liked: isLiked) { [weak self] in
            self?.presenter.toggleLike()
        }
    }
    
    func didTapComment(cell: PostListCollectionCell) {
        presenter.presentCommentController(shouldComment: true)
    }
    
    func didTapCommentCount(cell: PostListCollectionCell) {
        presenter.presentCommentController()
    }
    
    func didTapLikeCount(cell: PostListCollectionCell) {
        presenter.presentPostLikes()
    }
    
    
    func didTapShareCount(cell: PostListCollectionCell) {
        presenter.presentPostShares()
    }
}

extension SinglePostViewController: PostListCollectionHeaderDelegate {
    
    func didTapDisplayName(header: PostListCollectionHeader, point: CGPoint) {
        presenter.presentUserTimeline()
    }
    
    func didTapAvatar(header: PostListCollectionHeader, point: CGPoint) {
        presenter.presentUserTimeline()
    }
}
