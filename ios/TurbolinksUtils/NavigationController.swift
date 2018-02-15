import WebKit
import Turbolinks

class NavigationController: UINavigationController {
    
    var session: Session!
    
    required convenience init(_ manager: RNTurbolinksManager,_ route: Dictionary<AnyHashable, Any>?) {
        self.init()
        
        let webViewConfiguration = WKWebViewConfiguration()
        webViewConfiguration.processPool = manager.processPool
        if (manager.messageHandler != nil) { webViewConfiguration.userContentController.add(manager, name: manager.messageHandler!) }
        if (manager.userAgent != nil) { webViewConfiguration.applicationNameForUserAgent = manager.userAgent }
        
        self.session = Session(webViewConfiguration: webViewConfiguration)
        self.session.delegate = manager
        self.session.webView.uiDelegate = self
        
        if (route != nil) {
            let tRoute = TurbolinksRoute(route!)
            self.tabBarItem = UITabBarItem(title: tRoute.tabTitle , image: tRoute.tabIcon, selectedImage: tRoute.tabIcon)
        }
    }
}

extension NavigationController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let bundle = Bundle(identifier: "com.apple.UIKit")!
        let confirm = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancel = bundle.localizedString(forKey: "Cancel", value: nil, table: nil)
        let ok = bundle.localizedString(forKey: "OK", value: nil, table: nil)
        
        confirm.addAction(UIAlertAction(title: cancel, style: .cancel) { (action) in
            completionHandler(false)
        })
        
        confirm.addAction(UIAlertAction(title: ok, style: .default) { (action) in
            completionHandler(true)
        })
        
        self.present(confirm, animated: true, completion: nil)
    }
}
