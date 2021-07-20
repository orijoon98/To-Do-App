

import UIKit

class MemoTableViewController: UITableViewController {
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd."
        f.locale = Locale(identifier: "Ko_kr")
        f.timeZone = TimeZone(abbreviation: "KST")
        return f
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DataManager.shared.fetchMemo()
        tableView.reloadData()
    }
    
    var token: NSObjectProtocol?
    
    deinit {
        if let token = token {
            NotificationCenter.default.removeObserver(token)
        }
    }
    
    static var comMemo = [Memo]()
    static var incomMemo = [Memo]()
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) {
            if let vc = segue.destination as? DetailViewController {
                if indexPath.section == 0 {
                    vc.memo = MemoTableViewController.incomMemo[indexPath.row]
                }
                else {
                    vc.memo = MemoTableViewController.comMemo[indexPath.row]
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backBarButtonItem = UIBarButtonItem(title: "뒤로", style: .plain, target: self, action: nil)
        self.navigationItem.backBarButtonItem = backBarButtonItem
        
        token = NotificationCenter.default.addObserver(forName: ComposeViewController.newMemoDidInsert, object: nil, queue: OperationQueue.main) { [weak self] (noti) in self?.tableView.reloadData()
        }

    }
    
   
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            if MemoTableViewController.incomMemo.isEmpty { return "" }
            return "할 일"
        }
        else {
            if MemoTableViewController.comMemo.isEmpty { return "" }
            return "완료 목록"
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var complete: Int = 0
        var incomplete: Int = 0
        MemoTableViewController.comMemo.removeAll()
        MemoTableViewController.incomMemo.removeAll()
        for memo in DataManager.shared.memoList {
            if memo.completed == false {
                incomplete = incomplete + 1
                MemoTableViewController.incomMemo.append(memo)
            }
            else {
                complete = complete + 1
                MemoTableViewController.comMemo.append(memo)
            }
        }
        if section == 0 {
            return incomplete
        }
        
        else {
            return complete
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        if indexPath.section == 0 {
            let target = MemoTableViewController.incomMemo[indexPath.row]
            
            cell.textLabel?.text = target.content
            if formatter.string(for: target.startDate) == formatter.string(for: target.finishDate) {
                cell.detailTextLabel?.text = formatter.string(for: target.startDate)
            } else {
                cell.detailTextLabel?.text = "\(formatter.string(for: target.startDate) ?? "") - \(formatter.string(for: target.finishDate) ?? "")"
            }
        }
        
        else {
            let target = MemoTableViewController.comMemo[indexPath.row]
            
            cell.textLabel?.text = target.content
            if formatter.string(for: target.startDate) == formatter.string(for: target.finishDate) {
                cell.detailTextLabel?.text = formatter.string(for: target.startDate)
            } else {
                cell.detailTextLabel?.text = "\(formatter.string(for: target.startDate) ?? "") - \(formatter.string(for: target.finishDate) ?? "")"
            }
        }
        
        cell.textLabel?.font = UIFont .boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.font = UIFont .boldSystemFont(ofSize: 13)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            // 오른쪽에 만들기
        
        if(indexPath.section == 0) {
            
            let complete = UIContextualAction(style: .normal, title: "완료") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                let target = MemoTableViewController.incomMemo[indexPath.row]
                target.completed = true
                tableView.reloadData()
                success(true)
            }
            complete.backgroundColor = .systemBlue
                
                
            let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                let target = MemoTableViewController.incomMemo[indexPath.row]
                let index: Int = DataManager.shared.memoList.firstIndex(of: target)!
                DataManager.shared.deleteMemo(target)
                DataManager.shared.memoList.remove(at: index)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections(IndexSet(0...1) , with: .fade)
                success(true)
            }
            delete.backgroundColor = .systemRed
                
            
            return UISwipeActionsConfiguration(actions:[delete, complete])
                
        }
        
        else {
            let complete = UIContextualAction(style: .normal, title: "취소") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                let target = MemoTableViewController.comMemo[indexPath.row]
                target.completed = false
                tableView.reloadData()
                success(true)
            }
            complete.backgroundColor = .systemBlue
                
                
            let delete = UIContextualAction(style: .normal, title: "삭제") { (UIContextualAction, UIView, success: @escaping (Bool) -> Void) in
                let target = MemoTableViewController.comMemo[indexPath.row]
                let index: Int = DataManager.shared.memoList.firstIndex(of: target)!
                DataManager.shared.deleteMemo(target)
                DataManager.shared.memoList.remove(at: index)
                tableView.deleteRows(at: [indexPath], with: .fade)
                tableView.reloadSections(IndexSet(0...1) , with: .fade)
                success(true)
            }
            delete.backgroundColor = .systemRed
                
            
            return UISwipeActionsConfiguration(actions:[delete, complete])
        }
    }
    
}
