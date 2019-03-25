//
//  ViewController.swift
//  Plane Detection
//
//  Created by Denis Bystruev on 25/03/2019.
//  Copyright © 2019 Denis Bystruev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = [.horizontal]

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

// MARK: - ... ARSCNViewDelegate
extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        node.addChildNode(createFloor(planeAnchor: anchor))
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let anchor = anchor as? ARPlaneAnchor else { return }
        guard let planeNode = node.childNodes.first else { return }
        guard let plane = planeNode.geometry as? SCNPlane else { return }
        guard planeNode.name == "Plane" else { return }
        
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        let extent = anchor.extent
        plane.width = CGFloat(extent.x)
        plane.height = CGFloat(extent.z)
    }
}

// MARK: - ... Custom Methods
extension ViewController {
    func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let extent = planeAnchor.extent
        
        let node = SCNNode()
        node.name = "Plane"
        
        let plane = SCNPlane(width: CGFloat(extent.x), height: CGFloat(extent.z))
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        node.geometry = plane
        
        node.eulerAngles.x = -.pi / 2
        node.opacity = 0.25
        
        return node
    }
}
