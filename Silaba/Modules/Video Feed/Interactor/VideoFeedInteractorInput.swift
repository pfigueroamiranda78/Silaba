//
//  VideoFeedInteractorInput.swift
//  Silaba
//
//  Created by Pedro Pablo Figueroa Miranda on 30/04/18.
//  Copyright © 2018 Silaba. All rights reserved.
//

import Foundation

protocol VideoFeedInteractorInput: BaseModuleInteractorInput {
    
    func fetchNew(with postId: String, withTalent talentSource: Talent, withKnowledge: knowledgeSource, and limit: UInt)
    func fetchNext(with postId: String, withTalent talentSource: Talent, withKnowledge: knowledgeSource, and limit: UInt)
}
