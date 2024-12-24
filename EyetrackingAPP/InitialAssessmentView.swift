//
//  InitialAssessmentView.swift
//  EyetrackingAPP
//
//  Created by 史承翰 on 2024/10/7.
//

import SwiftUI
import Speech
import AVFoundation
import PhotosUI

// 定義測試類型
enum TestType {
    case fluency
    case comprehension
    case repetition
}

// 定義流暢度測試的子類型
enum FluencyTestType {
    case naming
    case sentenceConstruction
    case storytelling
}

// 定義測試項目
struct TestItem {
    let type: TestType
    let subtype: FluencyTestType?
    let instruction: String
    let image: UIImage?
    let question: String?
    
    init(type: TestType, subtype: FluencyTestType? = nil, instruction: String, image: UIImage? = nil, question: String? = nil) {
        self.type = type
        self.subtype = subtype
        self.instruction = instruction
        self.image = image
        self.question = question
    }
}

class LanguageAssessmentViewModel: ObservableObject {
    @Published var currentTestItem: TestItem?
    @Published var transcribedText = ""
    @Published var isRecording = false
    @Published var showError = false
    @Published var errorMessage: String?
    
    private var speechRecognizer: SpeechRecognizer?
    private var testItems: [TestItem] = []
    private var currentItemIndex = 0
    
    init() {
        setupTestItems()
    }
    
    private func setupTestItems() {
        // 這裡添加測試項目，您可以根據需要擴展
        testItems = [
            TestItem(type: .fluency, subtype: .naming, instruction: "請說出圖片中物品的名稱", image: UIImage(named: "item1")),
            TestItem(type: .fluency, subtype: .sentenceConstruction, instruction: "請用完整句子描述圖片中的動作", image: UIImage(named: "action1")),
            TestItem(type: .fluency, subtype: .storytelling, instruction: "請描述圖片中的故事", image: UIImage(named: "story1")),
            TestItem(type: .comprehension, instruction: "請回答以下問題", question: "您最喜歡的食物是什麼？為什麼？"),
            TestItem(type: .repetition, instruction: "請重複以下句子", question: "今天天氣真好，我想去公園散步。")
        ]
    }
    
    func startNextTest() {
        if currentItemIndex < testItems.count {
            currentTestItem = testItems[currentItemIndex]
            currentItemIndex += 1
        } else {
            // 測試結束，可以在這裡添加結束邏輯
            currentTestItem = nil
        }
    }
    
    func startRecording() {
        isRecording = true
        speechRecognizer = SpeechRecognizer()
        speechRecognizer?.startTranscribing { [weak self] result in
            DispatchQueue.main.async {
                self?.transcribedText = result
            }
        } errorHandler: { [weak self] error in
            DispatchQueue.main.async {
                self?.errorMessage = error.localizedDescription
                self?.showError = true
                self?.isRecording = false
            }
        }
    }
    
    func stopRecording() {
        isRecording = false
        speechRecognizer?.stopTranscribing()
    }
}

struct LanguageAssessmentView: View {
    @StateObject private var viewModel = LanguageAssessmentViewModel()
    
    var body: some View {
        VStack {
            if let testItem = viewModel.currentTestItem {
                TestItemView(testItem: testItem, viewModel: viewModel)
            } else {
                Text("測試已完成")
            }
            
            Button(action: {
                if viewModel.isRecording {
                    viewModel.stopRecording()
                } else {
                    viewModel.startRecording()
                }
            }) {
                Text(viewModel.isRecording ? "停止錄音" : "開始錄音")
                    .padding()
                    .background(viewModel.isRecording ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            ScrollView {
                Text(viewModel.transcribedText)
                    .padding()
            }
            .frame(height: 150)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Button("下一題") {
                viewModel.startNextTest()
            }
            .padding()
            .disabled(viewModel.currentTestItem == nil)
        }
        .padding()
        .onAppear {
            viewModel.startNextTest()
        }
        .alert(isPresented: $viewModel.showError) {
            Alert(title: Text("錯誤"), message: Text(viewModel.errorMessage ?? "未知錯誤"), dismissButton: .default(Text("確定")))
        }
    }
}

struct TestItemView: View {
    let testItem: TestItem
    @ObservedObject var viewModel: LanguageAssessmentViewModel
    
    var body: some View {
        VStack {
            Text(testItem.instruction)
                .font(.headline)
                .padding()
            
            if let image = testItem.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
            
            if let question = testItem.question {
                Text(question)
                    .font(.subheadline)
                    .padding()
            }
        }
    }
}

class SpeechRecognizer {
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let speechRecognizer: SFSpeechRecognizer?
    
    init() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-TW"))
    }
    
    func startTranscribing(resultHandler: @escaping (String) -> Void, errorHandler: @escaping (Error) -> Void) {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            errorHandler(NSError(domain: "SpeechRecognizer", code: 0, userInfo: [NSLocalizedDescriptionKey: "Speech recognizer is unavailable"]))
            return
        }
        
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            let request = SFSpeechAudioBufferRecognitionRequest()
            request.append(buffer)
            
            self.recognitionTask = speechRecognizer.recognitionTask(with: request) { result, error in
                if let error = error {
                    errorHandler(error)
                    return
                }
                guard let result = result else { return }
                resultHandler(result.bestTranscription.formattedString)
            }
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch {
            errorHandler(error)
        }
    }
    
    func stopTranscribing() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
    }
}


@main
struct LanguageAssessmentApp: App {
    var body: some Scene {
        WindowGroup {
            LanguageAssessmentView()
        }
    }
}
