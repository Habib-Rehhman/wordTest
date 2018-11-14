//
//  ViewController.swift
//  wordTest . T
//
//  Created by Habib on 11/11/18.
//  Copyright © 2018 Habib. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import UserNotifications

class ViewController: UIViewController, ARSCNViewDelegate {
    // MARK: Properties
    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var ARView: ARSCNView!
   //declare variable
    var i = 0;
  
    var pointsArray: [SCNVector3] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ARView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        self.ARView.delegate = self
        //ARView.add3DText(showText: self.inputText!.text!,nodeName: self.inputText!.text!,pos: cameraView())
        
    }
    
    @IBAction func handleShowPaths(_ sender: Any) {
        
    
        for index in 0..<pointsArray.count {
         
         if(index+1 < pointsArray.count){
            let distancePieces =  integer_t(((distanceBetweenVectors(v1: pointsArray[index], v2: pointsArray[index+1]))/0.5).rounded(.up)) //there is also a fuction named "distanceBetweenVectors"
            print(distancePieces)
            var i = 0
            var lerp = SCNVector3Zero
            var line = SCNNode.lineNode(from: pointsArray[index] , to: lerp)
            var fIndex = pointsArray[index]
            while(i < distancePieces)
            {
                
                 lerp = fIndex.lerp(toVector: pointsArray[index+1], t: 1)
                print(lerp)
                 line = SCNNode.lineNode(from: fIndex , to: lerp)//, radius: 1.0)
                
                self.ARView.scene.rootNode.addChildNode(line)
                fIndex = lerp
                i = i+1
                
                
            }
            lerp = fIndex.lerp(toVector: pointsArray[index+1], t: 1)
            line = SCNNode.lineNode(from: lerp , to: pointsArray[index+1])//, radius: 1.0)
            
            self.ARView.scene.rootNode.addChildNode(line)

            
         }
         }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        ARView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        ARView.session.pause()
    }
    
    @IBAction func updateAct(_ sender: Any) {
      
        let showText=self.inputText!.text!
        if(showText.isEmpty)
        {
            //show text enter notification
            let content = UNMutableNotificationContent()
            content.title = "Metro Station Map"
            content.body =  " Enter the Stop Name to add"
            content.sound = UNNotificationSound.default
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
            let request = UNNotificationRequest(identifier: "TestIdentifier", content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        return
        }
        
        let pointOfView = ARView.pointOfView!
        let transform = pointOfView.transform
        let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
        let location = SCNVector3(transform.m41,transform.m42,transform.m43)
        let currentPositionOfCamera = orientation + location
        pointsArray.append(currentPositionOfCamera)
        i = i+1;
        let text = SCNText(string: showText, extrusionDepth: 1)
        print("not returned")
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        text.materials = [material]
       
        let node = SCNNode()
        node.position = currentPositionOfCamera// SCNVector3(x:-0.2,y:-0.1,z:-0.1)
        node.scale = SCNVector3(x:0.01,y:0.01,z:0.01)
        node.geometry = text
        let eulerAngles = self.ARView.session.currentFrame?.camera.eulerAngles
        node.eulerAngles = SCNVector3(eulerAngles!.x, eulerAngles!.y, eulerAngles!.z + .pi / 2)
    
        
        //notification
        let content = UNMutableNotificationContent()
        content.title = "Metro Station Map"
        content.body =  " Stop added successfuly!"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.2, repeats: false)
        let request = UNNotificationRequest(identifier: "TestIdentifier", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        self.ARView.scene.rootNode.addChildNode(node)

       
        
        }
      
    
    }
   
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    

/*func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
    
}
extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}*/



extension SCNNode {
    static func lineNode(from: SCNVector3, to: SCNVector3, radius: CGFloat = 0.05) -> SCNNode {
        let vector = to - from
        let height = vector.length
        let cylinder = SCNCylinder(radius: radius, height: CGFloat(height))
        cylinder.radialSegmentCount = 4
        cylinder.firstMaterial?.diffuse.contents = UIImage(named: "Arrow")//UIColor.red
        let node = SCNNode(geometry: cylinder)
        node.position = (to + from) / 2
        node.eulerAngles = SCNVector3.lineEulerAngles(vector: vector)
        
        return node
    }
}

