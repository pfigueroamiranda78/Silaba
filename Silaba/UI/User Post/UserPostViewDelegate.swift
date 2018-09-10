//
//  UserPostViewDelegate.swift
//  Photostream
//
//  Created by Mounir Ybanez on 09/12/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit

extension UserPostViewController: UICollectionViewDelegateFlowLayout {
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        var condition: Bool = false
        
        switch sceneType {
        case .grid:
            condition = indexPath.row == presenter.postCount - 10
            
        case .list:
            condition = indexPath.section == presenter.postCount - 10
        }
        
        guard condition else {
            return
        }
        
        presenter.loadMorePosts()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch sceneType {
        case .grid:
            return gridLayout.itemSize
            
        case .list:
            let item = presenter.post(at: indexPath.section) as? PostListCollectionCellItem
            prototype.configure(with: item, isPrototype: true)
            let size = CGSize(width: listLayout.itemSize.width, height: prototype.dynamicHeight)
            return size
        }
    }
}

extension UserPostViewController: PostListCollectionCellDelegate {
    func didTapHashTag(cell: PostListCollectionCell, hashTag theTag: String) {
        guard let index = collectionView?.indexPath(for: cell)?.section else {
                return
        }
        presenter.presentPostFromTagg(at: index, with: theTag)
    }
    
    func didTapMentionTag(cell: PostListCollectionCell, mentionTag theMention: String) {
        guard let index = collectionView?.indexPath(for: cell)?.section  else {
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
        presenter.presentVideoController(at: index, with: type, with: knowledgeSource)
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func showTranslationText(source src: String, target tgt: String, text txt: String) {
        var translator : TranslatorService
        var translatedText: String = "No disponible"
        let translateSearchData = TranslateSearchData (source: src, target: tgt, text: txt, text2: txt)
        translator = GoogleTranslator()
        translator.translate(inputData: translateSearchData) { (result) in
            if (result.error == nil) {
                translatedText = result.translated!
                let alert = UIAlertController(title: "Traducido como ...", message: translatedText, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alert.addAction(okAction)
                self.controller!.present(alert, animated: true, completion: nil)
            }
        }
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
            
            
            knowledgeSourcePicker.addAction(UIAlertAction(title: "Inglés", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.showTranslationText(source: "es", target : "en", text : recognized)}))
                
            knowledgeSourcePicker.addAction(UIAlertAction(title: "Francés", style: UIAlertActionStyle.default, handler: {(alert: UIAlertAction!) in self.showTranslationText(source: "es", target : "fr", text : recognized)}))
                    
            self.present(knowledgeSourcePicker, animated: true)
            return
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
    
    func didTapVideo(cell: PostListCollectionCell) {
        guard let index = collectionView![cell]?.section,
            let post = presenter.post(at: index) else {
            return
        }
        
        setKnowledgeSource(at: index, withTalent: post.talent, withRecognized: post.reconocido)
    }
    
    
    func didTapShare(cell: PostListCollectionCell) {
        guard let index = collectionView![cell]?.section,
            let post = presenter.post(at: index) else {
                return
        }
        
        cell.toggleShare(share: post.isLiked) { [unowned self] in
            self.presenter.toggleShare(at: index)
        }
    }
    
    
    func didTapPhoto(cell: PostListCollectionCell) {
        guard let index = collectionView![cell]?.section else {
            return
        }
        
        presenter.likePost(at: index)
    }
    
    func didTapHeart(cell: PostListCollectionCell) {
        guard let index = collectionView![cell]?.section,
            let post = presenter.post(at: index) else {
                return
        }
        
        cell.toggleHeart(liked: post.isLiked) { [unowned self] in
            self.presenter.toggleLike(at: index)
        }
    }
    
    func didTapComment(cell: PostListCollectionCell) {
        guard let index = collectionView![cell]?.section else {
            return
        }
        
        presenter.presentCommentController(at: index, shouldComment: true)
    }
    
    func didTapCommentCount(cell: PostListCollectionCell) {
        guard let index = collectionView![cell]?.section else {
            return
        }
        
        presenter.presentCommentController(at: index)
    }
    
    func didTapLikeCount(cell: PostListCollectionCell) {
        guard let index = collectionView![cell]?.section else {
            return
        }
        
        presenter.presentPostLikes(at: index)
    }
    
    func didTapShareCount(cell: PostListCollectionCell) {
        guard let index = collectionView![cell]?.section else {
            return
        }
        
        presenter.presentPostShares(at: index)
    }
}

extension UserPostViewController {
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollHandler.isScrollable {
            if scrollHandler.isScrollingUp {
                scrollEventListener?.didScrollUp(
                    with: scrollHandler.offsetDelta,
                    offsetY: scrollHandler.currentOffsetY )
            } else if scrollHandler.isScrollingDown {
                scrollEventListener?.didScrollDown(
                    with: scrollHandler.offsetDelta,
                    offsetY: scrollHandler.currentOffsetY)
            }
            scrollHandler.update()
        }
    }
}
