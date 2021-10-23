//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Distributed Actors open source project
//
// Copyright (c) 2018-2019 Apple Inc. and the Swift Distributed Actors project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.md for the list of Swift Distributed Actors project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

@testable import DistributedActors
import DistributedActorsTestKit
import Foundation
import XCTest

final class ActorIsolationFailureHandlingTests: ActorSystemXCTestCase {
    private enum SimpleTestError: Error {
        case simpleError(reason: String)
    }

    enum SimpleProbeMessage: Equatable, NonTransportableActorMessage {
        case spawned(child: _ActorRef<FaultyWorkerMessage>)
        case echoing(message: String)
    }

    enum FaultyWorkerMessage: NonTransportableActorMessage {
        case work(n: Int, divideBy: Int)
        case throwError(error: Error)
    }

    enum WorkerError: Error {
        case error(code: Int)
    }

    func faultyWorkerBehavior(probe pw: _ActorRef<Int>) -> Behavior<FaultyWorkerMessage> {
        .receive { context, message in
            context.log.info("Working on: \(message)")
            switch message {
            case .work(let n, let divideBy): // Fault handling is not implemented
                pw.tell(n / divideBy)
                return .same
            case .throwError(let error):
                context.log.warning("Throwing as instructed, error: \(error)")
                throw error
            }
        }
    }

    let spawnFaultyWorkerCommand = "spawnFaultyWorker"
    func healthyMasterBehavior(pm: _ActorRef<SimpleProbeMessage>, pw: _ActorRef<Int>) -> Behavior<String> {
        .receive { context, message in
            switch message {
            case self.spawnFaultyWorkerCommand:
                let worker = try context.spawn("faultyWorker", self.faultyWorkerBehavior(probe: pw))
                pm.tell(.spawned(child: worker))
            default:
                pm.tell(.echoing(message: message))
            }
            return .same
        }
    }

    func test_worker_crashOnlyWorkerOnPlainErrorThrow() throws {
        let pm: ActorTestProbe<SimpleProbeMessage> = self.testKit.spawnTestProbe("testProbe-master-1")
        let pw: ActorTestProbe<Int> = self.testKit.spawnTestProbe("testProbeForWorker-1")

        let healthyMaster: _ActorRef<String> = try system.spawn("healthyMaster", self.healthyMasterBehavior(pm: pm.ref, pw: pw.ref))

        // watch parent and see it spawn the worker:
        pm.watch(healthyMaster)
        healthyMaster.tell("spawnFaultyWorker")
        guard case .spawned(let worker) = try pm.expectMessage() else { throw pm.error() }

        // watch the worker and see that it works correctly:
        pw.watch(worker)
        worker.tell(.work(n: 100, divideBy: 10))
        try pw.expectMessage(10)

        // issue a message that will cause the worker to crash
        worker.tell(.throwError(error: WorkerError.error(code: 418))) // BOOM!

        // the worker, should have terminated due to the error:
        try pw.expectTerminated(worker)

        // even though the worker crashed, the parent is still alive (!)
        let stillAlive = "still alive"
        healthyMaster.tell(stillAlive)
        try pm.expectMessage(.echoing(message: "still alive"))
    }
}
