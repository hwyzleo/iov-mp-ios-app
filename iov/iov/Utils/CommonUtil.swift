//
//  CommonUtil.swift
//  iov
//
//  Created by 叶荣杰 on 2024/9/1.
//

import Foundation

/// 转换性别字符串
func genderStr(_ gender: String) -> String {
    switch gender {
    case "MALE":
        return "男"
    case "FEMALE":
        return "女"
    default:
        return "未知"
    }
}

/// 日期转字符串
func dateToStr(date: Date, format: String = "yyyy-MM-dd") -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}

/// 字符串转日期
func strToDate(str: String, format: String = "yyyy-MM-dd") -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = format
    if let date = dateFormatter.date(from: str) {
        return date
    } else {
        return nil
    }
}

/// 显示时间戳
func tsDisplay(ts: Int64) -> String {
    let now = Int64(Date().timeIntervalSince1970*1000)
    let interval = now - ts
    if interval <= 60*1000 {
        return "1分钟内"
    }
    if interval < 60*60*1000 {
        return "\(interval/1000/60)分钟前"
    }
    if interval < 24*60*60*1000 {
        return "\(interval/1000/60/60)小时前"
    }
    return dateToStr(date: Date(timeIntervalSince1970: TimeInterval(ts)), format: "MM-dd HH:mm")
}

/// 格式化时间戳
func tsFormat(ts: Int64, format: String = "yyyy-MM-dd HH:mm:ss") -> String {
    var time = ts
    if time > 1000000000000 {
        time = time / 1000
    }
    return dateToStr(date: Date(timeIntervalSince1970: TimeInterval(time)), format: format)
}

/// 计算倒计时
func calCountDown(endTs: Int64) -> String {
    let now = Int64(Date().timeIntervalSince1970*1000)
    let interval = endTs - now
    if interval <= 0 {
        return "已结束"
    }
    if interval < 60*1000 {
        return "\(interval/1000)秒"
    }
    if interval < 60*60*1000 {
        let minute = interval/60/1000
        let second = (interval-minute*60*1000)/1000
        return "\(minute)分\(second)秒"
    }
    if interval < 24*60*60*1000 {
        let hour = interval/60/60/1000
        let minute = (interval - hour*60*60*1000)/60/1000
        let second = (interval - hour*60*60*1000 - minute*60*1000)/1000
        return "\(hour)小时\(minute)分\(second)秒"
    } else {
        let day = interval/24/60/60/1000
        let hour = (interval - day*24*60*60*1000)/60/60/1000
        let minute = (interval - day*24*60*60*1000 - hour*60*60*1000)/60/1000
        let second = (interval - day*24*60*60*1000 - hour*60*60*1000 - minute*60*1000)/1000
        return "\(day)天\(hour)小时\(minute)分\(second)秒"
    }
}

/// 写信息入本地
func setInfo(_ key: String, value: String) {
    UserDefaults.standard.set(value, forKey: key)
    UserDefaults.standard.synchronize()
}
/// 信息从本地读取
func getInfo(_ key: String) -> String {
    let str = (UserDefaults.standard.object(forKey: key) as? String)
    return str ?? ""
}
