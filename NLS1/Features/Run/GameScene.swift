//
//  GameScene.swift
//  NLS1
//

import SpriteKit
import SwiftUI
import UIKit

final class GameScene: SKScene {
    var config: LevelConfig?
    var onGameOver: ((Double, Double, Int) -> Void)?

    private var playerNode: SKShapeNode!
    private var laneCount: Int = 3
    private var laneWidth: CGFloat = 0
    private var currentLane: Int = 0
    private var lastSpawnTime: TimeInterval = 0
    private var spawnRate: TimeInterval = 1.2
    private var targetSpeed: CGFloat = 1.5
    private var obstacles: [SKNode] = []
    private var shots: [SKNode] = []
    private var targets: [SKNode] = []
    private var startTime: TimeInterval = 0
    private var shotsFired: Int = 0
    private var shotsHit: Int = 0
    private var cleanDodges: Int = 0
    private var charge: CGFloat = 0
    private var overdriveActive: Bool = false
    private var overdriveEndTime: TimeInterval = 0
    private var chargeNode: SKShapeNode?
    private var overdriveButton: SKShapeNode?
    private var hitRecently: Bool = false
    private var gameEnded: Bool = false

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        scaleMode = .resizeFill
        physicsWorld.gravity = .zero

        laneCount = config?.laneCount ?? 3
        spawnRate = 1.0 / (config?.spawnRate ?? 1.0)
        targetSpeed = CGFloat(config?.targetSpeed ?? 1.5) * 60
        startTime = CACurrentMediaTime()

        let w = size.width
        let h = size.height
        laneWidth = w / CGFloat(laneCount)

        // Background layer (gradient + stars + lane guides)
        buildGameBackground(width: w, height: h)

        // Player (Sproutship silhouette)
        playerNode = sproutshipNode()
        playerNode.position = CGPoint(x: laneCenterX(for: 0), y: h * 0.2)
        playerNode.zPosition = 10
        addChild(playerNode)
        currentLane = 0

        // Charge bar
        let barW: CGFloat = 120
        let barH: CGFloat = 8
        let barBg = SKShapeNode(rect: CGRect(x: -barW/2, y: -barH/2, width: barW, height: barH), cornerRadius: 2)
        barBg.strokeColor = .clear
        barBg.fillColor = SKColor(white: 0.2, alpha: 0.8)
        barBg.position = CGPoint(x: w/2, y: h - 50)
        barBg.zPosition = 100
        addChild(barBg)
        chargeNode = SKShapeNode(rect: CGRect(x: -barW/2, y: -barH/2, width: 0, height: barH), cornerRadius: 2)
        chargeNode?.strokeColor = .clear
        chargeNode?.fillColor = SKColor(red: 0.1, green: 0.83, blue: 0.54, alpha: 1)
        chargeNode?.position = CGPoint(x: w/2, y: h - 50)
        chargeNode?.zPosition = 101
        if let c = chargeNode { addChild(c) }

        // Overdrive button
        let btn = SKShapeNode(circleOfRadius: 28)
        btn.strokeColor = SKColor(red: 0.96, green: 0.78, blue: 0.29, alpha: 1)
        btn.fillColor = SKColor(white: 0.1, alpha: 0.9)
        btn.position = CGPoint(x: w - 50, y: 50)
        btn.zPosition = 100
        btn.name = "overdrive"
        addChild(btn)
        overdriveButton = btn
    }

    private func laneCenterX(for lane: Int) -> CGFloat {
        laneWidth * (CGFloat(lane) + 0.5)
    }

    private func buildGameBackground(width w: CGFloat, height h: CGFloat) {
        let bgZ: CGFloat = -10

        // 1) Gradient texture (emerald deep → slightly lighter top)
        let gradientNode = SKSpriteNode(texture: SKTexture(image: Self.makeGradientImage(width: w, height: h)))
        gradientNode.position = CGPoint(x: w / 2, y: h / 2)
        gradientNode.zPosition = bgZ
        gradientNode.size = CGSize(width: w, height: h)
        addChild(gradientNode)

        // 2) Subtle radial glows (nebula accent)
        let glowClover = SKShapeNode(circleOfRadius: w * 0.6)
        glowClover.position = CGPoint(x: w * 0.25, y: h * 0.2)
        glowClover.fillColor = SKColor(red: 0.1, green: 0.83, blue: 0.54, alpha: 0.08)
        glowClover.strokeColor = .clear
        glowClover.zPosition = bgZ + 0.5
        addChild(glowClover)
        let glowCyan = SKShapeNode(circleOfRadius: w * 0.45)
        glowCyan.position = CGPoint(x: w * 0.8, y: h * 0.75)
        glowCyan.fillColor = SKColor(red: 0.27, green: 0.84, blue: 1, alpha: 0.06)
        glowCyan.strokeColor = .clear
        glowCyan.zPosition = bgZ + 0.5
        addChild(glowCyan)

        // 3) Starfield (deterministic positions)
        let starPositions: [(CGFloat, CGFloat)] = Self.gameStarPositions
        for (nx, ny) in starPositions {
            let star = SKShapeNode(circleOfRadius: 1.2)
            star.position = CGPoint(x: nx * w, y: ny * h)
            star.fillColor = SKColor(white: 0.95, alpha: 0.35 + (nx * 0.15))
            star.strokeColor = .clear
            star.zPosition = bgZ + 1
            addChild(star)
        }

        // 4) Lane divider lines (vertical, subtle)
        for i in 1..<laneCount {
            let x = laneWidth * CGFloat(i)
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: CGPoint(x: x, y: 0))
            path.addLine(to: CGPoint(x: x, y: h))
            line.path = path
            line.strokeColor = SKColor(red: 0.1, green: 0.83, blue: 0.54, alpha: 0.12)
            line.lineWidth = 1
            line.zPosition = bgZ + 2
            addChild(line)
        }
    }

    private static func makeGradientImage(width w: CGFloat, height h: CGFloat) -> UIImage {
        let size = CGSize(width: max(1, w), height: max(1, h))
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cg = ctx.cgContext
            let colors = [
                UIColor(red: 0.04, green: 0.18, blue: 0.14, alpha: 1).cgColor,
                UIColor(red: 0.05, green: 0.16, blue: 0.12, alpha: 1).cgColor,
                UIColor(red: 0.03, green: 0.12, blue: 0.09, alpha: 1).cgColor
            ] as CFArray
            let space = CGColorSpaceCreateDeviceRGB()
            guard let gradient = CGGradient(colorsSpace: space, colors: colors, locations: [0, 0.5, 1]) else { return }
            cg.drawLinearGradient(
                gradient,
                start: CGPoint(x: w / 2, y: h),
                end: CGPoint(x: w / 2, y: 0),
                options: []
            )
        }
    }

    private static let gameStarPositions: [(CGFloat, CGFloat)] = {
        var result: [(CGFloat, CGFloat)] = []
        var seed: UInt64 = 123456
        for _ in 0..<48 {
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let x = CGFloat(seed % 10000) / 10000
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let y = CGFloat(seed % 10000) / 10000
            result.append((x, y))
        }
        return result
    }()

    private func sproutshipNode() -> SKShapeNode {
        let path = CGMutablePath()
        let w: CGFloat = 24
        let h: CGFloat = 18
        path.move(to: CGPoint(x: -w*0.45, y: h*0.35))
        path.addQuadCurve(to: CGPoint(x: 0, y: -h*0.45), control: CGPoint(x: -w*0.5, y: -h*0.1))
        path.addQuadCurve(to: CGPoint(x: w*0.45, y: h*0.35), control: CGPoint(x: w*0.5, y: -h*0.1))
        path.addLine(to: CGPoint(x: w*0.25, y: h*0.4))
        path.addQuadCurve(to: CGPoint(x: -w*0.25, y: h*0.4), control: CGPoint(x: 0, y: h*0.5))
        path.closeSubpath()
        let node = SKShapeNode(path: path)
        node.strokeColor = SKColor(white: 0.9, alpha: 0.6)
        node.fillColor = SKColor(red: 0.07, green: 0.2, blue: 0.12, alpha: 1)
        node.glowWidth = 2
        return node
    }

    override func update(_ currentTime: TimeInterval) {
        if gameEnded { return }
        if overdriveActive {
            if currentTime >= overdriveEndTime {
                overdriveActive = false
                hitRecently = false
            }
        }

        // Spawn
        if lastSpawnTime == 0 { lastSpawnTime = currentTime }
        let rate = overdriveActive ? spawnRate * 1.5 : spawnRate
        if currentTime - lastSpawnTime > rate {
            lastSpawnTime = currentTime
            spawnObstacle(at: currentTime)
        }

        let speed: CGFloat = overdriveActive ? targetSpeed * 0.5 : targetSpeed
        let dy = speed * 0.016

        // Move obstacles down
        for node in obstacles {
            node.position.y -= dy
            if node.position.y < -50 {
                node.removeFromParent()
                obstacles.removeAll { $0 == node }
                if node.name == "bramble" || node.name == "flux" {
                    cleanDodges += 1
                }
            }
        }
        for node in targets {
            node.position.y -= dy
            if node.position.y < -50 {
                node.removeFromParent()
                targets.removeAll { $0 == node }
            }
        }
        for node in shots {
            node.position.y += 200 * 0.016
            if node.position.y > size.height + 20 {
                node.removeFromParent()
                shots.removeAll { $0 == node }
            }
        }

        // Collision: player vs obstacles
        let playerRect = CGRect(x: playerNode.position.x - 15, y: playerNode.position.y - 12, width: 30, height: 24)
        for node in obstacles {
            let r = CGRect(x: node.position.x - 12, y: node.position.y - 12, width: 24, height: 24)
            if playerRect.intersects(r) {
                endGame(currentTime)
                return
            }
        }

        // Collision: shots vs targets
        for shot in shots {
            let sr = CGRect(x: shot.position.x - 4, y: shot.position.y - 4, width: 8, height: 8)
            for target in targets {
                let tr = CGRect(x: target.position.x - 12, y: target.position.y - 12, width: 24, height: 24)
                if sr.intersects(tr) {
                    shotsHit += 1
                    if !hitRecently {
                        charge = min(100, charge + 25)
                        hitRecently = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                            self?.hitRecently = false
                        }
                    }
                    shot.removeFromParent()
                    shots.removeAll { $0 == shot }
                    target.removeFromParent()
                    targets.removeAll { $0 == target }
                    break
                }
            }
        }

        // Level complete (win) check — after collisions so counts are up to date
        if let cfg = config {
            let survived = currentTime - startTime
            switch cfg.goalType {
            case .surviveSeconds:
                if survived >= cfg.targetValue {
                    endGame(currentTime)
                    return
                }
            case .accuracyPercent:
                if shotsFired >= 3, Double(shotsHit) / Double(shotsFired) * 100 >= cfg.targetValue {
                    endGame(currentTime)
                    return
                }
            case .noHitStreak:
                if cleanDodges >= Int(cfg.targetValue) {
                    endGame(currentTime)
                    return
                }
            }
        }

        // Update charge bar
        if let bar = chargeNode {
            let fullW: CGFloat = 120
            bar.path = CGPath(rect: CGRect(x: -fullW/2, y: -4, width: fullW * (CGFloat(charge) / 100), height: 8), transform: nil)
        }
    }

    private func spawnObstacle(at time: TimeInterval) {
        let lane = Int.random(in: 0..<laneCount)
        let x = laneCenterX(for: lane)
        let y = size.height + 30
        let choice = Int.random(in: 0..<5)
        if choice == 0 {
            let node = SKShapeNode(rectOf: CGSize(width: laneWidth * 0.7, height: 16), cornerRadius: 4)
            node.position = CGPoint(x: x, y: y)
            node.strokeColor = SKColor(red: 0.6, green: 0.3, blue: 0.2, alpha: 1)
            node.fillColor = SKColor(red: 0.3, green: 0.15, blue: 0.1, alpha: 1)
            node.name = "bramble"
            addChild(node)
            obstacles.append(node)
        } else if choice == 1 {
            let node = SKShapeNode(circleOfRadius: 14)
            node.position = CGPoint(x: x, y: y)
            node.strokeColor = SKColor(red: 0.2, green: 0.5, blue: 0.6, alpha: 1)
            node.fillColor = SKColor(red: 0.1, green: 0.3, blue: 0.4, alpha: 0.8)
            node.name = "flux"
            addChild(node)
            obstacles.append(node)
        } else {
            let node = SKShapeNode(ellipseOf: CGSize(width: 28, height: 20))
            node.position = CGPoint(x: x, y: y)
            node.strokeColor = SKColor(red: 0.1, green: 0.83, blue: 0.54, alpha: 1)
            node.fillColor = SKColor(red: 0.05, green: 0.4, blue: 0.3, alpha: 0.9)
            node.name = "drone"
            addChild(node)
            targets.append(node)
        }
    }

    private func endGame(_ currentTime: TimeInterval) {
        guard !gameEnded else { return }
        gameEnded = true
        let survived = currentTime - startTime
        let accuracy = shotsFired > 0 ? Double(shotsHit) / Double(shotsFired) * 100 : 0
        onGameOver?(survived, accuracy, cleanDodges)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)
        let nodesAtPoint = nodes(at: loc)
        if nodesAtPoint.contains(where: { $0.name == "overdrive" }) {
            if charge >= 100 && !overdriveActive {
                charge = 0
                overdriveActive = true
                overdriveEndTime = CACurrentMediaTime() + 3.0
            }
            return
        }
        // Shoot
        let shot = SKShapeNode(circleOfRadius: 4)
        shot.position = CGPoint(x: playerNode.position.x, y: playerNode.position.y + 20)
        shot.fillColor = SKColor(red: 0.27, green: 0.84, blue: 1, alpha: 1)
        shot.strokeColor = .clear
        addChild(shot)
        shots.append(shot)
        shotsFired += 1
    }

    func movePlayer(toLane lane: Int) {
        let clamped = max(0, min(laneCount - 1, lane))
        guard clamped != currentLane else { return }
        currentLane = clamped
        let x = laneCenterX(for: currentLane)
        playerNode.run(SKAction.move(to: CGPoint(x: x, y: playerNode.position.y), duration: 0.12))
    }

    func swipeLeft() {
        movePlayer(toLane: currentLane - 1)
    }

    func swipeRight() {
        movePlayer(toLane: currentLane + 1)
    }
}
