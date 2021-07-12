

import UIKit

class ComposeViewController: UIViewController {
    
    @IBOutlet weak var leftButton: UIBarButtonItem!
    
    @IBOutlet weak var rightButton: UIBarButtonItem!
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd."
        f.locale = Locale(identifier: "Ko_kr")
        f.timeZone = TimeZone(abbreviation: "KST")
        return f
    }()
    
    var editTarget: Memo?
    var originalMemoContent: String?
    
    static var startingDate: Date?
    static var finishingDate: Date?
    
    static func compareDate(a: Date, b: Date) -> Int {
        switch a.compare(b) {
        case .orderedAscending:
            return 1
        case .orderedDescending:
            return -1
        default:
            return 0
        }
    }
    
    @IBOutlet weak var startDateOutlet: UIDatePicker!

    @IBOutlet weak var finishDateOutlet: UIDatePicker!
    
    @IBAction func startDate(_ sender: UIDatePicker) {
        let startDatePickerView = sender // 상수 선언, sender로 날짜가 보내짐
        ComposeViewController.startingDate = startDatePickerView.date
    }

    @IBAction func finishDate(_ sender: UIDatePicker) {
        let finishDatePickerView = sender
        ComposeViewController.finishingDate = finishDatePickerView.date
    }
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBAction func save(_ sender: Any) {
        guard let memo = memoTextView.text,
            memo.count > 0 else {
            alert(message: "메모를 입력하세요")
            return
        }
        
        guard let sta = ComposeViewController.startingDate, let fin = ComposeViewController.finishingDate, ComposeViewController.compareDate(a: sta, b: fin) >= 0 else {
            alert(message: "날짜를 재설정하세요")
            return
        }
        
        if let target = editTarget {
            target.content = memo
            target.startDate = ComposeViewController.startingDate
            target.finishDate = ComposeViewController.finishingDate
            DataManager.shared.saveContext()
            NotificationCenter.default.post(name: ComposeViewController.memoDidChange, object: nil)
        } else {
            DataManager.shared.addNewMemo(memo)
            NotificationCenter.default.post(name: ComposeViewController.newMemoDidInsert, object: nil)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    var willShowToken: NSObjectProtocol?
    var willHideToken: NSObjectProtocol?
    
    deinit {
        if let token = willShowToken {
            NotificationCenter.default.removeObserver(token)
        }
        
        if let token = willHideToken {
            NotificationCenter.default.removeObserver(token)
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let memo = editTarget {
            navigationItem.title = "메모 편집"
            memoTextView.text = memo.content
            originalMemoContent = memo.content
            ComposeViewController.startingDate = memo.startDate
            ComposeViewController.finishingDate = memo.finishDate
            startDateOutlet.setDate(memo.startDate!, animated: false)
            finishDateOutlet.setDate(memo.finishDate!, animated: false)
        } else { // 새 메모
            navigationItem.title = "새 메모"
            memoTextView.text = ""
            ComposeViewController.startingDate = Date()
            ComposeViewController.finishingDate = Date()
            startDateOutlet.setDate(Date(), animated: false)
            finishDateOutlet.setDate(Date(), animated: false)
        }
        
        let leftBarButton = leftButton
        leftBarButton?.title = "취소"
        navigationItem.leftBarButtonItem = leftBarButton
        
        let rightBarButton = rightButton
        rightBarButton?.title = "저장"
        navigationItem.rightBarButtonItem = rightBarButton
        
        memoTextView.delegate = self
        
        willShowToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let strongSelf = self else { return }
            
            if let frame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as?
                NSValue {
                let height = frame.cgRectValue.height
                
                var inset = strongSelf.memoTextView.contentInset
                inset.bottom = height
                strongSelf.memoTextView.contentInset = inset
                
                inset = strongSelf.memoTextView.scrollIndicatorInsets
                inset.bottom = height
                strongSelf.memoTextView.scrollIndicatorInsets = inset
            }
        })
        
        
        willHideToken = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: OperationQueue.main, using: { [weak self] (noti) in
            guard let strongSelf = self else { return }
            
            var inset = strongSelf.memoTextView.contentInset
            inset.bottom = 0
            strongSelf.memoTextView.contentInset = inset
            
            inset = strongSelf.memoTextView.scrollIndicatorInsets
            inset.bottom = 0
            strongSelf.memoTextView.scrollIndicatorInsets = inset
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        memoTextView.becomeFirstResponder()
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        memoTextView.resignFirstResponder()
        navigationController?.presentationController?.delegate = nil
    }

}

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let original = originalMemoContent, let edited = textView.text {
            if #available(iOS 13.0, *) {
                isModalInPresentation = original != edited
            } else {
                
            }
        }
    }
}


extension ComposeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        let alert = UIAlertController(title: "알림", message: "편집한 내용을 저장할까요?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] (action) in self?.save(action)
        }
        alert.addAction(okAction)
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) { [weak self] (action) in self?.close(action)
        }
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
}

extension ComposeViewController {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}
