

import UIKit

class notiComposeViewController: UIViewController {
    
    
    @IBOutlet weak var leftButton: UIBarButtonItem!
    
    @IBOutlet weak var rightButton: UIBarButtonItem!
    
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy.MM.dd."
        f.locale = Locale(identifier: "Ko_kr")
        return f
    }()
    
    let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "Ko_kr")
        f.dateFormat = "a h:mm"
        return f
    }()
    
    var editTarget: Noti?
    var originalMemoContent: String?
    
    static var insertDate: Date?
    static var insertTime: Date?
    
    
    @IBOutlet weak var dateOutlet: UIDatePicker!

    @IBOutlet weak var timeOutlet: UIDatePicker!
    
    @IBAction func setDate(_ sender: UIDatePicker) {
        let datePickerView = sender // 상수 선언, sender로 날짜가 보내짐
        notiComposeViewController.insertDate = datePickerView.date
    }

    @IBAction func setTime(_ sender: UIDatePicker) {
        let datePickerView = sender
        notiComposeViewController.insertTime = datePickerView.date
    }
    
    @IBOutlet weak var memoTextView: UITextView!
    
    @IBAction func close(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let memo = memoTextView.text,
            memo.count > 0 else {
            alert(message: "메모를 입력하세요")
            return
        }
        
        if let target = editTarget {
            target.content = memo
            target.insertDate = notiComposeViewController.insertDate
            target.insertTime = notiComposeViewController.insertTime
            notiDataManager.shared.saveContext()
            NotificationCenter.default.post(name: notiComposeViewController.memoDidChange, object: nil)
        } else {
            notiDataManager.shared.addNewMemo(memo)
            NotificationCenter.default.post(name: notiComposeViewController.newMemoDidInsert, object: nil)
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
            navigationItem.title = "알림 편집"
            memoTextView.text = memo.content
            originalMemoContent = memo.content
            notiComposeViewController.insertDate = memo.insertDate
            notiComposeViewController.insertTime = memo.insertTime
            dateOutlet.setDate(memo.insertDate!, animated: false)
            timeOutlet.setDate(memo.insertTime!, animated: false)
        } else { // 새 메모
            navigationItem.title = "새 알림"
            memoTextView.text = ""
            notiComposeViewController.insertDate = Date()
            notiComposeViewController.insertTime = Date()
            dateOutlet.setDate(Date(), animated: false)
            timeOutlet.setDate(Date(), animated: false)
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

extension notiComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        if let original = originalMemoContent, let edited = textView.text {
            if #available(iOS 13.0, *) {
                isModalInPresentation = original != edited
            } else {
                
            }
        }
    }
}


extension notiComposeViewController: UIAdaptivePresentationControllerDelegate {
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

extension notiComposeViewController {
    static let newMemoDidInsert = Notification.Name(rawValue: "newMemoDidInsert")
    static let memoDidChange = Notification.Name(rawValue: "memoDidChange")
}
