//
//  GYInputBox.swift
//  GYInputBoxDemo
//
//  Created by y g on 2020/12/19.
//

import UIKit
import SnapKit

public protocol GYSearchBarDelegate {
    
    /// 返回补全富文本内容
    /// - Parameter index: 下标
    func attributedTextForIndex(index:Int) -> NSAttributedString
}

public class GYInputBox: UIView {
    
    /// 代理
    public  var delegate:GYSearchBarDelegate?
    
    /// 输入框文本发生改变事件
    public var searchTextDidChange:((String) -> ())!
    
    /// 选中某个补全文本事件
    public var didSelectIndex:((Int) -> ())!
    
    /// 输入框文本内容
    public var text: String {
        get {
            return onEditingText ?? ""
        }
        set {
            searBarField.text = newValue
        }
    }
    
    /// 自动补全的数据源
    public var dataSouce:NSArray! = [] {
        didSet{
            self.tableView.reloadData()
            resetConstraint()
        }
    }
    
    
    /// 私有属性
    fileprivate var searBarField:UITextField!
    fileprivate var tableView:UITableView!
    fileprivate var placeholder:String!
    fileprivate var onEditingText:String!//正在编辑的文本
    private var delegateImpl: GYInputBoxDelegateImpl?
    
    public convenience init(placeholder: String, frame: CGRect) {
        self.init(frame: frame)
        self.placeholder = placeholder
        delegateImpl = GYInputBoxDelegateImpl(target: self)
        setupViews()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startEditing () {
        searBarField.becomeFirstResponder()
    }
    
    public func endEditing () {
        searBarField.resignFirstResponder()
    }
    
    fileprivate func setupViews() {
        searBarField = UITextField()
        searBarField.layer.cornerRadius = 4;
        searBarField.delegate = delegateImpl
        searBarField.layer.borderColor = UIColor.lightGray.cgColor
        searBarField.layer.borderWidth = 1.0
        let leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 18, height: 0))
        searBarField.leftView = leftView
        searBarField.leftViewMode = .always
        searBarField.clearButtonMode = .whileEditing
        searBarField.placeholder = placeholder
        self.addSubview(searBarField)
        searBarField.snp.makeConstraints({ (make) in
            make.height.equalTo(35)
            make.margins.equalTo(UIEdgeInsets.init(top: 2, left: 2, bottom: 2, right: 2));
        })
        
        tableView = UITableView.init(frame: CGRect.zero, style: .plain)
        tableView.delegate = delegateImpl
        tableView.dataSource = delegateImpl
        tableView.separatorStyle = .none
        tableView.layer.cornerRadius = 4;
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.layer.borderWidth = 1.0
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "id")
        self.addSubview(tableView)
    }
    
    fileprivate func resetConstraint() {
        searBarField.snp.remakeConstraints { (make) in
            make.height.equalTo(35)
            make.left.top.equalTo(2);
            make.right.equalTo(-2);
        }
        let height:CGFloat = 40.0 * CGFloat((dataSouce.count > 4 ? 4 : dataSouce.count))
        tableView.snp.remakeConstraints { (make) in
            make.height.equalTo(height)
            make.top.equalTo(searBarField.snp.bottom).offset(2)
            make.left.equalTo(2);
            make.right.bottom.equalTo(-2);
        }
    }
}

//隐藏内部实现协议
private class GYInputBoxDelegateImpl: NSObject,UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    private weak var target: GYInputBox!

        init(target: GYInputBox) {
            self.target = target
            super.init()
        }
    
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return target.dataSouce.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "id", for: indexPath)
        cell.textLabel?.attributedText = target.delegate?.attributedTextForIndex(index: indexPath.row)
        return cell
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0;
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (target.didSelectIndex != nil) {
            target.didSelectIndex(indexPath.row)
        }
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if (target.searchTextDidChange != nil) {
            target.onEditingText = ""
            target.searchTextDidChange(target.onEditingText)
        }
        return true
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        if (target.searchTextDidChange != nil) {
            target.onEditingText = newText
            target.searchTextDidChange(target.onEditingText)
        }
        return true
    }
}

