import SwiftUI
import WatchConnectivity
import StoreKit

@main
struct AlQuranApp: App {
    @StateObject private var settings = Settings.shared
    @StateObject private var quranData = QuranData.shared
    @StateObject private var quranPlayer = QuranPlayer.shared
    @StateObject private var namesData = NamesViewModel.shared
    
    @State private var isLaunching = true
    
    @AppStorage("timeSpent") private var timeSpent: Double = 0
    @AppStorage("shouldShowRateAlert") private var shouldShowRateAlert: Bool = true
    @State private var startTime: Date?
    
    init() {
        _ = WatchConnectivityManager.shared
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if isLaunching {
                    LaunchScreen(isLaunching: $isLaunching)
                } else if settings.firstLaunch {
                    SplashScreen()
                } else {
                    SurahsView()
                }
            }
            .environmentObject(quranData)
            .environmentObject(quranPlayer)
            .environmentObject(namesData)
            .environmentObject(settings)
            .accentColor(settings.accentColor.color)
            .tint(settings.accentColor.color)
            .preferredColorScheme(settings.colorScheme)
            .transition(.opacity)
            .onAppear {
                if shouldShowRateAlert {
                    startTime = Date()
                    
                    let remainingTime = max(180 - timeSpent, 0)
                    if remainingTime == 0 {
                        guard let windowScene = UIApplication.shared.connectedScenes
                            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                            return
                        }
                        SKStoreReviewController.requestReview(in: windowScene)
                        shouldShowRateAlert = false
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + remainingTime) {
                            guard let windowScene = UIApplication.shared.connectedScenes
                                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else {
                                return
                            }
                            SKStoreReviewController.requestReview(in: windowScene)
                            shouldShowRateAlert = false
                        }
                    }
                }
            }
            .onDisappear {
                if shouldShowRateAlert, let startTime = startTime {
                    timeSpent += Date().timeIntervalSince(startTime)
                }
            }
        }
        .onChange(of: settings.lastReadSurah) { _ in
            sendMessageToWatch()
        }
        .onChange(of: settings.lastReadAyah) { _ in
            sendMessageToWatch()
        }
        .onChange(of: settings.favoriteSurahs) { _ in
            sendMessageToWatch()
        }
        .onChange(of: settings.bookmarkedAyahs) { _ in
            sendMessageToWatch()
        }
        .onChange(of: settings.favoriteLetters) { _ in
            sendMessageToWatch()
        }
        .onChange(of: settings.accentColor) { _ in
            sendMessageToWatch()
        }
    }
    
    private func sendMessageToWatch() {
        guard WCSession.default.isPaired else {
            print("No Apple Watch is paired")
            return
        }
        
        let settingsData = settings.dictionaryRepresentation()
        let message = ["settings": settingsData]

        if WCSession.default.isReachable {
            print("Watch is reachable. Sending message to watch: \(message)")

            WCSession.default.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message to watch: \(error.localizedDescription)")
            }
        } else {
            print("Watch is not reachable. Transferring user info to watch: \(message)")
            WCSession.default.transferUserInfo(message)
        }
    }
}
