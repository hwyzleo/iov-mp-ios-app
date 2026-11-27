//
//  ExploreArticleHTMLDocumentBuilder.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-012 on 2026/11/26.
//

import Foundation

/// 官方文章只读 HTML 文档构建：
/// - 标题、图集、作者与时间由原生视图渲染，文档只包含正文
/// - 正文使用 CMS 已清洗的 `body`
/// - 不引入脚本、样式表或任意可执行内容
enum ExploreArticleHTMLDocumentBuilder {

    static func makeDocument(_ detail: ExploreArticleDetailViewState,
                             locale: Locale = .current) -> String? {
        guard case let .officialHTML(body) = detail.body else {
            return nil
        }

        return """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <meta http-equiv="Content-Security-Policy" content="default-src 'none'; img-src https:; style-src 'unsafe-inline';"/>
        <style>
        :root { color-scheme: dark; }
        html, body { margin: 0; padding: 0; background: #0B0E14; }
        body {
          padding: 0;
          color: #FFFFFF;
          font: -apple-system-body;
          line-height: 1.65;
          word-wrap: break-word;
          -webkit-text-size-adjust: 100%;
        }
        article img { max-width: 100%; height: auto; border-radius: 8px; }
        article a { color: #00F0FF; }
        </style>
        </head>
        <body>
        <article>\(body)</article>
        </body>
        </html>
        """
    }

    static func escapeHTML(_ value: String) -> String {
        var escaped = value
        escaped = escaped.replacingOccurrences(of: "&", with: "&amp;")
        escaped = escaped.replacingOccurrences(of: "<", with: "&lt;")
        escaped = escaped.replacingOccurrences(of: ">", with: "&gt;")
        escaped = escaped.replacingOccurrences(of: "\"", with: "&quot;")
        escaped = escaped.replacingOccurrences(of: "'", with: "&#39;")
        return escaped
    }

    static func formatDate(_ date: Date, locale: Locale) -> String {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
