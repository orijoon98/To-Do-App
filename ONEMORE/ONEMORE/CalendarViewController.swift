//
//  CalendarViewController.swift
//  ONEMORE
//
//  Created by 공혁준 on 2021/05/03.
//

import UIKit
import FSCalendar

class CalendarViewController: UIViewController {
    
    
    @IBOutlet weak var calendar: FSCalendar!
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.headerMinimumDissolvedAlpha = 0
        calendar.delegate = self
        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension CalendarViewController: FSCalendarDelegate{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print(formatter.string(from: date))//선택된 날짜 넘겨서 table view reload하기
        //tableView.reloadData()
        
    }
}

extension CalendarViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.memoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "calendarCell", for: indexPath)

        let target = DataManager.shared.memoList[indexPath.row]
        cell.textLabel?.text = target.content
        if formatter.string(for: target.startDate) == formatter.string(for: target.finishDate) {
            cell.detailTextLabel?.text = formatter.string(for: target.startDate)
        } else {
            cell.detailTextLabel?.text = "\(formatter.string(for: target.startDate) ?? "") - \(formatter.string(for: target.finishDate) ?? "")"
        }
        
        return cell
    }
}
