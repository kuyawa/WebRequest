//
//  ViewController.swift
//  WebRequest
//
//  Created by Mac Mini on 12/9/16.
//  Copyright © 2016 Armonia. All rights reserved.
//

import Cocoa

enum HttpMethod : Int {
    case Get, Post, Put, Delete
}

class ViewController: NSViewController {

    var raw  : String = ""
    var body : String = ""
    
    let fontMono = NSFont(name: "Monaco", size: 14.0)
    
    @IBOutlet weak var textURL        : NSTextField!
    @IBOutlet weak var textStatusCode : NSTextField!
    @IBOutlet weak var textMimeType   : NSTextField!
    @IBOutlet weak var textMessage    : NSTextField!
    @IBOutlet weak var textResult     : NSTextField!
    @IBOutlet      var textHeaders    : NSTextView!
    @IBOutlet      var textPayload    : NSTextView!
    @IBOutlet      var textContent    : NSTextView!
    @IBOutlet weak var buttonMethod   : NSSegmentedControl!
    @IBOutlet weak var formUrlEncoded : NSButton!
    
    
    @IBAction func onRequest(_ sender: AnyObject) {
        resetUI()
        statusLoading()
        webRequest()
    }

    @IBAction func onFormEncoded(_ sender: NSButton) {
        let formEncoded = "Content-Type: application/x-www-form-urlencoded; charset=utf-8"
        if sender.state == 1 {
            if let headers = textHeaders.string {
                textHeaders.string = headers + "\n" + formEncoded
            } else {
                textHeaders.string = formEncoded
            }
        } else {
            textHeaders.string = textHeaders.string?.replacingOccurrences(of: "\n"+formEncoded, with: "")
            textHeaders.string = textHeaders.string?.replacingOccurrences(of: formEncoded, with: "")
        }
    }

    @IBAction func onShowHeaders(_ sender: NSButton) {
        if sender.state == 1 {
            textContent.string = self.raw
        } else {
            textContent.string = self.body
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
    }
    
    func initialize() {
        resetUI()
        let testUrl = "http://example.com"
        textURL.stringValue = testUrl
    }

    func resetUI() {
        textResult.stringValue     = "Content:"
        textStatusCode.stringValue = ""
        textMimeType.stringValue   = ""
        textMessage.stringValue    = ""
        textHeaders.string         = "User-Agent: WebRequest 1.0"
        textContent.string         = ""
        textHeaders.font           = fontMono
        textPayload.font           = fontMono
        textContent.font           = fontMono
    }

    func statusLoading() {
        // TODO: add spinnner
        textStatusCode.stringValue = "Loading..."
    }
    
    func webRequest() {
        let web     = WebRequest()
        let url     = URL(string: textURL.stringValue)
        let method  = HttpMethod(rawValue: buttonMethod.selectedSegment)!
        let headers = textHeaders.string ?? ""
        let payload = textPayload.string ?? ""
        let encoded = (formUrlEncoded.state==1)
        
        if !headers.isEmpty {
            web.headers = headers.components(separatedBy: .newlines)
        }
        
        switch method {
        case .Get:
            try? web.get(url!){ self.handle($0) }
        case .Post:
            if encoded {
                web.headers.append("Content-Type: application/x-www-form-urlencoded; charset=utf-8")
            }
            try? web.post(url!, body: payload){ self.handle($0) }
        case .Put:
            try? web.put(url!, body: payload){ self.handle($0) }
        case .Delete:
            try? web.delete(url!){ self.handle($0) }
        }
    }
    
    func handle(_ response: WebResponse){
        self.raw  = response.raw
        self.body = response.content
        
        if response.isError {
            DispatchQueue.main.async {
                self.textResult.stringValue     = "Error:"
                self.textStatusCode.stringValue = "Error"
                self.textMimeType.stringValue   = "Error"
                self.textMessage.stringValue    = response.error?.localizedDescription ?? "Unknown error"
                self.textContent.string         = response.error?.localizedDescription ?? "Unknown error"
            }
            return
        }
        
        DispatchQueue.main.async {
            self.textResult.stringValue      = "Content:"
            self.textStatusCode.integerValue = response.statusCode
            self.textMimeType.stringValue    = response.mimeType
            self.textMessage.stringValue     = "Ok"
            // If raw checked, show raw
            self.textContent.string          = response.content
        }
    }

}

