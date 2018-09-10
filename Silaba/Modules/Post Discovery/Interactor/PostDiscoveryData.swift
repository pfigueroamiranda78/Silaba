//
//  PostDiscoveryData.swift
//  Photostream
//
//  Created by Mounir Ybanez on 20/12/2016.
//  Copyright © 2016 Mounir Ybanez. All rights reserved.
//

protocol PostDiscoveryData {
    
    var id: String { set get }
    var message: String { set get }
    var timestamp: Double { set get }
    
    var photoUrl: String { set get }
    var photoWidth: Int { set get }
    var photoHeight: Int { set get }
    
    var likes: Int { set get }
    var comments: Int { set get }
    var isLiked: Bool { set get }
    var shares: Int { set get }
    var isShared: Bool { set get }
    var isVideo: Bool { set get }
    
    var userId: String { set get }
    var avatarUrl: String { set get }
    var displayName: String { set get }
    
    var identifier: String { set get }
    var confidence: Float { set get }
    var recognized_type: String { set get }
    var talent: Talent { set get }
}

struct PostDiscoveryDataItem: PostDiscoveryData {
    
    var id: String = ""
    var message: String = ""
    var timestamp: Double = 0
    
    var photoUrl: String = ""
    var photoWidth: Int = 0
    var photoHeight: Int = 0
    
    var likes: Int = 0
    var comments: Int = 0
    var isLiked: Bool = false
    
    var shares: Int = 0
    var isShared: Bool = false
    var isVideo: Bool = false
    
    var userId: String = ""
    var avatarUrl: String = ""
    var displayName: String = ""
    
    var identifier: String = ""
    var confidence: Float = 0
    var recognized_type: String = ""
    var talent: Talent = Talent()
}

extension PostDiscoveryData {
    
    func isTalentInList(withTalent talent: Talent, ofTalentList talentList: TalentList)-> Bool {
        for the_talent in talentList.talents {
            if (the_talent.id == talent.id) {
                return true
            }
        }
        return false
    }
    
    func getTalentList(withPostDiscoveryData thPostDiscoveryData :[PostDiscoveryData])-> TalentList {
        var result = TalentList()
        for the_post in thPostDiscoveryData {
            let the_talent = the_post.talent
            if (!isTalentInList(withTalent: the_talent, ofTalentList: result)) {
                result.talents.append(the_talent)
            }
        }
        
        return result
    }
    
    func getByTalent(withPostDiscoveryData thPostDiscoveryData :[PostDiscoveryData], ofTalent talent:Talent)-> [PostDiscoveryData] {
        var result = [PostDiscoveryData]()
        
        for the_post in thPostDiscoveryData {
            let the_talent = the_post.talent
            if (the_talent.id == talent.id) {
                result.append(the_post)
            }
        }
        
        return result
    }
}
