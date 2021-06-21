//  DataManager.swift
//  ONEMORE
//
//  Created by 공혁준 on 2021/05/01.
//

import Foundation
import CoreData

class notiDataManager {
    static let shared = notiDataManager()
    private init() {
        
    }
    
    var mainContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    var memoList = [Noti]()
    
    func fetchMemo() {
        let request: NSFetchRequest<Noti> = Noti.fetchRequest()
        
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
        request.sortDescriptors = [sortByDateDesc]
        
        do {
            memoList = try mainContext.fetch(request)
        } catch {
            print(error)
        }
    }
    
    func addNewMemo(_ memo: String?) {
        let newMemo = Noti(context: mainContext)
        newMemo.content = memo
        newMemo.insertDate = notiComposeViewController.insertDate
        newMemo.insertTime = notiComposeViewController.insertTime
        
        memoList.insert(newMemo, at: 0)
        
        saveContext()
    }
    
    func deleteMemo(_ memo: Noti?) {
        if let memo = memo {
            mainContext.delete(memo)
            saveContext()
        }
    }
    
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ONEMORE")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
