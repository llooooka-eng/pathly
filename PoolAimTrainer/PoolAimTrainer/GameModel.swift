//
//  GameModel.swift
//  PoolAimTrainer
//
//  Shared state bridging the SwiftUI controls and the SpriteKit scene.
//

import SwiftUI
import Combine

final class GameModel: ObservableObject {
    /// Shot power, 0…1. Scaled to an impulse inside the scene.
    @Published var power: CGFloat = 0.55
    /// Whether the aiming guide (ghost ball + predicted lines) is drawn.
    @Published var showGuides: Bool = true
    /// Live readout of the current cut angle, shown in the HUD.
    @Published var cutAngleText: String = "—"
    /// Whether the balls are currently rolling (disables the Shoot button).
    @Published var isSettled: Bool = true

    // Commands the scene installs so the UI can drive it.
    var shootAction: (() -> Void)?
    var resetRackAction: (() -> Void)?
    var breakLayoutAction: (() -> Void)?
}
