//
//  main.swift
//  PerfectTemplate
//
//  Created by Kyle Jessup on 2015-11-05.
//	Copyright (C) 2015 PerfectlySoft, Inc.
//
//===----------------------------------------------------------------------===//
//
// This source file is part of the Perfect.org open source project
//
// Copyright (c) 2015 - 2016 PerfectlySoft Inc. and the Perfect project authors
// Licensed under Apache License v2.0
//
// See http://perfect.org/licensing.html for license information
//
//===----------------------------------------------------------------------===//
//

import PerfectLib
import PerfectHTTP
import PerfectHTTPServer
import Foundation

// Create HTTP server.
let server = HTTPServer()

// Register your own routes and handlers
var routes = Routes()
routes.add(method: .get, uri: "/", handler: {
    request, response in
    response.setHeader(.contentType, value: "text/html")
    response.appendBody(string: "<html><title>Hello, world!</title><body>Hello, world!</body></html>")
    response.completed()
    }
)

let formName = "DYUcju"
func readEntries(request: HTTPRequest) -> NSArray {
    let filePath = "\(request.documentRoot)/entries.plist"
    let entries = NSArray(contentsOfFile: filePath) ?? []
    return entries
}

routes.add(method: .post, uri: "/registration") { request, response in

    func completeError(description: String) {
        response.status = .badRequest
        response.appendBody(string: "<html><title>Bad Request</title><body>\(description)</body></html>")
        response.completed()
    }
    guard let body = request.postBodyBytes else {
        completeError(description: "Request Body Should Not Be NULL")
        return
    }

    let data = Data(body)
    guard let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions(rawValue: 0)) as! [String: Any] else {
        completeError(description: "Request Body Should Be JSON")
        return
    }

    let form = json["form"] as! String
    guard form == formName else {
        completeError(description: "Wrong Form")
        return
    }

    let entry = json["entry"] as! [String: Any]
    let filePath = "\(request.documentRoot)/entries.plist"
    let entries = readEntries(request: request)
    entries.adding(entry)
    entries.write(toFile: filePath, atomically: true)
    
    response.status = .ok
    response.completed()
}

routes.add(method: .get, uri: "/registration") { request, response in
    let docRoot = request.documentRoot
    var entries: [[String: Any]] = readEntries(request: request) as! [[String: Any]]
    let list = entries.map { obj -> [String : String] in
        let name = obj["field_4"] as! String
        let udid = obj["field_9"] as! String
        return ["deviceIdentifier": udid, "deviceName": name]
    }
    let fileDic: Dictionary = ["Device UDIDs": list]
    do {
        let data = try PropertyListSerialization.data(fromPropertyList: fileDic, format: PropertyListSerialization.PropertyListFormat.binary, options: PropertyListSerialization.WriteOptions.min)
        response.setHeader(.contentType, value: "application/x-plist")
        response.setHeader(.contentLength, value: "\(data.count)")
        response.setHeader(.contentDisposition, value: "inline; filename=\"registration_ids.plist\"")
        let array = data.withUnsafeBytes {
            [UInt8](UnsafeBufferPointer(start: $0, count: data.count))
        }
        response.setBody(bytes: array)
    } catch {
        response.status = .internalServerError
        response.setBody(string: "请求处理出现错误： \(error)")
    }
    response.completed()
}


// Add the routes to the server.
server.addRoutes(routes)

// Set a listen port of 8181
server.serverPort = 8181

// Set a document root.
// This is optional. If you do not want to serve static content then do not set this.
// Setting the document root will automatically add a static file handler for the route /**
server.documentRoot = "./webroot"

// Gather command line options and further configure the server.
// Run the server with --help to see the list of supported arguments.
// Command line arguments will supplant any of the values set above.
configureServer(server)

do {
	// Launch the HTTP server.
	try server.start()
} catch PerfectError.networkError(let err, let msg) {
	print("Network error thrown: \(err) \(msg)")
}
