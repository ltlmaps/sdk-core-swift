//
//  XyoBoundWitnessAppGroupManager.swift
//  Pods-Receiver
//
//  Created by Darren Sutherland on 6/6/19.
//

import Foundation

public class XyoBoundWitnessAppGroupManager: XyoAppGroupPipeListener {

    private var relayNode: XyoRelayNode?
    private lazy var manager: XyoAppGroupPipeServer = {
        return XyoAppGroupPipeServer(listener: self)
    }()

    private class AppPipeCatalogue: XyoFlagProcedureCatalogue {
        private static let allSupportedFunctions = UInt32(XyoProcedureCatalogueFlags.BOUND_WITNESS)

        public init () {
            super.init(forOther: AppPipeCatalogue.allSupportedFunctions,
                       withOther: AppPipeCatalogue.allSupportedFunctions)
        }

        override public func choose(catalogue: [UInt8]) -> [UInt8] {
            guard let intrestedFlags = catalogue.last else {
                return []
            }

            if (intrestedFlags & UInt8(XyoProcedureCatalogueFlags.BOUND_WITNESS) != 0 && canDo(bytes: [UInt8(XyoProcedureCatalogueFlags.BOUND_WITNESS)])) {
                return [UInt8(XyoProcedureCatalogueFlags.BOUND_WITNESS)]
            }

            return []
        }
    }

    public init() {
        self.createNewRelayNode()
    }

    public func initiate(identifier: String) {
        let pipe = self.manager.requestConnection(identifier: String(identifier))
        pipe.setFirstWrite { [weak self] in
            self?.relayNode?.boundWitness(handler: XyoNetworkHandler(pipe: pipe), procedureCatalogue: AppPipeCatalogue()) { _, _ in
                // TODO propogate this, throw or return in callback?
            }
        }
    }

    public func onPipe(pipe: XyoNetworkPipe) {}

    private func createNewRelayNode() {
        do {
            let storage = XyoInMemoryStorage()
            let blocks = XyoStrageProviderOriginBlockRepository(storageProvider: storage,hasher: XyoSha256())
            let state = XyoStorageOriginChainStateRepository(storage: storage)
            let conf = XyoRepositoryConfiguration(originState: state, originBlock: blocks)

            let node = XyoRelayNode(hasher: XyoSha256(),
                                    repositoryConfiguration: conf,
                                    queueRepository: XyoStorageBridgeQueueRepository(storage: storage))

            let signer = XyoSecp256k1Signer()
            node.originState.addSigner(signer: signer)

            try node.selfSignOriginChain()

            self.relayNode = node
        } catch {
            fatalError("Node should be able to sign its chain")
        }
    }

}
