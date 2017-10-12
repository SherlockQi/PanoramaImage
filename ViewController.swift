//
//  ViewController.swift
//  PanoramaImage
//
//  Created by HeiKki on 2017/10/9.
//  Copyright © 2017年 HeiKki. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion

class ViewController: UIViewController {
    let scnView = SCNView()
    //相机
    let cameraNode = SCNNode()
    
    //记录位置
    var lastPoint_x:CGFloat = 0
    var lastPoint_y:CGFloat = 0
    
    //记录角度
    var fingerRotationY:CGFloat = 0
    var fingerRotationX:CGFloat = 0
    
    
    //上次缩合
    var prevScale       :CGFloat = 1.0
    //本次缩合
    var currentScale    :CGFloat = 1.0
    //缩合限制
    let sScaleMin        :CGFloat = 0.5
    let sScaleMax        :CGFloat = 5.0
    let camera_Fox       :Double  = 60.0
    let camera_Height    :Double  = 50.0

    
    lazy var motionManager: CMMotionManager = {
        let motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 1.0 / 60
        return motionManager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //添加场景 容器
        scnView.frame = view.bounds
        scnView.scene = SCNScene()
        self.view.addSubview(scnView);
        //添加相机节点
        let camera = SCNCamera()
        cameraNode.camera = camera
        cameraNode.camera?.automaticallyAdjustsZRange = true;
        cameraNode.position = SCNVector3Make(0, 0, 0);
        cameraNode.camera?.xFov = camera_Fox;
        cameraNode.camera?.yFov = camera_Fox;
        cameraNode.camera?.yFov = camera_Fox;

        
        scnView.scene?.rootNode.addChildNode(cameraNode);
        //添加图片显示节点
        let panoramaNode = SCNNode()
        panoramaNode.geometry = SCNSphere(radius: 150);
        //剔除外表面
        panoramaNode.geometry?.firstMaterial?.cullMode = .front
        //只显示一个面
        panoramaNode.geometry?.firstMaterial?.isDoubleSided = false
        panoramaNode.position = SCNVector3Make(0, 0, 0);
        scnView.scene?.rootNode.addChildNode(panoramaNode);
        //图片
        let image = UIImage(named: "image")
        panoramaNode.geometry?.firstMaterial?.diffuse.contents = image
       
        //添加手势
//        let pan = UIPanGestureRecognizer(target: self, action: #selector(panImage(gesture:)))
//        scnView.addGestureRecognizer(pan)
//
//        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(gesture:)))
//        scnView.addGestureRecognizer(pinch)

        motionManager.startDeviceMotionUpdates(using: .xArbitraryCorrectedZVertical, to: OperationQueue(), withHandler: { (motion, erroe) in
            var vector = SCNVector3Zero
            let orientation = UIApplication.shared.statusBarOrientation
            
            if orientation == UIInterfaceOrientation.portrait{
                vector.x = Float((motion?.attitude.pitch)!)
                vector.y = Float((motion?.attitude.roll)!)
            }
            
//            if orientation == UIInterfaceOrientation.landscapeRight{
//                vector.y = Float((motion?.attitude.pitch)!)
//                vector.x = Float(-(motion?.attitude.roll)!)
//            }
//            if orientation == UIInterfaceOrientation.landscapeLeft{
//                vector.y = Float(-(motion?.attitude.pitch)!)
//                vector.x = Float((motion?.attitude.roll)!)
//            }
            self.cameraNode.eulerAngles = vector
        })
        
    }
    
    @objc func panImage(gesture:UIGestureRecognizer){
        if !gesture.isKind(of: UIPanGestureRecognizer.self){
            return
        }

        if gesture.state == .began {
            let currentPoint = gesture .location(in: self.scnView)
            lastPoint_x = currentPoint.x
            lastPoint_y = currentPoint.y
        }else{
            let currentPoint = gesture .location(in: self.scnView)
            var distX = currentPoint.x - lastPoint_x
            var distY:CGFloat = currentPoint.y - lastPoint_y
            lastPoint_x = currentPoint.x
            lastPoint_y = currentPoint.y
            distX *= -0.003
            distY *= -0.003
            
            fingerRotationY += distY
            fingerRotationX += distX
            
            var modelMatrix = SCNMatrix4MakeRotation(0, 0, 0, 0)
            modelMatrix = SCNMatrix4Rotate(modelMatrix, Float(fingerRotationX),0, 1, 0);
            modelMatrix = SCNMatrix4Rotate(modelMatrix, Float(fingerRotationY), 1, 0, 0);
            self.cameraNode.pivot = modelMatrix;
        }
    }
    //捏合手势
    @objc func pinchGesture(gesture:UIGestureRecognizer){
        if !gesture.isKind(of: UIPinchGestureRecognizer.self){
            return
        }
        let pinchGesture = gesture as! UIPinchGestureRecognizer
        
        if pinchGesture.state != .ended && pinchGesture.state != .failed{
            if pinchGesture.scale != 0.0{
                
                var scale = pinchGesture.scale - 1
                if scale < 0 {
                    scale *= (sScaleMax - sScaleMin)
                }
                    currentScale = scale + prevScale
                    currentScale = validateScale(scale: currentScale)
                
                let valScale = validateScale(scale: currentScale)
                let scaleRatio = 1-(valScale-1)*0.15
                let xFov = CGFloat(camera_Fox) * scaleRatio
                let yFov = CGFloat(camera_Height) * scaleRatio
                    cameraNode.camera?.xFov = Double(xFov)
                    cameraNode.camera?.yFov = Double(yFov)
            }
            }else if pinchGesture.state == .ended{
            prevScale = currentScale
        }
    }
    
    private func validateScale(scale:CGFloat) -> CGFloat {
        var validateScale = scale
        if scale < sScaleMin {
            validateScale = sScaleMin
        } else if scale > sScaleMax{
            validateScale = sScaleMax
        }
        return validateScale
    }
}

