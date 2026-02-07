//
//  PetWidgetExtensionBundle.swift
//  PetWidgetExtension
//
//  Created by Christian Manzke on 2/7/26.
//

import WidgetKit
import SwiftUI

@main
struct PetWidgetExtensionBundle: WidgetBundle {
    var body: some Widget {
        PetWidgetExtension()
        PetWidgetExtensionControl()
        PetWidgetExtensionLiveActivity()
    }
}
