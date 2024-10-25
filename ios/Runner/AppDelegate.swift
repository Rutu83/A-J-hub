
import UIKit
import Flutter
import Photos

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GeneratedPluginRegistrant.register(with: self)

        let controller = window?.rootViewController as! FlutterViewController
        let galleryChannel = FlutterMethodChannel(name: "com.allinonemarketing.allinone_app/gallery", binaryMessenger: controller.binaryMessenger)

        galleryChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            if call.method == "refreshGallery" {
                if let arguments = call.arguments as? [String: Any],
                   let filePath = arguments["filePath"] as? String {
                    self.refreshGallery(filePath)
                    result(nil)
                } else {
                    result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid argument received", details: nil))
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func refreshGallery(_ filePath: String) {
        let url = URL(fileURLWithPath: filePath)
        do {
            try PHPhotoLibrary.shared().performChangesAndWait {
                PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: url)
            }
            print("Image added to gallery.")
        } catch {
            print("Error adding image to gallery: \(error.localizedDescription)")
        }
    }
}
