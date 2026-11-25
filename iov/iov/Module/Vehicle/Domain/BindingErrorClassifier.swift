//
//  BindingErrorClassifier.swift
//  iov
//
//  Created by CR IOS-APP-DSN-CR-011 on 2026/11/23.
//

import Foundation

/// 绑定链路错误语义分层（IOS-APP-DSN-CR-011 D-011-4 / 第 1 轮裁决 BLK-9）。
///
/// 目标：认证类错误不再被压成 `.network`，解码失败与网络失败分开，网关码单独归类。
/// 判定顺序：
/// 1. 已是 `VehicleBindingFailure` 直接透传（服务层内部已分类的场景）；
/// 2. `NSURLErrorDomain` → `.network`（可重试）；
/// 3. `NetworkAPIError`（`TspManager.parseData` 解码失败）→ `.invalidResponse`（不讲「网络问题」）；
/// 4. 有包络业务码 → 网关码 / 认证码 / 4011xx / 兜底；
/// 5. 其余 → `.network`（可重试兜底，保持既有行为，不猜测为认证类）。
enum BindingErrorClassifier {

    // MARK: - 网关码（复用既有码，不新增）

    static let gatewayAuthenticationFailed = "SGW-401001"
    static let gatewayForbidden = "SGW-403001"
    static let gatewayNotFound = "SGW-404001"

    private static let gatewayMarker = "SGW-"

    // MARK: - Error 分类

    /// 网络层 / 解码层错误分类（方案 A：零侵入，仅在本模块使用）
    static func classify(error: Error) -> VehicleBindingFailure {
        if let failure = error as? VehicleBindingFailure {
            return failure
        }
        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            return .network
        }
        if nsError.domain == "NetworkAPIError" {
            // 响应体无法解码为 `TspResponse` 包络：视为「服务响应异常」，不得说成网络问题
            return .invalidResponse
        }
        // 兜底保持既有可重试语义，不推断认证维度
        return .network
    }

    /// 带状态码的增量分类（方案 B 预留，本期非必做；未拿到状态码时按方案 A 处理）。
    ///
    /// 注意：本期不实现带状态码的网络方法，因此 HTTP 401 空体实际由解码失败覆盖，
    /// 落 `.invalidResponse`（可重试），认证维度由 `701304` / `701403` / `SGW-401001` 覆盖。
    static func classify(error: Error, statusCode: Int?) -> VehicleBindingFailure {
        if let failure = error as? VehicleBindingFailure {
            return failure
        }
        let nsError = error as NSError
        if nsError.domain == "NetworkAPIError", let statusCode {
            if statusCode == 401 { return .authenticationRejected }
            if statusCode == 403 { return .forbidden }
            if statusCode == 404 { return .invalidResponse }
        }
        return classify(error: error)
    }

    // MARK: - 包络业务码分类

    /// 包络码 → 失败语义（`TspResponse.code`，亦覆盖网关码）
    static func classify(code: String?, message: String? = nil) -> VehicleBindingFailure {
        let trimmedMessage = message?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasMessage = !(trimmedMessage ?? "").isEmpty
        let rawCode = code?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        // 网关码优先级最高：既可能出现在 code，也可能出现在 message（网关直返）
        if let gatewayCode = normalizedGatewayCode(in: rawCode) ?? trimmedMessage.flatMap(normalizedGatewayCode(in:)) {
            switch gatewayCode {
            case gatewayAuthenticationFailed:
                return .authenticationSessionExpired
            case gatewayForbidden:
                return .forbidden
            case gatewayNotFound:
                return .invalidResponse
            default:
                return hasMessage ? .server(message: trimmedMessage) : .server(message: nil)
            }
        }

        guard !rawCode.isEmpty else {
            return hasMessage ? .server(message: trimmedMessage) : .unknown
        }

        let upper = rawCode.uppercased()
        switch upper {
        case AuthServerCode.sessionExpired:
            return .authenticationSessionExpired
        case AuthServerCode.authenticationRejected:
            return .authenticationRejected
        default:
            return VehicleBindingFailure.from(code: rawCode, message: trimmedMessage)
        }
    }

    /// 归一化网关码：大小写不敏感、忽略包裹空白；返回大写标准形式（非法则 nil）
    static func normalizedGatewayCode(in text: String) -> String? {
        let upper = text.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard upper.hasPrefix(gatewayMarker) else { return nil }
        // 只取 `SGW-` 前缀段（避免 message 中夹带业务码时误判）
        let candidate = String(upper.prefix(gatewayMarker.count + 6))
        let digits = candidate.dropFirst(gatewayMarker.count)
        guard digits.count == 6, digits.allSatisfy({ $0.isNumber }) else { return nil }
        return candidate
    }
}
