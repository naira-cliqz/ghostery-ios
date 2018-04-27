//
//  DomainStore.swift
//  Client
//
//  Created by Tim Palade on 4/23/18.
//  Copyright © 2018 Cliqz. All rights reserved.
//

import Foundation
import RealmSwift

class Domain: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var state: Int = 0 //0 none, 1 trusted, 2 restricted
    var trustedTrackers = List<Int>()
    var restrictedTrackers = List<Int>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
    var translatedState: DomainState {
        switch state {
        case 0:
            return .none
        case 1:
            return .trusted
        case 2:
            return .restricted
        default:
            return .none
        }
    }
}

enum DomainState {
    case none
    case trusted
    case restricted
}

enum ListType {
    case trustedList
    case restrictedList
}

class DomainStore: NSObject {
    
    class func get(domain: String) -> Domain? {
        let realm = try! Realm()
        if let domain = realm.object(ofType: Domain.self, forPrimaryKey: domain) {
            return domain
        }
        return nil
    }
    
    class func create(domain: String) -> Domain {
        let realm = try! Realm()
        let domainObj = Domain()
        domainObj.name = domain
        
        try! realm.write {
            realm.add(domainObj)
        }
        
        return domainObj
    }
    
    class func changeState(domain: Domain, state: DomainState) {
        
        let realm = try! Realm()
        do {
            try realm.write {
                domain.state = intForState(state: state)
                realm.add(domain, update: true)
            }
        }
        catch {
            debugPrint("could not change state of domain")
        }
    }
    
    class func add(appId: Int, domain: Domain, list: ListType) {
        
        let realm = try! Realm()
        do {
            try realm.write {
                
                if list == .trustedList {
                    domain.trustedTrackers.append(appId)
                }
                else if list == .restrictedList {
                    domain.restrictedTrackers.append(appId)
                }
                
                realm.add(domain, update: true)
            }
        }
        catch {
            debugPrint("could not add appId = \(appId) to list = \(list) of domain = \(domain.name)")
        }
    }
    
    class func remove(appId: Int, domain: Domain, list: ListType) {
        
        let realm = try! Realm()
        do {
            try realm.write {
                
                if list == .trustedList {
                    domain.trustedTrackers.remove(element: appId)
                }
                else if list == .restrictedList {
                    domain.restrictedTrackers.remove(element: appId)
                }
                
                realm.add(domain, update: true)
            }
        }
        catch {
            debugPrint("could not add appId = \(appId) to list = \(list) of domain = \(domain.name)")
        }
    }
    
    private class func intForState(state: DomainState) -> Int {
        switch state {
        case .none:
            return 0
        case .trusted:
            return 1
        case .restricted:
            return 2
        }
    }
}

extension List where Element: Comparable {
    func remove(element: Element) {
        for i in 0..<self.elements.count {
            let item = self[i]
            if item == element {
                self.remove(at: i)
            }
        }
    }
}