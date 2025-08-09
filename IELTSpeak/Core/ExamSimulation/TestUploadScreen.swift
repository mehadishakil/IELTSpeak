////
////  TestUploadScreen.swift
////  IELTSpeak
////
////  Created by Mehadi Hasan on 9/8/25.
////
//
//
//import SwiftUI
//
//struct TestUploadScreen: View {
//    @StateObject private var uploadManager = UploadManager.shared
//    @StateObject private var localStorageManager = LocalStorageManager.shared
//    @Environment(\.dismiss) private var dismiss
//    
//    @State private var showingUploadAlert = false
//    @State private var alertMessage = ""
//    
//    var body: some View {
//        NavigationView {
//            VStack(spacing: 0) {
//                // Header
//                HeaderSection()
//                
//                ScrollView {
//                    VStack(spacing: 24) {
//                        // Upload Status Card
//                        UploadStatusCard()
//                        
//                        // Progress Section
//                        if !uploadManager.uploadProgress.isEmpty {
//                            UploadProgressSection()
//                        }
//                        
//                        // Local Storage Info
//                        LocalStorageInfoCard()
//                        
//                        // Action Buttons
//                        ActionButtonsSection()
//                        
//                        Spacer(minLength: 40)
//                    }
//                    .padding(.horizontal, 20)
//                    .padding(.top, 20)
//                }
//            }
//            .background(Color(.systemGroupedBackground))
//            .navigationBarHidden(true)
//            .onAppear {
//                loadLocalResponses()
//            }
//            .alert("Upload Status", isPresented: $showingUploadAlert) {
//                Button("OK") { }
//            } message: {
//                Text(alertMessage)
//            }
//        }
//    }
//    
//    // MARK: - Header Section
//    
//    @ViewBuilder
//    private func HeaderSection() -> some View {
//        HStack {
//            Button("Back") {
//                dismiss()
//            }
//            .font(.custom("Fredoka-Regular", size: 16))
//            .foregroundColor(.blue)
//            
//            Spacer()
//            
//            Text("Upload Test Results")
//                .font(.custom("Fredoka-SemiBold", size: 20))
//                .foregroundColor(.primary)
//            
//            Spacer()
//            
//            // Placeholder for alignment
//            Button("") { }
//                .opacity(0)
//                .disabled(true)
//        }
//        .padding(.horizontal, 20)
//        .padding(.vertical, 16)
//        .background(Color(.systemBackground))
//        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 1)
//    }
//    
//    // MARK: - Upload Status Card
//    
//    @ViewBuilder
//    private func UploadStatusCard() -> some View {
//        VStack(spacing: 16) {
//            // Status Icon and Title
//            HStack {
//                Group {
//                    if uploadManager.isUploading {
//                        ProgressView()
//                            .scaleEffect(1.2)
//                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
//                    } else if uploadManager.uploadError != nil {
//                        Image(systemName: "exclamationmark.triangle.fill")
//                            .font(.system(size: 32))
//                            .foregroundColor(.red)
//                    } else if uploadManager.batchResult?.allSuccessful == true {
//                        Image(systemName: "checkmark.circle.fill")
//                            .font(.system(size: 32))
//                            .foregroundColor(.green)
//                    } else {
//                        Image(systemName: "icloud.and.arrow.up")
//                            .font(.system(size: 32))
//                            .foregroundColor(.blue)
//                    }
//                }
//                
//                VStack(alignment: .leading, spacing: 4) {
//                    Text(statusTitle)
//                        .font(.custom("Fredoka-SemiBold", size: 18))
//                        .foregroundColor(.primary)
//                    
//                    Text(statusSubtitle)
//                        .font(.custom("Fredoka-Regular", size: 14))
//                        .foregroundColor(.secondary)
//                        .multilineTextAlignment(.leading)
//                }
//                
//                Spacer()
//            }
//            
//            // Overall Progress Bar (if uploading)
//            if uploadManager.isUploading || !uploadManager.uploadProgress.isEmpty {
//                OverallProgressBar()
//            }
//            
//            // Error Message
//            if let error = uploadManager.uploadError {
//                ErrorMessageView(error: error)
//            }
//        }
//        .padding(20)
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
//    }
//    
//    // MARK: - Progress Section
//    
//    @ViewBuilder
//    private func UploadProgressSection() -> some View {
//        VStack(spacing: 16) {
//            HStack {
//                Text("Upload Progress")
//                    .font(.custom("Fredoka-SemiBold", size: 18))
//                    .foregroundColor(.primary)
//                
//                Spacer()
//                
//                let stats = uploadManager.getUploadStatistics()
//                Text("\(stats.completed)/\(stats.total)")
//                    .font(.custom("Fredoka-Regular", size: 14))
//                    .foregroundColor(.secondary)
//            }
//            
//            LazyVStack(spacing: 8) {
//                ForEach(Array(uploadManager.uploadProgress.enumerated()), id: \.element.id) { index, progress in
//                    UploadProgressRow(
//                        responseNumber: index + 1,
//                        progress: progress
//                    )
//                }
//            }
//        }
//        .padding(20)
//        .background(Color(.systemBackground))
//        .cornerRadius(12)
//        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
//    }
//    
//    // MARK: - Local Storage Info
//    
//    @ViewBuilder
//    private func LocalStorageInfoCard() -> some View {
//        VStack(spacing: 12) {
//            HStack {
//                Image(systemName: "externaldrive.fill")
//                    .foregroundColor(.orange)
//                
//                Text("Local Storage")
//                    .font(.custom("Fredoka-SemiBold", size: 16))
//                
//                Spacer()
//            }
//            
//            VStack(spacing: 8) {
//                StorageInfoRow(
//                    title: "Responses Saved",
//                    value: "\(localStorageManager.localResponses.count)"
//                )
//                
//                StorageInfoRow(
//                    title: "Storage Used",
//                    value: formatStorageSize(localStorageManager.getLocalStorageSize())
//                )
//                
//                if let sessionId = localStorageManager.currentSessionId {
//                    StorageInfoRow(
//                        title: "Current Session",
//                        value: String(sessionId.prefix(8)) + "..."
//                    )
//                }
//            }
//        }
//        .padding(16)
//        .background(Color(.secondarySystemGroupedBackground))
//        .cornerRadius(10)
//    }
//    
//    // MARK: - Action Buttons
//    
//    @ViewBuilder
//    private func ActionButtonsSection() -> some View {
//        VStack(spacing: 16) {
//            // Primary Upload Button
//            if !uploadManager.isUploading && uploadManager.hasLocalResponsesForUpload() {
//                Button(action: startUpload) {
//                    HStack {
//                        Image(systemName: "icloud.and.arrow.up")
//                        Text("Start Upload")
//                    }
//                    .font(.custom("Fredoka-SemiBold", size: 18))
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 16)
//                    .background(.blue)
//                    .cornerRadius(12)
//                }
//            }
//            
//            // Retry Button (if there are failures)
//            if !uploadManager.isUploading && 
//               uploadManager.uploadProgress.contains(where: { $0.status == .failed }) {
//                Button(action: retryFailedUploads) {
//                    HStack {
//                        Image(systemName: "arrow.clockwise")
//                        Text("Retry Failed Uploads")
//                    }
//                    .font(.custom("Fredoka-SemiBold", size: 16))
//                    .foregroundColor(.white)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 14)
//                    .background(.orange)
//                    .cornerRadius(10)
//                }
//            }
//            
//            // Clear/Reset Button
//            if !uploadManager.isUploading && !uploadManager.uploadProgress.isEmpty {
//                Button(action: clearUploadHistory) {
//                    HStack {
//                        Image(systemName: "trash")
//                        Text("Clear Upload History")
//                    }
//                    .font(.custom("Fredoka-Regular", size: 14))
//                    .foregroundColor(.red)
//                    .frame(maxWidth: .infinity)
//                    .padding(.vertical, 12)
//                    .background(Color.red.opacity(0.1))
//                    .cornerRadius(8)
//                }
//            }
//        }
//    }
//    
//    // MARK: - Helper Views
//    
//    @ViewBuilder
//    private func OverallProgressBar() -> some View {
//        let stats = uploadManager.getUploadStatistics()
//        let progress = stats.total > 0 ? Double(stats.completed) / Double(stats.total) : 0.0
//        
//        VStack(spacing: 8) {
//            HStack {
//                Text("Overall Progress")
//                    .font(.custom("Fredoka-Regular", size: 14))
//                    .foregroundColor(.secondary)
//                
//                Spacer()
//                
//                Text("\(Int(progress * 100))%")
//                    .font(.custom("Fredoka-Medium", size: 14))
//                    .foregroundColor(.secondary)
//            }
//            
//            ProgressView(value: progress)
//                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
//                .scaleEffect(x: 1, y: 1.5, anchor: .center)
//        }
//    }
//    
//    @ViewBuilder
//    private func ErrorMessageView(error: String) -> some View {
//        HStack {
//            Image(systemName: "exclamationmark.triangle")
//                .foregroundColor(.red)
//            
//            Text(error)
//                .font(.custom("Fredoka-Regular", size: 14))
//                .foregroundColor(.red)
//                .multilineTextAlignment(.leading)
//            
//            Spacer()
//        }
//        .padding(12)
//        .background(Color.red.opacity(0.1))
//        .cornerRadius(8)
//    }
//    
//    @ViewBuilder
//    private func StorageInfoRow(title: String, value: String) -> some View {
//        HStack {
//            Text(title)
//                .font(.custom("Fredoka-Regular", size: 14))
//                .foregroundColor(.secondary)
//            
//            Spacer()
//            
//            Text(value)
//                .font(.custom("Fredoka-Medium", size: 14))
//                .foregroundColor(.primary)
//        }
//    }
//    
//    // MARK: - Computed Properties
//    
//    private var statusTitle: String {
//        if uploadManager.isUploading {
//            return "Uploading..."
//        } else if uploadManager.uploadError != nil {
//            return "Upload Failed"
//        } else if uploadManager.batchResult?.allSuccessful == true {
//            return "Upload Complete"
//        } else if uploadManager.hasLocalResponsesForUpload() {
//            return "Ready to Upload"
//        } else {
//            return "No Data to Upload"
//        }
//    }
//    
//    private var statusSubtitle: String {
//        if uploadManager.isUploading {
//            let stats = uploadManager.getUploadStatistics()
//            return "Uploading \(stats.completed + 1) of \(stats.total) responses..."
//        } else if let error = uploadManager.uploadError {
//            return "Some uploads failed. Please retry."
//        } else if uploadManager.batchResult?.allSuccessful == true {
//            return "All responses have been uploaded successfully for AI evaluation."
//        } else if uploadManager.hasLocalResponsesForUpload() {
//            return "Your test responses are saved locally and ready to upload for AI evaluation."
//        } else {
//            return "Complete a test to see upload options here."
//        }
//    }
//    
//    // MARK: - Actions
//    
//    private func loadLocalResponses() {
//        // Trigger loading of local responses
//        localStorageManager.printStorageStatus()
//    }
//    
//    private func startUpload() {
//        Task {
//            await uploadManager.startBatchUpload()
//            
//            if let result = uploadManager.batchResult {
//                if result.allSuccessful {
//                    alertMessage = "All \(result.successfulUploads) responses uploaded successfully!"
//                } else {
//                    alertMessage = "Upload completed with \(result.successfulUploads) successful and \(result.failedUploads) failed uploads."
//                }
//                showingUploadAlert = true
//            }
//        }
//    }
//    
//    private func retryFailedUploads() {
//        Task {
//            await uploadManager.retryFailedUploads()
//        }
//    }
//    
//    private func clearUploadHistory() {
//        uploadManager.resetUploadState()
//    }
//    
//    // MARK: - Utility Methods
//    
//    private func formatStorageSize(_ bytes: Int64) -> String {
//        let formatter = ByteCountFormatter()
//        formatter.countStyle = .file
//        return formatter.string(fromByteCount: bytes)
//    }
//}
//
//// MARK: - Upload Progress Row
//
//struct UploadProgressRow: View {
//    let responseNumber: Int
//    let progress: UploadProgress
//    
//    var body: some View {
//        HStack(spacing: 12) {
//            // Response number circle
//            Circle()
//                .fill(statusColor.opacity(0.2))
//                .frame(width: 30, height: 30)
//                .overlay(
//                    Text("\(responseNumber)")
//                        .font(.custom("Fredoka-Regular", size: 12))
//                        .fontWeight(.medium)
//                        .foregroundColor(statusColor)
//                )
//            
//            // Response info
//            VStack(alignment: .leading, spacing: 4) {
//                Text("Response \(responseNumber)")
//                    .font(.custom("Fredoka-Regular", size: 14))
//                    .fontWeight(.medium)
//                
//                Text(progress.status.displayName)
//                    .font(.custom("Fredoka-Regular", size: 12))
//                    .foregroundColor(statusColor)
//            }
//            
//            Spacer()
//            
//            // Status indicator
//            Group {
//                switch progress.status {
//                case .pending:
//                    Image(systemName: "clock.fill")
//                        .foregroundColor(.gray)
//                        
//                case .uploading:
//                    ProgressView()
//                        .scaleEffect(0.8)
//                        .progressViewStyle(CircularProgressViewStyle(tint: statusColor))
//                        
//                case .completed:
//                    Image(systemName: "checkmark.circle.fill")
//                        .foregroundColor(.green)
//                        
//                case .failed:
//                    Image(systemName: "xmark.circle.fill")
//                        .foregroundColor(.red)
//                }
//            }
//            .font(.system(size: 16))
//        }
//        .padding(.horizontal, 16)
//        .padding(.vertical, 12)
//        .background(Color(.systemBackground))
//        .cornerRadius(8)
//        .overlay(
//            RoundedRectangle(cornerRadius: 8)
//                .stroke(statusColor.opacity(0.3), lineWidth: 1)
//        )
//    }
//    
//    private var statusColor: Color {
//        switch progress.status {
//        case .pending: return .gray
//        case .uploading: return .blue
//        case .completed: return .green
//        case .failed: return .red
//        }
//    }
//}
//
//// MARK: - Preview
//
//struct TestUploadScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        TestUploadScreen()
//            .preferredColorScheme(.light)
//        
//        TestUploadScreen()
//            .preferredColorScheme(.dark)
//    }
//}
