import UIKit
import WebKit

class ViewController: UIViewController {
    
    var webView: WKWebView!
    var progressView: UIProgressView!
    var websites = ["google.com", "apple.com", "ya.ru"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openYaUrl()
        showtoolbarItems()
        openPage()
    }
    
    func openYaUrl() {
        let url = URL(string: "https://" + websites[0])!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    func openPage() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Open", style: .plain, target: self, action: #selector(openTapped))
    }
    
    @objc func openTapped() {
        let ac = UIAlertController(title: "Open page...", message: nil, preferredStyle: .actionSheet)
        for website in websites {
            ac.addAction(UIAlertAction(title: website, style: .default, handler: openPage))
        }
        ac.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: openPage))
        
        ac.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(ac, animated: true)
    }
    
    func openPage(action: UIAlertAction) {
        guard let actionTitle = action.title else { return }
        guard let url = URL(string: "https://" + actionTitle) else { return }
        webView.load(URLRequest(url: url))
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        title = webView.title
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress" {
            progressView.progress = Float(webView.estimatedProgress)
        }
        
    }
    func showtoolbarItems(){
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil) //пространство между элементами
        let refresh = UIBarButtonItem(barButtonSystemItem: .refresh, target: webView, action: #selector(webView.reload)) //кнопка рефреша
        
        //добавляем в тулбар индикатор прогреса без заполнения (отслеживание прогресса)
        progressView = UIProgressView(progressViewStyle: .default)
        progressView.sizeToFit()
        let progressButton = UIBarButtonItem(customView: progressView)
        
        //заполняемый индикатор прогресса в нижнем тулбаре
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        
        //возврат к предыдущей странице
        let back = UIBarButtonItem(barButtonSystemItem: .rewind, target: webView, action: #selector(webView.goBack))
        let forwardd = UIBarButtonItem(barButtonSystemItem: .fastForward, target: webView, action: #selector(webView.goForward))
        
        toolbarItems = [back, forwardd, spacer, progressButton, spacer, refresh ]
        navigationController?.isToolbarHidden = false
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url

        if let host = url?.host {
            for website in websites {
                if host.contains(website) {
                    decisionHandler(.allow)
                    return
                }
            }
        } else {
            //TODO: алерт с уведомлением
//            alertForbidden()
            print("forbidden")
        }
        decisionHandler(.cancel)
    }
    
//    func alertForbidden() {
//        let ac = UIAlertController(title: "decidePolicy", message: "forbidden", preferredStyle: .alert)
//        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//    }
}

extension ViewController: WKNavigationDelegate{
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
}
