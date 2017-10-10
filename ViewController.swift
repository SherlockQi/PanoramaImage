//
//  ViewController.swift
//  PanoramaImage
//
//  Created by HeiKki on 2017/10/9.
//  Copyright © 2017年 HeiKki. All rights reserved.
//

import UIKit
import SceneKit

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
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panImage(gesture:)))
        scnView.addGestureRecognizer(pan)
    }
    
    @objc func panImage(gesture:UIGestureRecognizer){
        if !gesture.isKind(of: UIPanGestureRecognizer.self){
            return
        }
        if gesture.numberOfTouches > 1{
            print(gesture.numberOfTouches)
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
}
