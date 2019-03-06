//
//  XyoBridgeQueue.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public class XyoBridgeQueue {
    public let repo : XyoBridgeQueueRepository
    public var sendLimit = 10
    public var removeWeight = 3
    
    public init (repository : XyoBridgeQueueRepository) {
        self.repo = repository
    }
    
    func addBlock (blockHash : XyoObjectStructure) {
        addBlock(blockHash: blockHash, weight: 0)
    }
    
    func addBlock (blockHash : XyoObjectStructure, weight : Int) {
        let newQueueItem = XyoBridgeQueueItem(weight: weight, hash: blockHash)
        repo.addQueueItem(item: newQueueItem)
    }
    
    func getBlocksToBridge() -> [XyoBridgeQueueItem] {
        return repo.getLowestWeight(n: sendLimit)
    }
    
    func onBlocksBridged (blocks : [XyoBridgeQueueItem]) {
        var hashes = [XyoObjectStructure]()
        
        for block in blocks {
            hashes.append(block.hash)
        }
        
        repo.incrementWeights(hashes: hashes)
    }
    
    // it is possable to leak blocks if this function is called, the blocks are removed in the queue, before the block repository.
    func getBlocksToRemove () -> [XyoObjectStructure] {
        let blocksToBridge = repo.getQueue()
        var toRemoveHashes = [XyoObjectStructure]()
        
        for i in (0..<blocksToBridge.count).reversed() {
            if (blocksToBridge[i].weight >= removeWeight) {
                let hash = blocksToBridge[i].hash
                toRemoveHashes.append(hash)
            }
        }
        
        repo.removeQueueItems(hashes: toRemoveHashes)
        return toRemoveHashes
    }
}
