import AuthenticationServices
import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, ASWebAuthenticationPresentationContextProviding {
  private var sepaySession: (id: UUID, session: ASWebAuthenticationSession)?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Required when FirebaseAppDelegateProxyEnabled = false
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    GeneratedPluginRegistrant.register(with: self)
    if let registrar = registrar(forPlugin: "SepayAuthorizationBrowser") {
      FlutterMethodChannel(
        name: "com.sipm.sipm_mobile/sepay_auth",
        binaryMessenger: registrar.messenger()
      ).setMethodCallHandler { [weak self] call, result in
        guard call.method == "authenticate" else {
          result(FlutterMethodNotImplemented)
          return
        }
        guard let self = self else {
          result(FlutterError(code: "unavailable", message: nil, details: nil))
          return
        }
        self.authenticateSepay(call.arguments, result: result)
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
    window ?? ASPresentationAnchor()
  }

  private func authenticateSepay(_ arguments: Any?, result: @escaping FlutterResult) {
    guard let input = arguments as? String,
          let url = URL(string: input),
          url.scheme == "https", url.host == "my.sepay.vn",
          url.path == "/oauth/authorize", url.user == nil, url.password == nil,
          url.port == nil || url.port == 443 else {
      result(FlutterError(code: "invalid_url", message: nil, details: nil))
      return
    }
    guard let anchor = window, !anchor.isHidden else {
      result(FlutterError(code: "unavailable", message: nil, details: nil))
      return
    }
    guard sepaySession == nil else {
      result(FlutterError(code: "already_open", message: nil, details: nil))
      return
    }

    let sessionID = UUID()
    let session = ASWebAuthenticationSession(
      url: url,
      callbackURLScheme: "legendsbadminton"
    ) { [weak self] callback, error in
      DispatchQueue.main.async {
        guard self?.sepaySession?.id == sessionID else { return }
        self?.sepaySession = nil
        if let callback = callback {
          result(callback.absoluteString)
        } else if let error = error as? ASWebAuthenticationSessionError {
          switch error.code {
          case .canceledLogin:
            result(nil)
          case .presentationContextNotProvided, .presentationContextInvalid:
            result(FlutterError(code: "unavailable", message: nil, details: nil))
          default:
            result(FlutterError(code: "authorization_failed", message: nil, details: nil))
          }
        } else {
          result(FlutterError(code: "authorization_failed", message: nil, details: nil))
        }
      }
    }
    session.presentationContextProvider = self
    sepaySession = (sessionID, session)
    if !session.start() {
      sepaySession = nil
      result(FlutterError(code: "unavailable", message: nil, details: nil))
    }
  }
}
