import UIKit
import WebKit

class WebView: WKWebView {
    
    private var fontSize: CGFloat = 16
    private var fontWeight: UIFont.Weight = .regular
    private var fontFileName: String {
        switch fontWeight {
        case .bold: "Font-Bold.ttf"
        case .heavy: "Font-ExtraBold.ttf"
        case .light: "Font-Light.ttf"
        case .medium: "Font-Medium.ttf"
        case .semibold: "Font-SemiBold.ttf"
        default: "Font-Regular.ttf"
        }
    }
    private var isLoadingContent = false
    private var loadContentCompletion: (() -> ())?
    private(set) var contentHeight: CGFloat = 0
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: bounds.width, height: contentHeight)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        navigationDelegate = self
        scrollView.isScrollEnabled = false
    }
    
    private func resetContentHeight() {
        contentHeight = 0
        invalidateIntrinsicContentSize()
        superview?.layoutIfNeeded()
    }
    
    func setFont(size: CGFloat, weight: UIFont.Weight) {
        fontSize = size
        fontWeight = weight
    }
    
    func setContent(_ body: String, completion: (() -> ())? = nil) {
        resetContentHeight()
        isLoadingContent = true
        loadContentCompletion = completion
        
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
            @font-face {
                font-family: 'CustomFont';
                src: url('\(fontFileName)');
                font-weight: normal;
            }
            
            body {
                -webkit-user-select: none;
                font-family: 'CustomFont', -apple-system;
                font-size: \(Int(fontSize))px;
                color: #1D1E21;
                background-color: transparent !important;
                margin: 0;
                padding: 0;
            }
        
            p {
                margin: 0;
                padding: 0;
            }
            
            img {
                max-width: 100%;
                height: auto;
            }
            
            figure.table {
                margin: 0;
                padding: 0;
                overflow-x: auto;
                width: 100%;
                max-width: 100%;
            }
            
            table {
                width: max-content;
                border-collapse: collapse;
                padding: 0;
            }
            
            th, td {
                border: 1px solid #ccc;
                padding: 8px;
            }
        </style>
        </head>
        <body>
        \(body)
        </body>
        </html>
        """
        loadHTMLString(html, baseURL: Bundle.main.bundleURL)
    }
    
    func crossOutText() {
        let handler = { [weak self] in
            guard let self else { return }
            evaluateJavaScript("""
            var style = document.createElement('style');
            style.innerHTML = `
                body, body * {
                    text-decoration: line-through !important;
                }
            `;
            document.head.appendChild(style);
            """)
        }
        
        if isLoadingContent {
            if loadContentCompletion == nil {
                loadContentCompletion = handler
            } else {
                let completion = loadContentCompletion
                loadContentCompletion = {
                    handler()
                    completion?()
                }
            }
        } else {
            handler()
        }
    }
    
}

extension WebView: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        guard !isLoading else { return }
        
        evaluateJavaScript("document.readyState") { [weak self] complete, _ in
            guard
                complete != nil,
                let self
            else { return }
            
            evaluateJavaScript("document.documentElement.scrollHeight") { [weak self] result, _ in
                guard
                    let height = result as? CGFloat,
                    let self
                else { return }
                
                contentHeight = height
                invalidateIntrinsicContentSize()
                isLoadingContent = false
                loadContentCompletion?()
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        resetContentHeight()
    }
    
}
