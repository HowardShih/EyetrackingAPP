//
//  ProgressTrackingView.swift
//  EyetrackingAPP
//
//  Created by 史承翰 on 2024/10/7.
//

import SwiftUI

struct ProgressTrackingView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: TreatmentProgressView()) {
                    Text("治療計劃進度追蹤")
                }
                NavigationLink(destination: RecordsView()) {
                    Text("治療紀錄")
                }
            }
            .navigationTitle("進度追蹤與紀錄")
        }
    }
}

struct TreatmentProgressView: View {
    var body: some View {
        Text("治療計劃進度追蹤內容")
    }
}

struct RecordsView: View {
    var body: some View {
        Text("治療紀錄內容")
    }
}

#Preview {
    ProgressTrackingView()
}
