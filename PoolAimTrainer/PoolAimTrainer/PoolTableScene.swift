//
//  PoolTableScene.swift
//  PoolAimTrainer
//
//  The interactive practice table. Drag anywhere to aim (the line pivots around
//  the cue ball), read the ghost-ball guide, then tap Shoot. Real SpriteKit
//  physics carry the balls, so what the guide predicts is what actually happens.
//

import SpriteKit

final class PoolTableScene: SKScene, SKPhysicsContactDelegate {

    // MARK: - Tuning

    private let ballRadius: CGFloat = 15
    private let cushion: CGFloat = 26          // felt inset from the frame
    private let pocketRadius: CGFloat = 24
    private let maxImpulse: CGFloat = 46       // impulse at power == 1

    // MARK: - Physics categories

    private struct Category {
        static let ball: UInt32   = 0x1 << 0
        static let cushion: UInt32 = 0x1 << 1
        static let pocket: UInt32 = 0x1 << 2
    }

    // MARK: - State

    weak var model: GameModel?

    private var cueBall: SKShapeNode!
    private var objectBalls: [SKShapeNode] = []
    private let guideLayer = SKNode()
    private var aimDirection = CGVector(dx: 0, dy: 1)
    private var feltRect: CGRect = .zero        // playable felt (inside cushions)

    // MARK: - Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.10, green: 0.11, blue: 0.13, alpha: 1)
        scaleMode = .resizeFill
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        guideLayer.zPosition = 50
        addChild(guideLayer)
        buildTable()
        installCommands()
        rackTriangle()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 0, size.height > 0, cueBall != nil else { return }
        rebuildForCurrentSize()
    }

    // MARK: - Table construction

    private func buildTable() {
        feltRect = CGRect(x: cushion,
                          y: cushion,
                          width: size.width - cushion * 2,
                          height: size.height - cushion * 2)

        // Felt
        let felt = SKShapeNode(rect: feltRect, cornerRadius: 12)
        felt.fillColor = SKColor(red: 0.05, green: 0.42, blue: 0.28, alpha: 1)
        felt.strokeColor = SKColor(red: 0.30, green: 0.20, blue: 0.10, alpha: 1)
        felt.lineWidth = cushion
        felt.zPosition = -10
        felt.name = "felt"
        addChild(felt)

        // Cushion collision: an edge loop one ball-radius inside the felt so
        // ball *centers* bounce exactly where the aim math predicts.
        let bounds = feltRect.insetBy(dx: ballRadius, dy: ballRadius)
        let body = SKPhysicsBody(edgeLoopFrom: bounds)
        body.categoryBitMask = Category.cushion
        body.friction = 0.1
        body.restitution = 0.92
        physicsBody = body

        addPockets()
    }

    private func addPockets() {
        let r = feltRect
        let spots = [
            CGPoint(x: r.minX, y: r.minY), CGPoint(x: r.minX, y: r.maxY),
            CGPoint(x: r.maxX, y: r.minY), CGPoint(x: r.maxX, y: r.maxY),
            CGPoint(x: r.minX, y: r.midY), CGPoint(x: r.maxX, y: r.midY)
        ]
        for spot in spots {
            let pocket = SKShapeNode(circleOfRadius: pocketRadius)
            pocket.position = spot
            pocket.fillColor = .black
            pocket.strokeColor = SKColor(white: 0.15, alpha: 1)
            pocket.zPosition = -5
            pocket.name = "pocket"
            let pb = SKPhysicsBody(circleOfRadius: pocketRadius * 0.6)
            pb.isDynamic = false
            pb.categoryBitMask = Category.pocket
            pb.contactTestBitMask = Category.ball
            pb.collisionBitMask = 0
            pocket.physicsBody = pb
            addChild(pocket)
        }
    }

    // MARK: - Balls

    private func makeBall(color: SKColor, name: String) -> SKShapeNode {
        let ball = SKShapeNode(circleOfRadius: ballRadius)
        ball.fillColor = color
        ball.strokeColor = SKColor(white: 0, alpha: 0.25)
        ball.lineWidth = 1
        ball.name = name
        ball.zPosition = 10

        let body = SKPhysicsBody(circleOfRadius: ballRadius)
        body.categoryBitMask = Category.ball
        body.collisionBitMask = Category.ball | Category.cushion
        body.contactTestBitMask = Category.pocket
        body.restitution = 0.95
        body.friction = 0.2
        body.linearDamping = 1.6      // felt rolling resistance
        body.angularDamping = 2.0
        body.allowsRotation = true
        ball.physicsBody = body
        return ball
    }

    /// Rack the 15 object balls in a triangle at the foot spot, cue on the head spot.
    private func rackTriangle() {
        clearBalls()

        let colors: [SKColor] = [
            .systemYellow, .systemBlue, .systemRed, .systemPurple, .systemOrange,
            .systemGreen, .brown, .black, .systemYellow, .systemBlue,
            .systemRed, .systemPurple, .systemOrange, .systemGreen, .brown
        ]

        let footY = feltRect.midY + feltRect.height * 0.22
        let spacing = ballRadius * 2 + 1
        let rowDy = spacing * 0.866
        var index = 0
        for row in 0..<5 {
            let ballsInRow = row + 1
            let rowY = footY + CGFloat(row) * rowDy
            let startX = feltRect.midX - CGFloat(row) * spacing / 2
            for col in 0..<ballsInRow {
                let ball = makeBall(color: colors[index], name: "obj\(index)")
                ball.position = CGPoint(x: startX + CGFloat(col) * spacing, y: rowY)
                addChild(ball)
                objectBalls.append(ball)
                index += 1
            }
        }

        cueBall = makeBall(color: .white, name: "cue")
        cueBall.position = CGPoint(x: feltRect.midX,
                                   y: feltRect.midY - feltRect.height * 0.28)
        addChild(cueBall)

        redrawGuides()
    }

    /// A looser, break-style scatter for varied practice.
    private func breakLayout() {
        rackTriangle()
        for ball in objectBalls {
            let dx = CGFloat.random(in: -1...1)
            let dy = CGFloat.random(in: -1...1)
            ball.physicsBody?.applyImpulse(CGVector(dx: dx * 6, dy: dy * 6))
        }
    }

    private func clearBalls() {
        objectBalls.forEach { $0.removeFromParent() }
        objectBalls.removeAll()
        cueBall?.removeFromParent()
        cueBall = nil
    }

    private func rebuildForCurrentSize() {
        childNode(withName: "felt")?.removeFromParent()
        children.filter { $0.name == "pocket" }.forEach { $0.removeFromParent() }
        physicsBody = nil
        buildTable()
        rackTriangle()
    }

    // MARK: - UI commands

    private func installCommands() {
        model?.shootAction = { [weak self] in self?.shoot() }
        model?.resetRackAction = { [weak self] in self?.rackTriangle() }
        model?.breakLayoutAction = { [weak self] in self?.breakLayout() }
    }

    private func shoot() {
        guard let cueBall, isSettled() else { return }
        let power = model?.power ?? 0.5
        let dir = AimCalculator.normalize(aimDirection)
        let impulse = CGVector(dx: dir.dx * maxImpulse * power,
                               dy: dir.dy * maxImpulse * power)
        cueBall.physicsBody?.applyImpulse(impulse)
        guideLayer.removeAllChildren()
    }

    // MARK: - Aiming input

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateAim(for: touches)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateAim(for: touches)
    }

    private func updateAim(for touches: Set<UITouch>) {
        guard let touch = touches.first, let cueBall, isSettled() else { return }
        let p = touch.location(in: self)
        let v = CGVector(dx: p.x - cueBall.position.x, dy: p.y - cueBall.position.y)
        if v.dx != 0 || v.dy != 0 {
            aimDirection = AimCalculator.normalize(v)
            redrawGuides()
        }
    }

    // MARK: - Guides

    private func redrawGuides() {
        guideLayer.removeAllChildren()
        guard let cueBall, model?.showGuides ?? true, isSettled() else {
            updateCutAngleText(nil)
            return
        }

        let targets = objectBalls.enumerated().map {
            AimCalculator.Target(index: $0.offset, center: $0.element.position)
        }
        let centerBounds = feltRect.insetBy(dx: ballRadius, dy: ballRadius)
        let result = AimCalculator.compute(origin: cueBall.position,
                                           direction: aimDirection,
                                           ballRadius: ballRadius,
                                           targets: targets,
                                           centerBounds: centerBounds)

        // Cue path: cue ball → contact point.
        drawLine(from: cueBall.position, to: result.ghostCenter,
                 color: SKColor(white: 1, alpha: 0.9), width: 2)

        switch result.kind {
        case .ball:
            // Ghost ball outline at the contact point.
            let ghost = SKShapeNode(circleOfRadius: ballRadius)
            ghost.position = result.ghostCenter
            ghost.strokeColor = SKColor(white: 1, alpha: 0.85)
            ghost.lineWidth = 1.5
            ghost.fillColor = SKColor(white: 1, alpha: 0.08)
            ghost.zPosition = 51
            guideLayer.addChild(ghost)

            // Predicted object-ball direction, drawn from the ball itself.
            if let objDir = result.objectDirection, let idx = result.targetIndex {
                let from = objectBalls[idx].position
                let to = CGPoint(x: from.x + objDir.dx * 140, y: from.y + objDir.dy * 140)
                drawLine(from: from, to: to,
                         color: SKColor.systemYellow.withAlphaComponent(0.9), width: 2.5)
            }
            updateCutAngleText(result.cutAngleDegrees)

        case .cushion:
            // Reflection preview off the rail.
            if let reflect = result.reflectDirection {
                let to = CGPoint(x: result.ghostCenter.x + reflect.dx * 120,
                                 y: result.ghostCenter.y + reflect.dy * 120)
                drawDashedLine(from: result.ghostCenter, to: to,
                               color: SKColor(white: 1, alpha: 0.5), width: 1.5)
            }
            updateCutAngleText(nil)

        case .none:
            updateCutAngleText(nil)
        }

        drawCueStick()
    }

    private func drawCueStick() {
        guard let cueBall else { return }
        let back = CGPoint(x: cueBall.position.x - aimDirection.dx * (ballRadius + 8),
                           y: cueBall.position.y - aimDirection.dy * (ballRadius + 8))
        let tail = CGPoint(x: cueBall.position.x - aimDirection.dx * 160,
                           y: cueBall.position.y - aimDirection.dy * 160)
        drawLine(from: back, to: tail,
                 color: SKColor(red: 0.80, green: 0.62, blue: 0.35, alpha: 0.95), width: 4)
    }

    private func drawLine(from: CGPoint, to: CGPoint, color: SKColor, width: CGFloat) {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        let node = SKShapeNode(path: path)
        node.strokeColor = color
        node.lineWidth = width
        node.lineCap = .round
        node.zPosition = 51
        guideLayer.addChild(node)
    }

    private func drawDashedLine(from: CGPoint, to: CGPoint, color: SKColor, width: CGFloat) {
        let path = CGMutablePath()
        path.move(to: from)
        path.addLine(to: to)
        let dashed = path.copy(dashingWithPhase: 0, lengths: [8, 6])
        let node = SKShapeNode(path: dashed)
        node.strokeColor = color
        node.lineWidth = width
        node.zPosition = 51
        guideLayer.addChild(node)
    }

    private func updateCutAngleText(_ degrees: CGFloat?) {
        DispatchQueue.main.async { [weak self] in
            if let degrees {
                self?.model?.cutAngleText = String(format: "%.0f°", degrees)
            } else {
                self?.model?.cutAngleText = "—"
            }
        }
    }

    // MARK: - Simulation bookkeeping

    private func isSettled() -> Bool {
        let threshold: CGFloat = 4
        if let v = cueBall?.physicsBody?.velocity, hypot(v.dx, v.dy) > threshold { return false }
        for ball in objectBalls {
            if let v = ball.physicsBody?.velocity, hypot(v.dx, v.dy) > threshold { return false }
        }
        return true
    }

    private var lastSettled = true

    override func update(_ currentTime: TimeInterval) {
        let settled = isSettled()
        if settled != lastSettled {
            lastSettled = settled
            DispatchQueue.main.async { [weak self] in self?.model?.isSettled = settled }
            if settled { redrawGuides() }   // refresh the guide once balls stop
        }
    }

    // MARK: - Pocketing

    func didBegin(_ contact: SKPhysicsContact) {
        let bodies = [contact.bodyA, contact.bodyB]
        guard let ballBody = bodies.first(where: { $0.categoryBitMask == Category.ball }),
              bodies.contains(where: { $0.categoryBitMask == Category.pocket }),
              let node = ballBody.node as? SKShapeNode else { return }

        if node.name == "cue" {
            // Scratch: respot the cue ball on the head spot.
            node.physicsBody?.velocity = .zero
            node.physicsBody?.angularVelocity = 0
            node.position = CGPoint(x: feltRect.midX,
                                    y: feltRect.midY - feltRect.height * 0.28)
        } else {
            node.removeFromParent()
            objectBalls.removeAll { $0 === node }
        }
    }
}
