
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
    

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "ONEMORE")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
