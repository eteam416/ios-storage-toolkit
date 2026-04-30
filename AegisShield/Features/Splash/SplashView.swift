import SwiftUI

/// Premium animated splash screen with brand reveal.
struct SplashView: View {
    @EnvironmentObject private var appState: AppStateManager
    @State private var shieldScale: CGFloat = 0.3
    @State private var shieldOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 20
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            AegisColors.brandPrimary
                .ignoresSafeArea()

            // Radial glow behind shield
            RadialGradient(
                colors: [
                    AegisColors.brandAccent.opacity(0.3),
                    Color.clear
                ],
                center: .center,
                startRadius: 20,
                endRadius: 200
            )
            .opacity(glowOpacity)
            .ignoresSafeArea()

            VStack(spacing: AegisSpacing.lg) {
                // Shield icon
                Image(systemName: "shield.checkered")
                    .font(.system(size: 80, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, AegisColors.brandAccent],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .scaleEffect(shieldScale)
                    .opacity(shieldOpacity)

                // App name
                VStack(spacing: AegisSpacing.xxs) {
                    Text("AegisShield")
                        .font(AegisTypography.displayLarge)
                        .foregroundStyle(.white)

                    Text(String(localized: "splash_tagline"))
                        .font(AegisTypography.bodySmall)
                        .foregroundStyle(.white.opacity(0.7))
                }
                .opacity(titleOpacity)
                .offset(y: titleOffset)
            }
        }
        .onAppear {
            runAnimation()
        }
    }

    private func runAnimation() {
        // Phase 1: Shield appears
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            shieldScale = 1.0
            shieldOpacity = 1.0
        }

        // Phase 2: Glow pulse
        withAnimation(.easeInOut(duration: 0.6).delay(0.3)) {
            glowOpacity = 1.0
        }

        // Phase 3: Title slides up
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            titleOpacity = 1.0
            titleOffset = 0
        }

        // Phase 4: Transition to next screen
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            appState.advanceFromSplash()
        }
    }
}
