import WebKit
import Turbolinks

class TurbolinksSession: Session {
    required convenience init(_ webViewConfiguration: WKWebViewConfiguration) {
        self.init(webViewConfiguration: webViewConfiguration)
        self.webView.uiDelegate = self
        self.webView.allowsLinkPreview = false
    }
    
    func injectSharedCookies() {
        if #available(iOS 11.0, *) {
            HTTPCookieStorage.shared.cookies?.forEach({ (cookie) in
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
            })
        } else {
            var script = ""
            var isEvaluatingJavaScript = true
            HTTPCookieStorage.shared.cookies?.forEach({ (cookie) in
                script.append(String(format: "document.cookie = \"%@=%@", cookie.name, cookie.value))
                if cookie.path != "" { script.append(String(format: "; Path=%@", cookie.path)) }
                if cookie.expiresDate != nil { script.append(String(format: "; Expires=%@", toUTCString(cookie.expiresDate!))) }
                script.append("\";\n")
            })
            
            webView.evaluateJavaScript(script) { (response, error) in isEvaluatingJavaScript = false }
            while isEvaluatingJavaScript { RunLoop.main.run(mode: .default, before: .distantFuture) }
        }
        
        func toUTCString(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "en_US")
            formatter.timeZone = TimeZone(abbreviation: "UTC")
            formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
            return formatter.string(from: date)
        }
    }
}

extension TurbolinksSession: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let confirm = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        confirm.addAction(UIAlertAction(title: getUIKitLocalizedString("Cancel"), style: .cancel) { (action) in completionHandler(false) })
        confirm.addAction(UIAlertAction(title: getUIKitLocalizedString("OK"), style: .default) { (action) in completionHandler(true) })
        topController.present(confirm, animated: true)
    }

    fileprivate func getUIKitLocalizedString(_ key: String) -> String {
        Bundle(identifier: "com.apple.UIKit")!.localizedString(forKey: key, value: nil, table: nil)
    }

    fileprivate var topController: UIViewController {
        var result = UIApplication.shared.keyWindow!.rootViewController!
        while let topController = result.presentedViewController { result = topController }
        return result
    }
}
