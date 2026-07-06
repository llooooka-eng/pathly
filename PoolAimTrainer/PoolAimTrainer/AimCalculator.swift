//
//  AimCalculator.swift
//  PoolAimTrainer
//
//  Pure-geometry aiming solver. Given the cue ball position and an aim
//  direction, it works out what the cue ball hits first (an object ball or a
//  cushion) and — crucially for practice — where the "ghost ball" sits and in
//  which direction the struck object ball will travel. No SpriteKit here so the
//  math stays testable and reusable.
//

import Foundation
import CoreGraphics

/// Result of casting an aim ray from the cue ball.
struct AimResult {
    enum Kind {
        case ball       // the ray reaches an object ball
        case cushion    // the ray reaches a cushion first
        case none       // nothing in range (shouldn't happen inside a closed table)
    }

    var kind: Kind = .none
    /// Distance the cue-ball *center* travels until contact.
    var travel: CGFloat = 0
    /// Where the cue-ball center is at the moment of contact (the "ghost ball").
    var ghostCenter: CGPoint = .zero
    /// Predicted travel direction of the struck object ball (unit vector).
    var objectDirection: CGVector?
    /// Reflection direction when the cue hits a cushion (unit vector).
    var reflectDirection: CGVector?
    /// Index of the object ball that would be struck.
    var targetIndex: Int?
    /// The "cut angle" between the cue path and the object-ball path, in degrees.
    var cutAngleDegrees: CGFloat?
}

enum AimCalculator {

    /// A tiny target for the solver: an object ball's index and center.
    struct Target {
        let index: Int
        let center: CGPoint
    }

    /// Cast an aim ray and return the first meaningful contact.
    ///
    /// - Parameters:
    ///   - origin: cue-ball center.
    ///   - direction: aim direction (need not be normalized).
    ///   - ballRadius: radius of every ball (uniform).
    ///   - targets: the other balls on the table.
    ///   - centerBounds: the rectangle the cue-ball *center* may occupy,
    ///     i.e. the felt inset by one ball radius on every side.
    static func compute(origin: CGPoint,
                        direction: CGVector,
                        ballRadius: CGFloat,
                        targets: [Target],
                        centerBounds: CGRect) -> AimResult {

        let dir = normalize(direction)
        guard dir.dx != 0 || dir.dy != 0 else { return AimResult() }

        var best = AimResult()
        var bestT = CGFloat.greatestFiniteMagnitude

        // --- Ball contacts: cue center meets target center at distance 2R. ---
        let contactDist = ballRadius * 2
        for target in targets {
            if let t = rayCircleFirstHit(origin: origin,
                                         dir: dir,
                                         center: target.center,
                                         radius: contactDist),
               t > 0.001, t < bestT {
                bestT = t
                let ghost = point(origin, dir, t)
                let objDir = normalize(CGVector(dx: target.center.x - ghost.x,
                                                dy: target.center.y - ghost.y))
                best = AimResult(kind: .ball,
                                 travel: t,
                                 ghostCenter: ghost,
                                 objectDirection: objDir,
                                 reflectDirection: nil,
                                 targetIndex: target.index,
                                 cutAngleDegrees: angleBetween(dir, objDir))
            }
        }

        // --- Cushion contact: first exit through the inset play rectangle. ---
        if let cushion = rayRectFirstHit(origin: origin, dir: dir, rect: centerBounds),
           cushion.t > 0.001, cushion.t < bestT {
            bestT = cushion.t
            best = AimResult(kind: .cushion,
                             travel: cushion.t,
                             ghostCenter: cushion.point,
                             objectDirection: nil,
                             reflectDirection: cushion.reflect,
                             targetIndex: nil,
                             cutAngleDegrees: nil)
        }

        return best
    }

    // MARK: - Ray / circle

    /// Nearest positive `t` where `origin + dir*t` is `radius` away from `center`.
    private static func rayCircleFirstHit(origin: CGPoint,
                                          dir: CGVector,
                                          center: CGPoint,
                                          radius: CGFloat) -> CGFloat? {
        let fx = origin.x - center.x
        let fy = origin.y - center.y
        // a == 1 because dir is normalized.
        let b = 2 * (dir.dx * fx + dir.dy * fy)
        let c = fx * fx + fy * fy - radius * radius
        let disc = b * b - 4 * c
        if disc < 0 { return nil }
        let sqrtDisc = disc.squareRoot()
        let t0 = (-b - sqrtDisc) / 2
        let t1 = (-b + sqrtDisc) / 2
        if t0 > 0 { return t0 }
        if t1 > 0 { return t1 }
        return nil
    }

    // MARK: - Ray / rectangle (interior → boundary)

    private struct RectHit {
        let t: CGFloat
        let point: CGPoint
        let reflect: CGVector
    }

    /// First boundary the ray reaches when starting inside `rect`.
    private static func rayRectFirstHit(origin: CGPoint,
                                        dir: CGVector,
                                        rect: CGRect) -> RectHit? {
        var bestT = CGFloat.greatestFiniteMagnitude
        var reflect = dir

        // Vertical walls (flip dx).
        if dir.dx > 0 {
            let t = (rect.maxX - origin.x) / dir.dx
            if t > 0, t < bestT { bestT = t; reflect = CGVector(dx: -dir.dx, dy: dir.dy) }
        } else if dir.dx < 0 {
            let t = (rect.minX - origin.x) / dir.dx
            if t > 0, t < bestT { bestT = t; reflect = CGVector(dx: -dir.dx, dy: dir.dy) }
        }
        // Horizontal walls (flip dy).
        if dir.dy > 0 {
            let t = (rect.maxY - origin.y) / dir.dy
            if t > 0, t < bestT { bestT = t; reflect = CGVector(dx: dir.dx, dy: -dir.dy) }
        } else if dir.dy < 0 {
            let t = (rect.minY - origin.y) / dir.dy
            if t > 0, t < bestT { bestT = t; reflect = CGVector(dx: dir.dx, dy: -dir.dy) }
        }

        if bestT == .greatestFiniteMagnitude { return nil }
        return RectHit(t: bestT, point: point(origin, dir, bestT), reflect: normalize(reflect))
    }

    // MARK: - Small vector helpers

    static func normalize(_ v: CGVector) -> CGVector {
        let len = (v.dx * v.dx + v.dy * v.dy).squareRoot()
        guard len > 0 else { return CGVector(dx: 0, dy: 0) }
        return CGVector(dx: v.dx / len, dy: v.dy / len)
    }

    private static func point(_ o: CGPoint, _ d: CGVector, _ t: CGFloat) -> CGPoint {
        CGPoint(x: o.x + d.dx * t, y: o.y + d.dy * t)
    }

    /// Angle between two unit vectors, in degrees (0…180).
    static func angleBetween(_ a: CGVector, _ b: CGVector) -> CGFloat {
        // Compute in Double to avoid CGFloat `acos` overload ambiguity.
        let dot = max(-1.0, min(1.0, Double(a.dx * b.dx + a.dy * b.dy)))
        return CGFloat(acos(dot) * 180.0 / Double.pi)
    }
}
