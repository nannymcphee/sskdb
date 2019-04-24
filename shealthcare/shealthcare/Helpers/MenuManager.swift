//
//  MenuManager.swift
//  shealthcare
//
//  Created by Nguyên Duy on 4/20/19.
//  Copyright © 2019 shealthcare. All rights reserved.
//

import Foundation

class MenuManager: UserDefaults {
    private static var menuManager: MenuManager = {
        let cacheManager = MenuManager()
        return cacheManager
    }()
    
    private let defaults = UserDefaults.standard
    private let cacheKey = "menu_item_cache_key"
    
    //MARK: - ACCESSOR
    class func shared() -> MenuManager {
        return menuManager
    }
    
    //MARK: - SAVE NEW LIST
    func save(_ items: [MenuItem]) {
        removeAll()
        // Save new list
        do {
            if #available(iOS 11.0, *) {
                let data = try NSKeyedArchiver.archivedData(withRootObject: items, requiringSecureCoding: false)
                defaults.set(data, forKey: cacheKey)
            } else {
                // Fallback on earlier versions
                let data = NSKeyedArchiver.archivedData(withRootObject: items)
                defaults.set(data, forKey: cacheKey)
            }
        } catch {
            print("Cannot archive items to data")
        }
    }
    
    //MARK: - SAVE ITEM
    func save(_ item: MenuItem) {
        var items = [MenuItem]()
        
        if let cachedItems = getAll() {
            // Only save new items
            // To prevent duplicate data
            if isSaved(item) == false {
                items = cachedItems
                items.append(item)
                // Save new list
                save(items)
                
            }
        } else {
            // Create and save new list
            items.append(item)
            
            do {
                if #available(iOS 11.0, *) {
                    let data = try NSKeyedArchiver.archivedData(withRootObject: items, requiringSecureCoding: false)
                    defaults.set(data, forKey: cacheKey)
                } else {
                    // Fallback on earlier versions
                    let data = NSKeyedArchiver.archivedData(withRootObject: items)
                    defaults.set(data, forKey: cacheKey)
                    defaults.synchronize()
                }
            } catch {
                print("Error saving to favorite: Cannot archive favorite words to data")
            }
            
        }
    }
    
    //MARK: - GET FAVORITE
    func getAll() -> [MenuItem]? {
        guard let data = defaults.object(forKey: cacheKey) as? NSData else {
            // Items not found in UserDefaults
            return [MenuItem]()
        }
        
        do {
            if #available(iOS 11.0, *) {
                guard let savedItems = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data as Data) as? [MenuItem] else {
                    print("Error getting favorite: Cannot unarchive favorite word's data")
                    return [MenuItem]()
                }
                return savedItems
            } else {
                let savedItems = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as? [MenuItem]
                return savedItems
            }
        } catch {
            print("Error getting items: Cannot unarchive items' data")
        }
        
        return [MenuItem]()
    }
    
    //MARK: - REMOVE FAVORITE
    func remove(_ item: MenuItem) {
        var itemsToSave: [MenuItem] = []
        
        if let savedItems = getAll() {
            itemsToSave = savedItems
            
            if let index = getIndex(of: item) {
                itemsToSave.remove(at: index)
                save(itemsToSave)
            }
        } else {
            print("Error removing item: Item not found")
        }
    }
    
    //MARK: - REMOVE ALL CACHED ITEMS
    func removeAll() {
        if defaults.value(forKey: cacheKey) != nil {
            defaults.removeObject(forKey: cacheKey)
        }
    }
    
    //MARK: - CHECK IS SAVED
    func isSaved(_ item: MenuItem) -> Bool {
        return getIndex(of: item) != nil ? true : false
    }
    
    //MARK: - GET INDEX
    func getIndex(of word: MenuItem) -> Int? {
        if let items = getAll() {
            return items.index(where: { $0.name == word.name }) ?? nil
        } else {
            return nil
        }
    }
}


