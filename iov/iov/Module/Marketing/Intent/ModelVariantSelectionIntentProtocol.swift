//
//  ModelVariantSelectionIntentProtocol.swift
//  iov
//
//  Created by iov on 2026/6/2.
//

import SwiftUI

protocol ModelVariantSelectionIntentProtocol: MviIntentProtocol {
    func onTapVariant(model: ConfiguratorResult.ModelItem, variant: ConfiguratorResult.VariantItem)
}
