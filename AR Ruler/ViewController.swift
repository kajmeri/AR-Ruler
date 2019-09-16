//
//  ViewController.swift
//  AR Ruler
//
//  Created by Krishna Ajmeri on 9/16/19.
//  Copyright © 2019 Krishna Ajmeri. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
	
	//MARK: - Variable Declaration
	
	@IBOutlet var sceneView: ARSCNView!
	var dotsArray = [SCNNode]()
	var textNode = SCNNode()
	
	//MARK: - View Methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		sceneView.delegate = self
		sceneView.autoenablesDefaultLighting = true
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		// Create a session configuration
		let configuration = ARWorldTrackingConfiguration()
		
		configuration.planeDetection = .horizontal
		
		// Run the view's session
		sceneView.session.run(configuration)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		
		// Pause the view's session
		sceneView.session.pause()
	}
	
	//MARK: - Touch/Motion Methods
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		if dotsArray.count >= 2 {
			for dot in dotsArray {
				dot.removeFromParentNode()
			}
			dotsArray = [SCNNode]()
		}
		
		if let touchLocation = touches.first?.location(in: sceneView) {
			
			let results = sceneView.hitTest(touchLocation, types: .featurePoint)
			
			if let hitResult = results.first {
				addDot(at: hitResult)
			}
		}
	}
	
	override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
		
	}
	
	//MARK: - Dice Rendering Methods
	
	func addDot(at location: ARHitTestResult) {
		
		let dotGeometry = SCNSphere(radius: 0.005)
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.red
		
		dotGeometry.materials = [material]
		
		let dotNode = SCNNode(geometry: dotGeometry)
		
		dotNode.position = SCNVector3(
			x: location.worldTransform.columns.3.x,
			y: location.worldTransform.columns.3.y + dotNode.boundingSphere.radius,
			z: location.worldTransform.columns.3.z
		)
		
		dotsArray.append(dotNode)
		
		sceneView.scene.rootNode.addChildNode(dotNode)
		
		if dotsArray.count >= 2 {
			calculate()
		}
		
	}
	
	func calculate() {
		let start = dotsArray[0]
		let end = dotsArray[1]
		
		let distance = sqrt(
			pow(end.position.x - start.position.x, 2) +
			pow(end.position.y - start.position.y, 2) +
			pow(end.position.z - start.position.z, 2)
		) / 0.0254
		
		updateText(text: String(format: "%.2f in.", distance), atPosition: end.position)
		
	}
	
	func updateText(text: String, atPosition position: SCNVector3) {
		
		textNode.removeFromParentNode()
		
		let textGeometry = SCNText(string: text, extrusionDepth: 1.0)
		
		textGeometry.firstMaterial?.diffuse.contents = UIColor.blue
		
		textNode = SCNNode(geometry: textGeometry)
		
		textNode.position = SCNVector3(position.x, position.y + 0.01, position.z)
		
		textNode.scale = SCNVector3(0.005, 0.005, 0.005)
		
		sceneView.scene.rootNode.addChildNode(textNode)
	}
}
