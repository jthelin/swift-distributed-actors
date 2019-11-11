// ==== ------------------------------------------------------------------ ====
// === DO NOT EDIT: Generated by GenActors                     
// ==== ------------------------------------------------------------------ ====

//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Actors open source project
//
// Copyright (c) 2019 Apple Inc. and the Swift Distributed Actors project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import DistributedActors

import class NIO.EventLoopFuture
// ==== ----------------------------------------------------------------------------------------------------------------
// MARK: DO NOT EDIT: Generated JackOfAllTrades messages 

/// DO NOT EDIT: Generated JackOfAllTrades messages
extension JackOfAllTrades {
    public enum Message { 
        case hello(replyTo: ActorRef<String>) 
        case ticketing(/*TODO: MODULE.*/GeneratedActor.Messages.Ticketing) 
        case parking(/*TODO: MODULE.*/GeneratedActor.Messages.Parking) 
    }

    
    /// Performs boxing of GeneratedActor.Messages.Ticketing messages such that they can be received by Actor<JackOfAllTrades>
    public static func _boxTicketing(_ message: GeneratedActor.Messages.Ticketing) -> JackOfAllTrades.Message {
        .ticketing(message)
    } 
    
    /// Performs boxing of GeneratedActor.Messages.Parking messages such that they can be received by Actor<JackOfAllTrades>
    public static func _boxParking(_ message: GeneratedActor.Messages.Parking) -> JackOfAllTrades.Message {
        .parking(message)
    } 
    
}
// ==== ----------------------------------------------------------------------------------------------------------------
// MARK: DO NOT EDIT: Generated JackOfAllTrades behavior

extension JackOfAllTrades {

    public static func makeBehavior(instance: JackOfAllTrades) -> Behavior<Message> {
        return .setup { _context in
            let context = Actor<JackOfAllTrades>.Context(underlying: _context)
            var instance = instance // TODO only var if any of the methods are mutating

            /* await */ instance.preStart(context: context)

            return Behavior<Message>.receiveMessage { message in
                switch message { 
                
                case .hello(let replyTo):
                    instance.hello(replyTo: replyTo)
 
                
                case .ticketing(.makeTicket):
                    instance.makeTicket() 
                case .parking(.park):
                    instance.park() 
                }
                return .same
            }.receiveSignal { _context, signal in 
                let context = Actor<JackOfAllTrades>.Context(underlying: _context)

                switch signal {
                case is Signals.PostStop: 
                    instance.postStop(context: context)
                    return .same
                case let terminated as Signals.Terminated:
                    switch instance.receiveTerminated(context: context, terminated: terminated) {
                    case .unhandled: 
                        return .unhandled
                    case .stop: 
                        return .stop
                    case .ignore: 
                        return .same
                    }
                default:
                    return .unhandled
                }
            }
        }
    }
}
// ==== ----------------------------------------------------------------------------------------------------------------
// MARK: Extend Actor for JackOfAllTrades

extension Actor where A.Message == JackOfAllTrades.Message {
    
    public func hello(replyTo: ActorRef<String>) { 
        self.ref.tell(.hello(replyTo: replyTo))
    } 
    
}
