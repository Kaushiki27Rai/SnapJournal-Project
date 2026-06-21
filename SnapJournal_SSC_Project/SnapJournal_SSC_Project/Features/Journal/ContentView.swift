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

private struct CameraButtonPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
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
    @State private var cameraButtonFrame: CGRect = .zero

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

                if showCaptureSheet {
                    Color.black.opacity(0.001)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { showCaptureSheet = false }
                        }
                        .transition(.opacity)

                    cameraPopover
                        .transition(.scale(scale: 0.92, anchor: .topTrailing).combined(with: .opacity))
                }
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
            .alert(deniedPermission?.title ?? "", isPresented: $showPermissionAlert) {
                Button("Open Settings") { openAppSettings() }
                Button("Not Now", role: .cancel) {}
            } message: {
                Text(deniedPermission?.message ?? "")
            }
        }
    }

    private var cameraPopover: some View {
        GeometryReader { geo in
            let popoverWidth: CGFloat = 220
            let popoverHeight: CGFloat = 110
            let buttonMidX = cameraButtonFrame.midX
            let popoverX = min(
                max(buttonMidX - popoverWidth / 2, 12),
                geo.size.width - popoverWidth - 12
            )
            let popoverY = cameraButtonFrame.maxY + 4

            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        Button {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { showCaptureSheet = false }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { requestCameraAccess() }
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 15))
                                    .foregroundStyle(Color(UIColor.label))
                                Text("Take a Photo")
                                    .font(.system(size: 15, weight: .regular))
                                    .foregroundStyle(Color(UIColor.label))
                                Spacer()
                            }
                            .padding(.horizontal, 16).padding(.vertical, 13)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)

                        Divider().padding(.horizontal, 14)
                    }

                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) { showCaptureSheet = false }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { requestPhotoLibraryAccess() }
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 15))
                                .foregroundStyle(Color(UIColor.label))
                            Text("Choose from Photos")
                                .font(.system(size: 15, weight: .regular))
                                .foregroundStyle(Color(UIColor.label))
                            Spacer()
                        }
                        .padding(.horizontal, 16).padding(.vertical, 13)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .frame(width: popoverWidth, height: popoverHeight)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(UIColor.separator).opacity(0.3), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.18), radius: 16, x: 0, y: 6)
            }
            .position(x: popoverX + popoverWidth / 2, y: popoverY + popoverHeight / 2)
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
                    .background(
                        GeometryReader { proxy in
                            Color.clear.preference(key: CameraButtonPreferenceKey.self, value: proxy.frame(in: .global))
                        }
                    )
            }
            .onPreferenceChange(CameraButtonPreferenceKey.self) { frame in
                cameraButtonFrame = frame
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
