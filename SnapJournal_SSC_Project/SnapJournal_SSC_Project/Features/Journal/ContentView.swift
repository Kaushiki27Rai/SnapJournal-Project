//
//  ContentView.swift
//  SnapJournal
//
//  Created by Kaushiki Rai on 20/02/26.
//

import SwiftUI
import PhotosUI
import AVFoundation

private enum PermissionKind {
    case camera, photoLibrary

    var title: String {
        switch self {
        case .camera:       return "Camera Access Required"
        case .photoLibrary: return "Photo Library Access Required"
        }
    }

    var message: String {
        switch self {
        case .camera:
            return "SnapJournal needs camera access to capture new moments. Please allow Camera access in Settings."
        case .photoLibrary:
            return "SnapJournal needs photo library access to choose a moment. Please allow Photos access in Settings."
        }
    }
}

struct ContentView: View {

    @Environment(MomentStore.self) private var store

    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var photoSource: PhotoSource = .library
    @State private var showPhotoPicker = false
    @State private var showCamera = false
    @State private var showCaptureSheet = false
    @State private var navigateToPreview = false
    @State private var deniedPermission: PermissionKind?
    @State private var showPermissionAlert = false
    @State private var searchText = ""

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter(); f.dateStyle = .medium; return f
    }()

    private var filteredMoments: [Moment] {
        let q = searchText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !q.isEmpty else { return store.moments }
        return store.moments.filter {
            ($0.emotion?.name.lowercased() ?? "").contains(q)
            || $0.publicReflection.lowercased().contains(q)
            || Self.dateFormatter.string(from: $0.date).lowercased().contains(q)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                mainContent
            }
            .navigationTitle("SnapJournal")
            .navigationBarTitleDisplayMode(.large)
            .toolbar { toolbarContent }
            .searchable(text: $searchText, prompt: "Emotion, date, or note...")
            .navigationDestination(isPresented: $navigateToPreview) {
                PolaroidPreviewView(image: selectedImage ?? UIImage(), source: photoSource)
            }
            .photosPicker(isPresented: $showPhotoPicker, selection: $selectedItem, matching: .images)
            .onChange(of: selectedItem) { _, new in loadFromLibrary(new) }
            .onChange(of: selectedImage) { _, new in if new != nil { navigateToPreview = true } }
            .onChange(of: navigateToPreview) { _, new in if !new { selectedItem = nil; selectedImage = nil } }
            .onChange(of: store.justSaved) { _, new in if new { navigateToPreview = false; store.justSaved = false } }
            .fullScreenCover(isPresented: $showCamera) {
                CameraPickerView(
                    onImagePicked: { image in
                        showCamera = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            photoSource = .camera
                            selectedImage = image
                        }
                    },
                    onCancel: { showCamera = false },
                    sourceType: .camera
                )
                .ignoresSafeArea()
            }
            .confirmationDialog("Capture the Moment", isPresented: $showCaptureSheet, titleVisibility: .visible) {
                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                    Button {
                        showCaptureSheet = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { requestCameraAccess() }
                    } label: {
                        Label("Take a Photo", systemImage: "camera")
                    }
                }
                Button {
                    showCaptureSheet = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { requestPhotoLibraryAccess() }
                } label: {
                    Label("Choose from Photos", systemImage: "photo.on.rectangle")
                }
                Button("Cancel", role: .cancel) {}
            }
            .alert(deniedPermission?.title ?? "", isPresented: $showPermissionAlert) {
                Button("Open Settings") { openAppSettings() }
                Button("Not Now", role: .cancel) {}
            } message: {
                Text(deniedPermission?.message ?? "")
            }
        }
    }

    @ViewBuilder
    private var mainContent: some View {
        if store.moments.isEmpty {
            emptyState
        } else if !searchText.isEmpty && filteredMoments.isEmpty {
            noResultsState
        } else {
            momentGrid
        }
    }

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .navigationBarTrailing) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) { showCaptureSheet = true }
            } label: {
                Image(systemName: "camera.fill").font(.system(size: 17)).foregroundStyle(Color(UIColor.label))
            }
            .accessibilityLabel("Capture a new moment")
        }
    }

    private var momentGrid: some View {
        ScrollView {
            VStack(spacing: 4) {
                HStack {
                    Text("\(store.moments.count) moment\(store.moments.count == 1 ? "" : "s")")
                        .font(.system(size: 12))
                        .foregroundStyle(Color(UIColor.tertiaryLabel))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)

                if !searchText.isEmpty {
                    HStack {
                        Text("\(filteredMoments.count) \(filteredMoments.count == 1 ? "result" : "results")")
                            .font(.system(size: 12))
                            .foregroundStyle(Color(UIColor.tertiaryLabel))
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(filteredMoments) { moment in
                    NavigationLink(destination: MomentDetailView(moment: moment)) {
                        MomentCard(moment: moment)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16).padding(.top, 8).padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private var noResultsState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "magnifyingglass").font(.system(size: 44))
                .foregroundStyle(Color(UIColor.systemGray3)).accessibilityHidden(true)
            Text("No moments found").font(.system(size: 17)).foregroundStyle(Color(UIColor.label))
            Text("Try searching by emotion, date, or reflection.").font(.system(size: 14))
                .foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 40)
            Spacer(); Spacer()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "camera.viewfinder").font(.system(size: 52))
                .foregroundStyle(Color(UIColor.systemGray3)).accessibilityHidden(true)
            Text("No moments yet").font(.system(size: 17)).foregroundStyle(Color(UIColor.label))
            Text("Tap the camera to capture your first.").font(.system(size: 14)).foregroundStyle(.secondary)
            Spacer(); Spacer()
        }
    }

    private func requestCameraAccess() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            photoSource = .camera; showCamera = true
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted { photoSource = .camera; showCamera = true }
                    else { deniedPermission = .camera; showPermissionAlert = true }
                }
            }
        default:
            deniedPermission = .camera; showPermissionAlert = true
        }
    }

    private func requestPhotoLibraryAccess() {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            photoSource = .library; showPhotoPicker = true
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                DispatchQueue.main.async {
                    if newStatus == .authorized || newStatus == .limited {
                        photoSource = .library; showPhotoPicker = true
                    } else {
                        deniedPermission = .photoLibrary; showPermissionAlert = true
                    }
                }
            }
        default:
            deniedPermission = .photoLibrary; showPermissionAlert = true
        }
    }

    private func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }

    private func loadFromLibrary(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                await MainActor.run { selectedImage = image }
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(MomentStore())
}
