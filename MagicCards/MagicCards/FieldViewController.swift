//
//  FieldViewController.swift
//  MagicCards
//
//  Created by Julianny Favinha on 7/16/18.
//  Copyright © 2018 Julianny Favinha. All rights reserved.
//

import UIKit
import ARKit

enum AppState: Int16 {
    case lookingForSurface
    case pointToSurface
    case readyToBattle
}

class FieldViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var status: UILabel!
    
    var deckSettings: DeckSettings!
    
    var appState: AppState = .lookingForSurface
    var statusMessage = ""
    var trackingStatus = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let customTabBarController = self.tabBarController as! CustomTabBarController
        deckSettings = customTabBarController.deckSettings
        
        initSceneView()
        initARSession()
        initGestureRecognizers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Intializers
    // ===================
    
    func initSceneView() {
        sceneView.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.showsStatistics = true
        sceneView.preferredFramesPerSecond = 60
        sceneView.antialiasingMode = .multisampling2X
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
    }
    
    func createARConfiguration() -> ARConfiguration {
        let config = ARWorldTrackingConfiguration()
        config.worldAlignment = .gravity
        config.planeDetection = [.horizontal]
        config.isLightEstimationEnabled = true
        config.providesAudioData = false
        return config
    }
    
    func initARSession() {
        guard ARWorldTrackingConfiguration.isSupported else {
            print("*** ARConfig: AR World Tracking Not Supported")
            return
        }
        
        let config = createARConfiguration()
        sceneView.session.run(config)
    }
    
    func resetARsession() {
        let config = createARConfiguration()
        sceneView.session.run(config,
                              options: [.resetTracking,
                                        .removeExistingAnchors])
        appState = .lookingForSurface
    }
    
    // MARK: - App status
    // ==================
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            self.updateAppState()
            self.updateStatusText()
        }
    }
    
    func updateAppState() {
        guard appState == .pointToSurface || appState == .readyToBattle else { return }
        
        if isAnyPlaneInView() {
            appState = .readyToBattle
        } else {
            appState = .pointToSurface
        }
    }
    
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .notAvailable:
            trackingStatus = "For some reason, augmented reality tracking isn’t available."
        case .normal:
            trackingStatus = ""
        case .limited(let reason):
            switch reason {
            case .excessiveMotion:
                trackingStatus = "You’re moving the device around too quickly. Slow down."
            case .insufficientFeatures:
                trackingStatus = "I can’t get a sense of the room. Is something blocking the rear camera?"
            case .initializing:
                trackingStatus = "Initializing — please wait a moment..."
            case .relocalizing:
                trackingStatus = "Relocalizing — please wait a moment..."
            }
        }
    }
    
    func updateStatusText() {
        switch appState {
        case .lookingForSurface:
            statusMessage = "Scan the room with your device until the yellow dots appear."
            sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        case .pointToSurface:
            statusMessage = "Point your device towards one of the detected surfaces."
            sceneView.debugOptions = []
        case .readyToBattle:
            statusMessage = "Tap on the floor grid to place the card."
            sceneView.debugOptions = []
        }
        
        status.text = trackingStatus != "" ? "\(trackingStatus)" : "\(statusMessage)"
    }
    
    func isAnyPlaneInView() -> Bool {
        let screenDivisions = 5 - 1
        let viewWidth = view.bounds.size.width
        let viewHeight = view.bounds.size.height
        
        for y in 0...screenDivisions {
            let yCoord = CGFloat(y) / CGFloat(screenDivisions) * viewHeight
            for x in 0...screenDivisions {
                let xCoord = CGFloat(x) / CGFloat(screenDivisions) * viewWidth
                let point = CGPoint(x: xCoord, y: yCoord)
                
                // Perform hit test for planes.
                let hitTest = sceneView.hitTest(point, types: .existingPlaneUsingExtent)
                if !hitTest.isEmpty {
                    return true
                }
                
            }
        }
        return false
    }
    
    // MARK: - Adding and removing cards
    // =====================================
    
    func initGestureRecognizers() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        sceneView.addGestureRecognizer(tapGestureRecognizer)
        
        sceneView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:))))
    }
    
    @objc func handleScreenTap(sender: UITapGestureRecognizer) {
        // Find out where the user tapped on the screen.
        let tappedSceneView = sender.view as! ARSCNView
        let tapLocation = sender.location(in: tappedSceneView)
        
        // Find all the detected planes that would intersect with
        // a line extending from where the user tapped the screen.
        let planeIntersections = tappedSceneView.hitTest(tapLocation, types: [.existingPlaneUsingGeometry])
        
        // If the closest of those planes is horizontal,
        // put the current furniture item on it.
        if !planeIntersections.isEmpty {
            let firstHitTestResult = planeIntersections.first!
            guard let planeAnchor = firstHitTestResult.anchor as? ARPlaneAnchor else { return }
            if planeAnchor.alignment == .horizontal {
                addCard(hitTestResult: firstHitTestResult)
            }
        }
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        gesture.minimumNumberOfTouches = 1
        
        let results = self.sceneView.hitTest(gesture.location(in: gesture.view), types: ARHitTestResult.ResultType.featurePoint)
        
        guard let result: ARHitTestResult = results.first else {
            return
        }
        
        let hits = self.sceneView.hitTest(gesture.location(in: gesture.view), options: nil)
        if let tappedNode = hits.first?.node {
            if (CardNode.isNodePartOfCardNode(tappedNode)) {
                let position = SCNVector3Make(result.worldTransform.columns.3.x, result.worldTransform.columns.3.y, result.worldTransform.columns.3.z)
                tappedNode.position = position
            }
        }
    }
    
    func addCard(hitTestResult: ARHitTestResult) {
        // Get the real-world position corresponding to
        // where the user tapped on the screen.
        let transform = hitTestResult.worldTransform
        let positionColumn = transform.columns.3 // 4th column; column index starts at 0
        let initialPosition = SCNVector3(positionColumn.x, positionColumn.y, positionColumn.z)
        
        // Get the current card item, correct its position if necessary,
        // and add it to the scene.
        let node = deckSettings.currentCardPiece()
        node.position = initialPosition
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    // MARK: - AR session error management
    // ===================================
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        trackingStatus = "AR session failure: \(error)"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        trackingStatus = "AR session was interrupted!"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        trackingStatus = "AR session interruption ended."
        resetARsession()
    }
    
    // MARK: - Plane detection
    // =======================
    
    // This delegate method gets called whenever the node corresponding to
    // a new AR anchor is added to the scene.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // We only want to deal with plane anchors, which encapsulate
        // the position, orientation, and size, of a detected surface.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Draw the appropriate plane over the detected surface.
        drawPlaneNode(on: node, for: planeAnchor)
    }
    
    // This delegate method gets called whenever the node correspondinf to
    // an existing AR anchor is updated.
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        // Once again, we only want to deal with plane anchors.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Remove any children this node may have.
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
        
        // Update the plane over this surface.
        drawPlaneNode(on: node, for: planeAnchor)
    }
    
    func drawPlaneNode(on node: SCNNode, for planeAnchor: ARPlaneAnchor) {
        // Create a plane node with the same position and size
        // as the detected plane.
        let planeNode = SCNNode(geometry: SCNPlane(
            width: CGFloat(planeAnchor.extent.x),
            height: CGFloat(planeAnchor.extent.z)
        ))
        planeNode.position = SCNVector3(planeAnchor.center.x,
                                        planeAnchor.center.y,
                                        planeAnchor.center.z)
        planeNode.geometry?.firstMaterial?.isDoubleSided = true
        
        // Align the plane with the anchor.
        planeNode.eulerAngles = SCNVector3(-Double.pi / 2, 0, 0)
        
        // Give the plane node the appropriate surface.
        if planeAnchor.alignment == .horizontal {
            planeNode.geometry?.firstMaterial?.diffuse.contents = UIImage(named: "grid")
            planeNode.name = "horizontal"
        }
        
        // Add the plane node to the scene.
        node.addChildNode(planeNode)
        
        /// Add floor node to the scene
        let scene = SCNScene(named: "art.scnassets/card.scn")
        let plane = (scene?.rootNode.childNode(withName: "plane", recursively: false))!
        node.addChildNode(plane)
        
        appState = .readyToBattle
    }

    // This delegate method gets called whenever the node corresponding to
    // an existing AR anchor is removed.
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        // We only want to deal with plane anchors.
        guard anchor is ARPlaneAnchor else { return }
        
        // Remove any children this node may have.
        node.enumerateChildNodes { (childNode, _) in
            childNode.removeFromParentNode()
        }
    }
    
}
