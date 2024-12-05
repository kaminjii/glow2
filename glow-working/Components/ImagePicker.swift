import SwiftUI
import PhotosUI

// MARK: - ImagePicker View
struct ImagePicker: View {
    @Binding var selectedImage: UIImage?
    @Binding var isPickerPresented: Bool
    @Binding var isLoading: Bool

    var body: some View {
        ZStack {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 220)
                    .cornerRadius(10)
                    .overlay(
                        Group {
                            if isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                                    .background(Color.black.opacity(0.3))
                            }
                        }
                    )
            } else {
                emptyImagePicker
            }
        }
        .frame(height: 375)
        .onTapGesture {
            isPickerPresented = true
        }
    }

    private var emptyImagePicker: some View {
        RoundedRectangle(cornerRadius: 10).fill(Color.gray3)
            .overlay(
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray3)
                    Image(systemName: "camera.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .foregroundColor(.gray5)
                        .padding()
                    Image(systemName: "plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                        .foregroundStyle(.gray1)
                        .padding()
                }
            )
    }
}

// MARK: - PhotoPicker
struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        // Check photo library permission first
        let authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        
        switch authStatus {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                if status == .denied {
                    showPermissionAlert()
                }
            }
        case .denied, .restricted:
            showPermissionAlert()
        default:
            break
        }
        
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    private func showPermissionAlert() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let viewController = windowScene.windows.first?.rootViewController {
                let alert = UIAlertController(
                    title: "Photos Access Required",
                    message: "Please allow access to your photos in Settings to use this feature.",
                    preferredStyle: .alert
                )
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                alert.addAction(UIAlertAction(title: "Settings", style: .default) { _ in
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                })
                
                viewController.present(alert, animated: true)
            }
        }
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PhotoPicker
        
        init(_ parent: PhotoPicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            guard let provider = results.first?.itemProvider,
                  provider.canLoadObject(ofClass: UIImage.self) else { return }
            
            provider.loadObject(ofClass: UIImage.self) { (image, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error loading image: \(error)")
                        return
                    }
                    if let image = image as? UIImage {
                        self.parent.selectedImage = image
                    }
                }
            }
        }
    }
}
