//
//  ContentView.swift
//  PoolAimTrainer
//
//  Hosts the SpriteKit table with a SwiftUI control panel on top.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var model = GameModel()
    @State private var scene = PoolTableScene()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                SpriteView(scene: makeScene(size: geo.size))
                    .ignoresSafeArea()

                VStack {
                    header
                    Spacer()
                    controls
                }
                .padding()
            }
        }
        .preferredColorScheme(.dark)
    }

    private func makeScene(size: CGSize) -> PoolTableScene {
        scene.size = size
        scene.scaleMode = .resizeFill
        scene.model = model
        return scene
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Aim Trainer")
                    .font(.headline)
                Text("Cut angle: \(model.cutAngleText)")
                    .font(.subheadline)
                    .foregroundStyle(.yellow)
            }
            Spacer()
            Toggle("Guides", isOn: $model.showGuides)
                .labelsHidden()
                .toggleStyle(.switch)
            Text("Guides").font(.caption).foregroundStyle(.secondary)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14))
    }

    private var controls: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "bolt.fill").foregroundStyle(.orange)
                Slider(value: $model.power, in: 0.1...1)
                Text("\(Int(model.power * 100))%")
                    .font(.caption.monospacedDigit())
                    .frame(width: 44, alignment: .trailing)
            }

            HStack(spacing: 12) {
                Button {
                    model.resetRackAction?()
                } label: {
                    Label("Rack", systemImage: "triangle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    model.breakLayoutAction?()
                } label: {
                    Label("Scatter", systemImage: "sparkles")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Button {
                    model.shootAction?()
                } label: {
                    Label("Shoot", systemImage: "scope")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(!model.isSettled)
            }
        }
        .padding(14)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

#Preview {
    ContentView()
}
