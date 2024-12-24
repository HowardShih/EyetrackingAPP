//
//  Home.swift
//  EyetrackingAPP
//
//  Created by 史承翰 on 2024/10/7.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // 背景
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    // App 名稱
                    Text("VocalEyes")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    // 產品簡介
                    Text("語音與眼動追蹤技術結合的失語症評估與治療 app")
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // 功能按鈕
                    VStack(spacing: 20) {
                        NavigationLink(destination: InitialAssessmentView()) {
                            FeatureButton(title: "初步評估", systemImage: "clipboard")
                        }
                        
                        NavigationLink(destination: TreatmentPlanView()) {
                            FeatureButton(title: "個人化治療計劃", systemImage: "list.bullet.clipboard")
                        }
                        
                        NavigationLink(destination: ProgressTrackingView()) {
                            FeatureButton(title: "進度追蹤紀錄", systemImage: "chart.bar")
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct FeatureButton: View {
    let title: String
    let systemImage: String
    
    var body: some View {
        HStack {
            Image(systemName: systemImage)
            Text(title)
        }
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(10)
        .padding(.horizontal)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
