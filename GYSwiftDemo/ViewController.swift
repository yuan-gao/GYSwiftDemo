//
//  ViewController.swift
//  GYSwiftDemo
//
//  Created by y g on 2020/12/17.
//

import UIKit
import SnapKit
import GYInputBox
import GYNetworkTool

class ViewController: UIViewController,GYSearchBarDelegate {
    
    var searchBar:GYInputBox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        setupViews()
    }

    func setupViews()  {
        
        searchBar = GYInputBox.init(placeholder: "搜索", frame: CGRect.zero)
        self.view.addSubview(searchBar)
        searchBar.delegate = self
        searchBar.startEditing()
        searchBar.snp.makeConstraints { (make) in
            make.left.right.equalTo(0)
            make.top.equalTo(88)
        }
        searchBar.searchTextDidChange = {
            (str:String) -> ()
            in
            self.searchRequest(keyword: str as NSString)
        }
        
        searchBar.didSelectIndex = {
            [unowned self] (index:Int) -> () in
            let dic = self.searchBar.dataSouce[index] as! NSDictionary
            let cont = dic["cont"] as! String
            self.searchBar.text = cont
            self.searchBar.dataSouce = []
        }
        
        self.view.bringSubviewToFront(searchBar)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.searchBar.endEditing();
    }

    
    //MARK:- request
    func searchRequest(keyword:NSString) {
        if keyword.length == 0 {
            searchBar.dataSouce = []
            return
        }
        let safeURL = "http://suggest.lagou.com/home/\(keyword)/180100000/10".addingPercentEncoding(withAllowedCharacters:.urlQueryAllowed)
        NSObject.get(with: safeURL!) { (json, string, data) in
            let COMPANY = json?["COMPANY"] ?? []
            self.searchBar.dataSouce = COMPANY as? NSArray
        } failure: { (error) in
            print(error ?? "")
        }
    }
    
    //MARK:- GYSearchBar delegate
    func attributedTextForIndex(index: Int) -> NSAttributedString {
        if index<searchBar.dataSouce.count {
            let dic = self.searchBar.dataSouce[index] as! NSDictionary
            let cont = dic["cont"] as! String
            let text = searchBar.text
            let ns_rangs = cont.nsRanges(of: text)
            let attrStr = NSMutableAttributedString.init(string: cont)
            for ns_rang in ns_rangs {
                attrStr.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.init(red: 71.0/255, green: 183.0/255, blue: 46.0/255, alpha: 1.0), range:ns_rang)
            }
            return attrStr
        }
        return NSAttributedString.init(string: "")
    }

}

//MARK:- extension

extension RangeExpression where Bound == String.Index  {
    func nsRange<S: StringProtocol>(in string: S) -> NSRange { .init(self, in: string) }
}

extension StringProtocol {
    func nsRange<S: StringProtocol>(of string: S, options: String.CompareOptions = [], range: Range<Index>? = nil, locale: Locale? = nil) -> NSRange? {
        self.range(of: string,
                   options: options,
                   range: range ?? startIndex..<endIndex,
                   locale: locale ?? .current)?
            .nsRange(in: self)
    }
    func nsRanges<S: StringProtocol>(of string: S, options: String.CompareOptions = [], range: Range<Index>? = nil, locale: Locale? = nil) -> [NSRange] {
        var start = range?.lowerBound ?? startIndex
        let end = range?.upperBound ?? endIndex
        var ranges: [NSRange] = []
        while start < end,
            let range = self.range(of: string,
                                   options: options,
                                   range: start..<end,
                                   locale: locale ?? .current) {
            ranges.append(range.nsRange(in: self))
            start = range.lowerBound < range.upperBound ? range.upperBound :
            index(range.lowerBound, offsetBy: 1, limitedBy: endIndex) ?? endIndex
        }
        return ranges
    }
}
