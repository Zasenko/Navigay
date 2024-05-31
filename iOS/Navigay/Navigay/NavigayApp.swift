//
//  NavigayApp.swift
//  Navigay
//
//  Created by Dmitry Zasenko on 03.10.23.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import AppTrackingTransparency


@main
struct NavigayApp: App {
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            AppUser.self, Country.self, Region.self, City.self, Event.self, Place.self, User.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            Te()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct Te: View {
    
    var body: some View {
        BannerView()
            .frame(width: GADAdSizeBanner.size.width,
                   height: GADAdSizeBanner.size.height)
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                        ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in })
                    }
    }
}

struct BannerView: UIViewControllerRepresentable {
    
    let bannerView = GADBannerView(adSize: GADAdSizeBanner)
    
    func makeUIViewController(context: Context) -> UIViewController {
        
        let viewController = UIViewController()
        bannerView.adUnitID = "ca-app-pub-4296517230777607/1201998816"
        bannerView.rootViewController = viewController
        viewController.view.addSubview(bannerView)
        viewController.view.backgroundColor = .blue
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        bannerView.load(GADRequest())
    }
}



class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      //  GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers =
         //   [ "2077ef9a63d2b398840261c8221a0c9b" ]
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        return true
    }
}

//class AppOpenAdManager: NSObject {
//  var appOpenAd: GADAppOpenAd?
//  var isLoadingAd = false
//  var isShowingAd = false
//
//  static let shared = AppOpenAdManager()
//
//    func showAdIfAvailable() {
//      // If the app open ad is already showing, do not show the ad again.
//      guard !isShowingAd else { return }
//
//      // If the app open ad is not available yet but is supposed to show, load
//      // a new ad.
//      if !isAdAvailable() {
//        Task {
//          await loadAd()
//        }
//        return
//      }
//
//      if let ad = appOpenAd {
//        isShowingAd = true
//        ad.present(fromRootViewController: nil)
//      }
//    }
//  private func isAdAvailable() -> Bool {
//    // Check if ad exists and can be shown.
//    return appOpenAd != nil
//  }
//    
//    private func loadAd() async {
//      // Do not load ad if there is an unused ad or one is already loading.
//      if isLoadingAd || isAdAvailable() {
//        return
//      }
//      isLoadingAd = true
//
//      do {
//        appOpenAd = try await GADAppOpenAd.load(
//          withAdUnitID: "ca-app-pub-3940256099942544/5575463023", request: GADRequest())
//      } catch {
//        print("App open ad failed to load with error: \(error.localizedDescription)")
//      }
//      isLoadingAd = false
//    }
//
//}

