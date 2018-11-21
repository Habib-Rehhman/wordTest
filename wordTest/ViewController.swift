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
    var currentPositionOfCamera: SCNVector3
    {
        get{
            let pointOfView = ARView.pointOfView!
            let transform = pointOfView.transform
            let orientation = SCNVector3(-transform.m31,-transform.m32,-transform.m33)
            let location = SCNVector3(transform.m41,transform.m42,transform.m43)
            return orientation + location
        }
    }
    //  var pointsDic: [String: [SCNVector3]] = [:]
    var pointsDic: [String: SCNVector3] = [:]
    var pointsArray: [SCNVector3] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.ARView.debugOptions = [ARSCNDebugOptions.showWorldOrigin]
        self.ARView.delegate = self
        //ARView.add3DText(showText: self.inputText!.text!,nodeName: self.inputText!.text!,pos: cameraView())
        
    }
    
    @IBAction func handleShowPaths(_ sender: Any) {
        
        //This block removes previous arrows
        self.ARView.scene.rootNode.enumerateChildNodes { (node, stop) in
            if (node.name != nil && node.name!.elementsEqual("arrow")){
            node.removeFromParentNode()
                
            }
        }
        
        //This block adds new arrows
         if(pointsDic.count>0){
          
          //drawPath(from:  currentPositionOfCamera, to: pointsDic.first!.value) //Draw using Dictionary
            drawPath(from:  currentPositionOfCamera, to: pointsArray[0])    // Draw using array
          let arr = Array(pointsDic)
          
           if(arr.count>1)
           {
            for indx in arr.startIndex ..< arr.endIndex-1{
            
                //drawPath(from: arr[indx].value , to: arr[indx+1].value)
                drawPath(from: pointsArray[indx] , to: pointsArray[indx+1])
                
               // print("\(arr[indx].key) -> \(arr[indx+1].key)")
            }
        }
    }
    }
    
    func drawPath(from: SCNVector3, to: SCNVector3)// tag: String)
    {
        let distancePieces =  integer_t(((distanceBetweenVectors(v1: from, v2: to))/0.15).rounded(.up))
        var i = 1
        var multiple: Float = 0
        var node: LineNode
        var lerp = SCNVector3Zero
        var frm = from
        while(i <= distancePieces)
        {
            
            lerp = frm.lerp(toVector: to, t: 0.15 * multiple)//(float_t(i) * 0.15).rounded(.up))
            
            if(i % 2 != 0 )
            {
               // print(i)
                node = LineNode(v1: frm, v2: lerp)
                node.name = "arrow"
                self.ARView.scene.rootNode.addChildNode(node)
              //  print("distance is \(frm.distance(toVector: lerp))")
                
            }
            frm = lerp
            i = i+1
            multiple = multiple + 0.15;
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
        
       
          pointsArray.append(SCNVector3Make(currentPositionOfCamera.x, currentPositionOfCamera.y-1, currentPositionOfCamera.z))
//        pointsDic[showText]![0] = SCNVector3Make(currentPositionOfCamera.x, currentPositionOfCamera.y-1.5, currentPositionOfCamera.z)
        
        pointsDic[showText] = SCNVector3Make(currentPositionOfCamera.x, currentPositionOfCamera.y-1, currentPositionOfCamera.z)
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
        content.sound = UNNotificationSound.default // These paranthesis are necessary for swift 3, for 4 no parenthesis
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
    
    



/*extension SCNNode {
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

extension Int {
    
    var degreesToRadians: Double { return Double(self) * .pi/180}
}



//quad

extension SCNGeometry {
    
    class func Quad(from: SCNVector3, to: SCNVector3) -> SCNGeometry {
        
         
        
        let rightPointOfFrom = from.lerp(toVector: SCNVector3(0,0,from.z-2), t: 0.2)
        let leftPointOfFrom = from.lerp(toVector: SCNVector3(0,0,from.z+2), t: 0.2)
        
        let rightPointOfTo = to.lerp(toVector: SCNVector3(0,0,to.z-2), t: 0.2)
        let leftPointOfTo = to.lerp(toVector: SCNVector3(0,0,to.z+2), t: 0.2)
        
        let verticesPosition = [
//            SCNVector3(x: -0.242548823, y: -0.188490361, z: -0.0887458622),
//            SCNVector3(x: -0.129298389, y: -0.188490361, z: -0.0820985138),
//            SCNVector3(x: -0.129298389, y: 0.2, z: -0.0820985138),
//            SCNVector3(x: -0.242548823, y: 0.2, z: -0.0887458622)
            
            rightPointOfFrom, leftPointOfFrom
            ,rightPointOfTo
            ,leftPointOfTo
           
            
            
        ]
        
        let textureCord = [
            CGPoint(x: 1, y: 1),
            CGPoint(x: 0, y: 1),
            CGPoint(x: 0, y: 0),
            CGPoint(x: 1, y: 0),
            ]
        
        let indices: [CInt] = [
            0, 2, 3,
            0, 1, 2
        ]
        
        let vertexSource = SCNGeometrySource(vertices: verticesPosition)
        let srcTex = SCNGeometrySource(textureCoordinates: textureCord)
        let date = NSData(bytes: indices, length: MemoryLayout<CInt>.size * indices.count)
        
        let scngeometry = SCNGeometryElement(data: date as Data,
                                             primitiveType: SCNGeometryPrimitiveType.triangles, primitiveCount: 2,
                                             bytesPerIndex: MemoryLayout<CInt>.size)
        
        let geometry = SCNGeometry(sources: [vertexSource,srcTex],
                                   elements: [scngeometry])
        
        return geometry
        
        
    }
    
}
*/

class LineNode: SCNNode
{
    init(
        v1: SCNVector3,  // where line starts
        v2: SCNVector3
                      // where line ends
         )  // any material.
    {
        super.init()
        let  height1 = self.distanceBetweenPoints2(A: v1, B: v2) as CGFloat //v1.distance(v2)
        
        position = v1
        
        let ndV2 = SCNNode()
        
        ndV2.position = v2
        
        let ndZAlign = SCNNode()
        ndZAlign.eulerAngles.x = Float.pi/2
        
        let cylgeo = SCNBox(width: 0.2, height: height1, length: 0.001, chamferRadius: 0)
        cylgeo.firstMaterial?.diffuse.contents = UIImage(named: "Arrow")
        
        let ndCylinder = SCNNode(geometry: cylgeo )
        ndCylinder.position.y = Float(-height1/2) + 0.001
        ndZAlign.addChildNode(ndCylinder)
        
        addChildNode(ndZAlign)
        
//       // let eulerAngles = self.ARView!.session.currentFrame?.camera.eulerAngles
//        ndZAlign.eulerAngles = SCNVector3(angles.x, angles.y, angles.z + .pi / 2)
        
        constraints = [SCNLookAtConstraint(target: ndV2)]
}

    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func distanceBetweenPoints2(A: SCNVector3, B: SCNVector3) -> CGFloat {
        let l = sqrt(
            (A.x - B.x) * (A.x - B.x)
                +   (A.y - B.y) * (A.y - B.y)
                +   (A.z - B.z) * (A.z - B.z)
        )
        return CGFloat(l)
    }
}
