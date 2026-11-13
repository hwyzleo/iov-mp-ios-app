//
//  CodableDefault.swift
//  iov
//
//  Created by hwyz_leo on 2024/9/1.
//

// 用于给 Codable 协议添加默认值
protocol DefaultValue {
    associatedtype Value: Codable
    static var defaultValue: Value { get }
}

@propertyWrapper
struct Default<T: DefaultValue> {
    var wrappedValue: T.Value
}

extension Default: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = (try? container.decode(T.Value.self)) ?? T.defaultValue
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: Default<T>.Type, forKey key: Key) throws -> Default<T> where T: DefaultValue {
        // 判断 key 缺失的情况，提供默认值
        (try decodeIfPresent(type, forKey: key)) ?? Default(wrappedValue: T.defaultValue)
    }
}
extension KeyedEncodingContainer {
    mutating func encode<T>(_ value: Default<T>, forKey key: Key) throws where T : DefaultValue {
        try encodeIfPresent(value.wrappedValue, forKey: key)
    }
}

/// 兼容后端时间字段的多种返回格式
///
/// 后端同一语义字段在不同接口/数据下可能返回：
/// - 毫秒时间戳：`1794532510160`
/// - 秒时间戳：`1794532510`
/// - 字符串时间戳：`"1794532510160"`
/// - ISO-8601 字符串：`"2026-11-12T13:52:17.000+00:00"`
///
/// 数值原样保留（不改变单位），日期字符串统一转换为「毫秒时间戳」，
/// 与 `tsFormat(ts:)` / `calCountDown(endTs:)` 等既有工具的入参约定保持一致。
///
/// 使用方式：`@FlexibleTimestamp var orderTime: Int64?`
@propertyWrapper
struct FlexibleTimestamp: Codable {
    var wrappedValue: Int64?

    init(wrappedValue: Int64?) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let timestamp = try? container.decode(Int64.self) {
            wrappedValue = timestamp
        } else if let timestamp = try? container.decode(Double.self) {
            wrappedValue = Int64(timestamp)
        } else if let text = try? container.decode(String.self) {
            wrappedValue = Self.parse(text)
        } else {
            wrappedValue = nil
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }

    /// 解析字符串形式的时间：数值时间戳 / ISO-8601 / 常见日期格式
    private static func parse(_ text: String) -> Int64? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let timestamp = Int64(trimmed) {
            return timestamp
        }
        if let timestamp = Double(trimmed) {
            return Int64(timestamp)
        }
        guard let date = TspManager.parseDate(from: trimmed) else { return nil }
        return Int64(date.timeIntervalSince1970 * 1000)
    }
}

extension KeyedDecodingContainer {
    func decode(_ type: FlexibleTimestamp.Type, forKey key: Key) throws -> FlexibleTimestamp {
        // 判断 key 缺失或格式无法识别的情况，提供 nil 默认值
        (try? decodeIfPresent(type, forKey: key)) ?? FlexibleTimestamp(wrappedValue: nil)
    }
}

extension Int: DefaultValue {
    static var defaultValue = -1
}

extension String: DefaultValue {
    static var defaultValue = ""
}
