
import UIKit
import FSCalendar

class CalendarViewController: UIViewController {

    @IBOutlet weak var calendar: FSCalendar!
    
    @IBOutlet weak var tableView: UITableView!
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd."
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    var events: [Date] = []
    var selectedDate: Date?
    
    var memo: Memo?
    var memoByDate = [Memo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.delegate = self
        calendar.dataSource = self
        selectedDate = Date()
        for memo in DataManager.shared.memoList {
            if ableDate(memo.startDate!, selectedDate!, memo.finishDate!) {
                memoByDate.append(memo)
            }
        }
        tableView.dataSource = self
        tableView.reloadData()
    }
    
    func setUpEvents() {
        if(!MemoTableViewController.incomMemo.isEmpty){
            for memo in MemoTableViewController.incomMemo {
                var today: Date = formatter.date(from: formatter.string(from: memo.startDate!))!
                var tomorrow: Date
                while true {
                    let compareDate: Date = formatter.date(from: formatter.string(from: memo.finishDate!))!
                    if ComposeViewController.compareDate(a: today, b: compareDate) == -1 {
                        break
                    }
                    events.append(today)
                    tomorrow = Date(timeInterval: 86400, since: today)
                    today = tomorrow
                }
            }
        }
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate, FSCalendarDataSource{
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedDate = Date()
        memoByDate.removeAll()
        events.removeAll()
        if !MemoTableViewController.incomMemo.isEmpty {
            for memo in MemoTableViewController.incomMemo {
                if ableDate(memo.startDate!, selectedDate!, memo.finishDate!) {
                    memoByDate.append(memo)
                }
            }
        }
        tableView.reloadData()
        setUpEvents()
        calendar.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        
        if self.events.contains(date){
            return 1
        }
        return 0
    }
    
    
    func ableDate(_ startDate: Date, _ targetDate: Date, _ finishDate: Date) -> Bool {
        let x: Date = formatter.date(from: formatter.string(from: startDate))!
        let y: Date = formatter.date(from: formatter.string(from: targetDate))!
        let z: Date = formatter.date(from: formatter.string(from: finishDate))!
        if ComposeViewController.compareDate(a: x, b: y) == -1 {
            return false
        }
        if ComposeViewController.compareDate(a: y, b: z) == -1 {
            return false
        }
        return true
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        memoByDate.removeAll()
        
        selectedDate = date
        
        for memo in MemoTableViewController.incomMemo {
            if ableDate(memo.startDate!, selectedDate!, memo.finishDate!) {
                memoByDate.append(memo)
            }
        }
        
        tableView.reloadData()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoByDate.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        let target = memoByDate[indexPath.row]
        cell.textLabel?.text = target.content
        if formatter.string(for: target.startDate) == formatter.string(for: target.finishDate) {
            cell.detailTextLabel?.text = formatter.string(for: target.startDate)
        } else {
            cell.detailTextLabel?.text = "\(formatter.string(for: target.startDate) ?? "") - \(formatter.string(for: target.finishDate) ?? "")"
        }
        
        cell.textLabel?.font = UIFont .boldSystemFont(ofSize: 17)
        cell.detailTextLabel?.font = UIFont .boldSystemFont(ofSize: 13)
        
        return cell
    }
    
}
