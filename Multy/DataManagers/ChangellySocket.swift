//Copyright 2018 Idealnaya rabota LLC
//Licensed under Multy.io license.
//See LICENSE for details

import UIKit
import SocketIO

private typealias MessageHandler = ChangellySocket

let changellySocketURL = "wss://api.changelly.com/"

class ChangellySocket: NSObject {
    static let shared = ChangellySocket()
    
    var manager : SocketManager
    var socket : SocketIOClient
    
    var isStarted : Bool {
        return socket.status == SocketIOStatus.connected
    }
    
    override init() {
        manager = SocketManager(socketURL: URL(string: changellySocketURL)!, config: [.log(false), .compress, .forceWebsockets(true), .reconnectAttempts(3), .forcePolling(false), .secure(false)])
        socket = manager.defaultSocket
    }
    
    func start() {
        if self.manager.status == .connected {
            return
        }
        
        DataManager.shared.getAccount { [unowned self] (account, error) in
            guard account != nil else {
                return
            }
            
            self.manager = SocketManager(socketURL: URL(string: socketUrl)!, config: [.log(false), .compress, .forceWebsockets(true), .reconnectAttempts(3), .forcePolling(false), .secure(false)])
            self.socket = self.manager.defaultSocket
            
            self.socket.on(clientEvent: .connect) { (data, ack) in
                print("socket connected")
            }
            
            self.socket.on(clientEvent: .disconnect) {data, ack in
                print("socket disconnected")
            }
            
            self.socket.on("connect") {data, ack in
                self.subscribe()
            }
            
            self.socket.connect()
        }
    }
    
    func subscribe() {
        
    }
    
    func restart() {
        stop()
        start()
    }
    
    func stop() {
        if self.socket.status == .connected{
            self.socket.disconnect()
        }
    }
}
