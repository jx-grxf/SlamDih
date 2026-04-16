import SwiftUI

struct SettingsView: View {
    @Bindable var monitor: SlapMonitor

    var body: some View {
        Form {
            Section("Detection") {
                Slider(value: $monitor.threshold, in: 0.15...2.5, step: 0.05) {
                    Text("Threshold")
                } minimumValueLabel: {
                    Text("Soft")
                } maximumValueLabel: {
                    Text("Hard")
                }

                Text("\(monitor.threshold, specifier: "%.2f") g")
                    .font(.system(.body, design: .monospaced))
            }

            Section("Audio") {
                HStack {
                    Text("Slap sound")
                    Spacer()
                    Text(monitor.soundStatus)
                        .foregroundStyle(.secondary)
                }

                Button("Test Sound") {
                    monitor.playTestSound()
                }
            }
        }
        .formStyle(.grouped)
        .frame(width: 420, height: 260)
        .padding()
    }
}
