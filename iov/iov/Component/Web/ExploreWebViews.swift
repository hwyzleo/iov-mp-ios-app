//
//  ExploreWebViews.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import SwiftUI
import WebKit

// MARK: - 受管 H5

/// 仅接受绝对 HTTPS；WebView 内部继续导航时非 HTTPS 一律拦截。
struct ExploreManagedWebView: View {
    let url: URL

    @State private var isLoading = true
    @State private var failed = false
    @State private var reloadToken = UUID()

    var body: some View {
        VStack(spacing: 0) {
            TopBackTitleBar(titleLocal: L10n.explore_web_title)
            ZStack(alignment: .top) {
                ManagedH5WebView(url: url,
                                 isLoading: $isLoading,
                                 failed: $failed)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(reloadToken)
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(ExploreTheme.Colors.brand)
                        .padding(.top, 24)
                }
                if failed {
                    VStack(spacing: 16) {
                        Text(L10n.explore_web_unavailable)
                            .font(ExploreTheme.Fonts.body)
                            .foregroundColor(ExploreTheme.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                        Button(action: {
                            failed = false
                            isLoading = true
                            reloadToken = UUID()
                        }) {
                            Text(L10n.explore_retry)
                        }
                        .buttonStyle(ExploreSecondaryButtonStyle())
                        .frame(maxWidth: 220)
                    }
                    .padding(ExploreTheme.Layout.margin)
                }
            }
        }
        .exploreScreenBackground()
    }
}

private struct ManagedH5WebView: UIViewRepresentable {
    let url: URL
    @Binding var isLoading: Bool
    @Binding var failed: Bool

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration())
        webView.navigationDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.isOpaque = false
        webView.backgroundColor = UIColor(ExploreTheme.Colors.background)
        webView.scrollView.backgroundColor = UIColor(ExploreTheme.Colors.background)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.load(URLRequest(url: url))
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.parent = self
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var parent: ManagedH5WebView

        init(parent: ManagedH5WebView) {
            self.parent = parent
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let target = navigationAction.request.url else {
                decisionHandler(.cancel)
                return
            }
            switch ExploreWebPolicy.h5NavigationDecision(for: target) {
            case .allowInWebView:
                decisionHandler(.allow)
            case .openExternally, .block:
                decisionHandler(.cancel)
            }
        }

        func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
            updateUI { $0.isLoading = true; $0.failed = false }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            updateUI { $0.isLoading = false }
        }

        func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
            updateUI { $0.isLoading = false; $0.failed = true }
        }

        func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
            updateUI { $0.isLoading = false; $0.failed = true }
        }

        private func updateUI(_ block: @escaping (inout ManagedH5WebView) -> Void) {
            DispatchQueue.main.async {
                var parent = self.parent
                block(&parent)
                self.parent = parent
            }
        }
    }
}

// MARK: - 官方文章只读 HTML

/// 官方文章 HTML 渲染器：禁用脚本，仅允许空白初始页；HTTPS 链接交给系统浏览器。
struct ExploreArticleHTMLView: UIViewRepresentable {
    let html: String
    /// 嵌入外层 ScrollView 时关闭 WebView 内部滚动
    var isScrollEnabled: Bool = true
    /// 正文高度回调，用于让 WebView 在原生滚动容器中自适应高度
    var onContentHeightChange: ((CGFloat) -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(html: html, onContentHeightChange: onContentHeightChange)
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.defaultWebpagePreferences.allowsContentJavaScript = false
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.isOpaque = false
        webView.backgroundColor = UIColor(ExploreTheme.Colors.background)
        webView.scrollView.backgroundColor = UIColor(ExploreTheme.Colors.background)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.isScrollEnabled = isScrollEnabled
        context.coordinator.observeContentSize(of: webView)
        webView.loadHTMLString(html, baseURL: nil)
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.onContentHeightChange = onContentHeightChange
        if webView.scrollView.isScrollEnabled != isScrollEnabled {
            webView.scrollView.isScrollEnabled = isScrollEnabled
        }
        guard context.coordinator.loadedHTML != html else { return }
        context.coordinator.loadedHTML = html
        webView.loadHTMLString(html, baseURL: nil)
    }

    final class Coordinator: NSObject, WKNavigationDelegate {
        var loadedHTML: String
        var onContentHeightChange: ((CGFloat) -> Void)?
        private var contentSizeObservation: NSKeyValueObservation?

        init(html: String, onContentHeightChange: ((CGFloat) -> Void)?) {
            self.loadedHTML = html
            self.onContentHeightChange = onContentHeightChange
        }

        deinit {
            contentSizeObservation?.invalidate()
        }

        func observeContentSize(of webView: WKWebView) {
            contentSizeObservation = webView.scrollView.observe(\.contentSize, options: [.new]) { [weak self] scrollView, _ in
                let height = scrollView.contentSize.height
                guard height > 0 else { return }
                DispatchQueue.main.async {
                    self?.onContentHeightChange?(height)
                }
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            let height = webView.scrollView.contentSize.height
            guard height > 0 else { return }
            DispatchQueue.main.async { [weak self] in
                self?.onContentHeightChange?(height)
            }
        }

        func webView(_ webView: WKWebView,
                     decidePolicyFor navigationAction: WKNavigationAction,
                     decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let target = navigationAction.request.url else {
                // `loadHTMLString` 的初始导航可能没有 URL；只放行这一次加载
                decisionHandler(.allow)
                return
            }
            switch ExploreWebPolicy.articleNavigationDecision(for: target) {
            case .allowInWebView:
                decisionHandler(.allow)
            case .openExternally:
                decisionHandler(.cancel)
                UIApplication.shared.open(target)
            case .block:
                decisionHandler(.cancel)
            }
        }
    }
}
