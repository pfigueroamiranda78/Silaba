//
//  PostDiscoveryViewDataSource.swift
//  Photostream
//
//  Created by Mounir Ybanez on 20/12/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

import UIKit

extension PostDiscoveryViewController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        switch sceneType {
        case .grid:
            //return 1
            return presenter.sectionCount
            
        case .list:
            return presenter.postCount
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sceneType {
        case .grid:
            if section == presenter.sectionCount - 1 {
                return presenter.postCount
            } else {
                return presenter.RecommendedPostCount(at: section)
            }
            
        case .list:
            return 1
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let section: Int = indexPath.section
        switch sceneType {
        case .grid:
            if section == presenter.sectionCount - 1 {
                let cell = PostGridCollectionCell.dequeue(from: collectionView, for: indexPath)!
                let item = presenter.post(at: indexPath.row) as? PostGridCollectionCellItem
                cell.configure(with: item)
                return cell
            } else {
                let cell = PostGridCollectionCell.dequeue(from: collectionView, for: indexPath)!
                let item = presenter.RecommendedPost(at: indexPath.row, at: section) as? PostGridCollectionCellItem
                cell.configure(with: item)
                return cell
            }
            
            
        case .list:
            let cell = PostListCollectionCell.dequeue(from: collectionView, for: indexPath)!
            let item = presenter.post(at: indexPath.section) as? PostListCollectionCellItem
            cell.configure(with: item)
            cell.delegate = self
            return cell
        }
    }
    

    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let section: Int = indexPath.section
        switch kind {
        case UICollectionElementKindSectionHeader where sceneType == .list:
            let header = PostListCollectionHeader.dequeue(from: collectionView, for: indexPath)!
            let item = presenter.post(at: indexPath.section) as? PostListCollectionHeaderItem
            header.configure(with: item)
            header.delegate = self
            return header
            
        default:
            if (section == presenter.sectionCount - 1) {
                let header = PostListCollectionHeader.dequeue(from: collectionView, for: indexPath)!
                header.displayNameLabel.text = "Resultados de tu búsqueda"
                return header
            } else {
                let header = PostListCollectionHeader.dequeue(from: collectionView, for: indexPath)!
                let section = indexPath.section
               
                header.displayNameLabel.text = "Sugerencias para ti en "+presenter.sectionName(at: section)!
                return header
            }
            //return UICollectionReusableView()
        }
    }
}
