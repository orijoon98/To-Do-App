

import UIKit

class settingTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    var memo: Memo?
    var note: Noti?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        let alert = UIAlertController(title: "데이터 모두 지우기", message: "삭제된 데이터는 복구할 수 없습니다", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "삭제", style: .destructive) { (action) in
            for memo in DataManager.shared.memoList {
                DataManager.shared.deleteMemo(memo)
            }
            for note in notiDataManager.shared.memoList {
                notiDataManager.shared.deleteMemo(note)
            }
            DataManager.shared.memoList.removeAll()
            notiDataManager.shared.memoList.removeAll()
            MemoTableViewController.incomMemo.removeAll()
            MemoTableViewController.comMemo.removeAll()
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
