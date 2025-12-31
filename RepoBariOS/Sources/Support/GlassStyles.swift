import SwiftUI

struct GlassBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.15, blue: 0.22),
                    Color(red: 0.08, green: 0.1, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.white.opacity(0.12), .clear],
                center: .topTrailing,
                startRadius: 40,
                endRadius: 260
            )
            .ignoresSafeArea()

            RadialGradient(
                colors: [Color.cyan.opacity(0.08), .clear],
                center: .bottomLeading,
                startRadius: 40,
                endRadius: 240
            )
            .ignoresSafeArea()
        }
    }
}

struct GlassCard<Content: View>: View {
    private let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(14)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.18), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.25), radius: 14, x: 0, y: 8)
    }
}
