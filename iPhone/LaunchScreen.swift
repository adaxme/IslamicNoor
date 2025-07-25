import SwiftUI

struct LaunchScreen: View {
    @EnvironmentObject var settings: Settings

    @Binding var isLaunching: Bool

    @State private var size = 0.8
    @State private var opacity = 0.5
    @State private var gradientSize: CGFloat = 0.0

    @Environment(\.colorScheme) var systemColorScheme
    @Environment(\.customColorScheme) var customColorScheme

    var currentColorScheme: ColorScheme {
        if let colorScheme = settings.colorScheme {
            return colorScheme
        } else {
            return systemColorScheme
        }
    }

    var backgroundColor: Color {
        switch currentColorScheme {
        case .light:
            return Color.white
        case .dark:
            return Color.black
        @unknown default:
            return Color.white
        }
    }

    var gradient: LinearGradient {
        LinearGradient(
            colors: [settings.accentColor.color.opacity(0.3), settings.accentColor.color.opacity(0.5)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        ZStack {
            backgroundColor
                .ignoresSafeArea()

            gradient
                .clipShape(Circle())
                .scaleEffect(gradientSize)

            VStack {
                VStack {
                    #if !os(watchOS)
                    Text("القرءان")
                        .font(.custom(settings.fontArabic, size: 30))
                        .foregroundColor(settings.accentColor.color)
                        .padding(.bottom, -1)
                    #endif

                    Image("Al-Quran")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                        .frame(width: 150, height: 150)
                        .padding()

                    #if !os(watchOS)
                    Text("Al-Quran")
                        .font(.custom("Avenir", size: 30))
                        .foregroundColor(settings.accentColor.color)
                        .padding(.top, -1)
                    #endif
                }
                .foregroundColor(settings.accentColor.color)
                .scaleEffect(size)
                .opacity(opacity)
            }
        }
        .onAppear {
            triggerHapticFeedback(.soft)
            
            withAnimation(.easeInOut(duration: 0.5)) {
                size = 0.9
                opacity = 1.0
                gradientSize = 3.0
                
                triggerHapticFeedback(.soft)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                triggerHapticFeedback(.soft)
                
                withAnimation(.easeOut(duration: 0.5)) {
                    size = 0.8
                    gradientSize = 0.0
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                    triggerHapticFeedback(.soft)

                    withAnimation {
                        self.isLaunching = false
                    }
                }
            }
        }
    }
    
    private func triggerHapticFeedback(_ feedbackType: HapticFeedbackType) {
        if settings.hapticOn {
            #if !os(watchOS)
            switch feedbackType {
            case .soft:
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            case .light:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .medium:
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            case .heavy:
                UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            }
            #else
            if settings.hapticOn { WKInterfaceDevice.current().play(.click) }
            #endif
        }
    }

    enum HapticFeedbackType {
        case soft, light, medium, heavy
    }
}
