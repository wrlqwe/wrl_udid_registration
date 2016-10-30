//
//  FormEntry.swift
//  PerfectTemplate
//
//  Created by 王儒林 on 2016/10/30.
//
//

import Foundation

class FormEntry {
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss UTC"
        return formatter
    }()
    var serial_number: NSNumber
    var formName: String
    var formUDID: String
    var creator_name: String
    var created_at: Date
    var updated_at: Date
    var info_remote_ip: String
    init(entry: [String: Any]) {
        serial_number = entry["serial_number"] as! NSNumber
        formName = entry["field_4"] as? String ?? ""
        formUDID = entry["field_9"] as? String ?? ""
        creator_name = entry["creator_name"] as? String ?? ""
        created_at = dateFormatter.date(from: entry["created_at"] as? String ?? "")!
        updated_at = dateFormatter.date(from: entry["updated_at"] as? String ?? "")!
        info_remote_ip = entry["info_remote_ip"] as? String ?? ""
    }
}
