//
//  ViewController.swift
//  WackAJellyfish
//
//  Created by Dean Wahle on 1/18/22.
//

import UIKit
import ARKit
import Each
class ViewController: UIViewController {

    var timerVar = Each(1).seconds
    var countdown = 10
    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var play: UIButton!
    @IBOutlet weak var sceneView: ARSCNView!
    let configuration = ARWorldTrackingConfiguration()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sceneView.debugOptions = [ARSCNDebugOptions.showWorldOrigin, ARSCNDebugOptions.showFeaturePoints]
        self.sceneView.session.run(configuration)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        //make it so tap recognizer will recognize any tap in the scene view
        self.sceneView.addGestureRecognizer(tapGestureRecognizer)
    }

    @IBAction func reset(_ sender: Any) {
        self.timerVar.stop()
        self.restoreTimer()
        self.play.isEnabled = true
        sceneView.scene.rootNode.enumerateChildNodes{ (node, _) in node.removeFromParentNode()}
    }
    @IBAction func play(_ sender: Any) {
        self.setTimer()
        self.addNode()
        self.play.isEnabled = false
    }
    
    func addNode() {
        let jellyFishScene = SCNScene(named: "art.scnassets/Jellyfish.scn")
        let jellyfishNode = jellyFishScene?.rootNode.childNode(withName: "Jellyfish", recursively: false)
        jellyfishNode?.position = SCNVector3(randomNumbers(firstNum: -1, secondNum: 1),randomNumbers(firstNum: -0.5, secondNum: 0.5),randomNumbers(firstNum: -1, secondNum: 1))
        self.sceneView.scene.rootNode.addChildNode(jellyfishNode!)
    }
    @objc func handleTap(sender: UITapGestureRecognizer){
        let sceneViewTappedOn = sender.view as! SCNView
        //get coordinates of where the user tapped in the scene view
        let touchCoordinates = sender.location(in: sceneViewTappedOn)
        //hittest checks if the coordinates you tapped overlap with an object in the sceneview
        let hitTest = sceneViewTappedOn.hitTest(touchCoordinates)
        //if you tap something, it hittest will give information on what you hit,
        //otherwise it will be empty
        if hitTest.isEmpty{
            print("Didnt touch anything")
        } else {
            if countdown > 0{
            //since we are in the else statement we know we hit something
            //knowing this, we can grab the first item in the results array
            //since we know we are only hitting one thing
            //unwrap it, and return the geometry of the node we tapped on
            let results = hitTest.first!
            let node = results.node
            //Only animate the jellyfish if there isn't already an animation playing
            //stacked animations create bugs
            if node.animationKeys.isEmpty{
                //Scene transactions are used to control animations
                //here we are addding one to make sure the jellyfish finishes its animation
                //before it dissapears
                SCNTransaction.begin()
                self.animateNode(node: node)
                //once the animation is complete
                //the jellyfish is removed from the parent node
                SCNTransaction.completionBlock = {
                    node.removeFromParentNode()
                    self.addNode()
                    self.restoreTimer()
                }
                SCNTransaction.commit()
            }
            }
        }
    }
    
    func animateNode(node: SCNNode){
        let spin = CABasicAnimation(keyPath: "position")
        spin.fromValue = node.presentation.position
        //move from node's current position
        spin.toValue = SCNVector3(node.presentation.position.x - 0.2,node.presentation.position.y - 0.2,node.presentation.position.z - 0.2)
        spin.duration = 0.07
        //animate moving back to original position
        spin.autoreverses = true
        spin.repeatCount = 5
        //stopping the node from animating another way while currently animated
        node.addAnimation(spin, forKey: "position")
    }
    
    func randomNumbers(firstNum: CGFloat, secondNum: CGFloat) -> CGFloat {
            return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNum - secondNum) + min(firstNum, secondNum)
        }
    
    func setTimer(){
        self.timerVar.perform { () -> NextStep in
            self.countdown -= 1
            self.timer.text = String(self.countdown)
            if self.countdown == 0 {
                self.timer.text = "you lose"
                return .stop
            }
            return .continue
        }
    }
    
    func restoreTimer(){
        self.countdown = 10
        self.timer.text = String(countdown)
    }
}

