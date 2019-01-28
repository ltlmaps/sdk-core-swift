//
//  XyoBoundWitnessOption.swift
//  sdk-core-swift
//
//  Created by Carter Harrison on 1/28/19.
//  Copyright © 2019 XYO Network. All rights reserved.
//

import Foundation
import sdk_objectmodel_swift

public protocol XyoBoundWitnessOption {
    func getFlag () -> UInt
    func getSignedPayload () -> XyoObjectStructure?
    func getUnsignedPatload () -> XyoObjectStructure?
    func onCompleted (boundWitness : XyoBoundWitness?)
}
