//
//  EyeTrackingARView.swift
//  EyetrackingAPP
//
//  Created by 史承翰 on 2024/10/9.
//

import ARKit
import SwiftUI

struct EyeTrackingARView: UIViewRepresentable {
    
    @Binding var eyePositions: [CGPoint] // 用來記錄眼球位置
    
    func makeUIView(context: Context) -> ARSCNView {
        let sceneView = ARSCNView()
        sceneView.delegate = context.coordinator
        
        // 使用 ARFaceTrackingConfiguration 進行臉部和眼球追蹤
        let configuration = ARFaceTrackingConfiguration()
        sceneView.session.run(configuration)
        
        return sceneView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate {
        var parent: EyeTrackingARView
        
        init(_ parent: EyeTrackingARView) {
            self.parent = parent
        }
        
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor else { return }
            
            // 使用眼球的 transform 計算眼睛的視線方向
            let leftEye = faceAnchor.leftEyeTransform
            let rightEye = faceAnchor.rightEyeTransform
            
            // 計算螢幕上對應的座標位置
            let leftEyePosition = projectEyePosition(transform: leftEye)
            let rightEyePosition = projectEyePosition(transform: rightEye)
            
            // 紀錄平均眼球位置
            let averageEyePosition = CGPoint(x: (leftEyePosition.x + rightEyePosition.x) / 2,
                                             y: (leftEyePosition.y + rightEyePosition.y) / 2)
            
            DispatchQueue.main.async {
                self.parent.eyePositions.append(averageEyePosition)
            }
        }
        
        // 計算 ARKit 空間到螢幕座標的投影
        func projectEyePosition(transform: simd_float4x4) -> CGPoint {
            let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
            // 假設螢幕尺寸固定，可根據具體應用修改
            let screenSize = UIScreen.main.bounds.size
            let projectedX = CGFloat(position.x) * screenSize.width / 2 + screenSize.width / 2
            let projectedY = -CGFloat(position.y) * screenSize.height / 2 + screenSize.height / 2
            return CGPoint(x: projectedX, y: projectedY)
        }
    }
}

struct EyeTrackingView: View {
    @State private var eyePositions: [CGPoint] = [] // 用來記錄眼球移動的軌跡

    var body: some View {
        ZStack {
            // 顯示眼球軌跡的 Path
            Path { path in
                guard !eyePositions.isEmpty else { return }
                
                path.move(to: eyePositions.first!) // 移動到初始點
                for position in eyePositions {
                    path.addLine(to: position) // 畫線到每個新的眼球位置
                }
            }
            .stroke(Color.blue, lineWidth: 2)
            
            // 放置眼球追蹤 AR 視圖
            EyeTrackingARView(eyePositions: $eyePositions)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

