import SwiftUI

struct LoginView: View {
    @Bindable var appModel: AppModel
    @State private var showSettings = false

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            VStack(spacing: 12) {
                Text("RepoBar")
                    .font(.system(size: 34, weight: .semibold, design: .rounded))
                Text("Your repos, everywhere."
                )
                .font(.headline)
                .foregroundStyle(.secondary)
            }

            GlassCard {
                VStack(spacing: 16) {
                    if let error = appModel.session.lastError {
                        Text(error)
                            .font(.subheadline)
                            .foregroundStyle(.orange)
                            .multilineTextAlignment(.center)
                    }

                    if appModel.session.account == .loggingIn {
                        ProgressView("Signing in…")
                            .frame(maxWidth: .infinity)
                    } else {
                        Button {
                            Task { await appModel.login() }
                        } label: {
                            Label("Sign in with GitHub", systemImage: "person.crop.circle.badge.checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Button("Settings") {
                        showSettings = true
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: 360)
            }
            Spacer()
        }
        .padding(24)
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView(appModel: appModel)
            }
        }
    }
}
