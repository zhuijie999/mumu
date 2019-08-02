//
//  MQWKWebCV.swift
//  MMQRCode
//
//  Created by yangjie on 2019/8/2.
//  Copyright © 2019 yangjie. All rights reserved.
//

import UIKit
import WebKit

class MQWKWebCV: MQBaseViewController {
    var _wkWebView: WKWebView?
    
    var loadingStr: String?
    
    lazy var supportLabel: UILabel = {
        let label = UILabel.labelWith(title: "", titleColor: UIColor.black, font: UIFont.systemFont(ofSize: 14), alignment: NSTextAlignment.center)
        label.mm_centerX = MQScreenWidth * 0.5
        label.mm_y = MQNavigationBarHeight + 10.0
        label.alpha = 0;
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        initSubViews()
        loadingUrl()
    }
    deinit {
        _wkWebView?.removeObserver(self, forKeyPath: "contentOffset")
    }
}

extension MQWKWebCV: MQViewLoadSubViewProtocol {
    func initSubViews() {
        _wkWebView = WKWebView(frame: view.bounds)
        _wkWebView?.uiDelegate = self
        _wkWebView?.navigationDelegate = self
        _wkWebView?.isOpaque = false
        _wkWebView?.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
//        _wkWebView?.scrollView.backgroundColor = UIColor.init(white: 0.0, alpha: 0.0)
        _wkWebView?.scrollView.addObserver(self, forKeyPath: "contentOffset", options: [.new], context: nil)
        _wkWebView?.scrollView.addObserver(self, forKeyPath: "estimatedProgress", options: [.new], context: nil)

        view.addSubview(_wkWebView!)
        
        let url = URL(string: loadingStr!)
        guard let tmpUrl = url else {
            MQPrintLog(message: "没找到")
            return
        }
        let str = "此网页由" + tmpUrl.host! + "提供"
        self.supportLabel.text = str
        self.supportLabel.sizeToFit()
        supportLabel.mm_centerX = MQScreenWidth * 0.5
        view.insertSubview(supportLabel, at: 0)
    }
}
extension MQWKWebCV {
    func loadingUrl() -> Void {
        if let str = loadingStr {
            let url = URL(string: str)
            let urlRequest: URLRequest = URLRequest(url: url!)
            _wkWebView?.load(urlRequest)
            
        } else {
            MQPrintLog(message: "字符串有误")
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let changes = change else {
            return
        }
        if keyPath == "contentOffset" {
            let newValue = changes[NSKeyValueChangeKey.newKey] as? CGPoint ?? CGPoint.zero
            let fitValue = newValue.y + MQNavigationBarHeight
            
            if  fitValue < 0 {
                let alpah = -fitValue / 60
                MQPrintLog(message: "alpha=\(alpah)")
                supportLabel.alpha = min(alpah, 1)
            } else {
                supportLabel.alpha = 0
            }
        } else if keyPath == "estimatedProgress" {
            let newValue = changes[NSKeyValueChangeKey.newKey] as? Double ?? 0
            
        }
    }
}
extension MQWKWebCV: WKUIDelegate {
    
}
extension MQWKWebCV: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        MQPrintLog(message: "startLoading")
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let title = webView.title {
            self.navigationItem.title = title
        }
    }
}

