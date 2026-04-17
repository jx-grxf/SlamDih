import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @Bindable var monitor: SlapMonitor

    @State private var pendingImportSound: SlapSound?
    @State private var isShowingImportDisclaimer = false
    @State private var isShowingFileImporter = false
    @State private var importErrorMessage: String?

    var body: some View {
        Form {
            Section("Detection") {
                Slider(value: $monitor.threshold, in: SlapMonitor.thresholdRange, step: SlapMonitor.thresholdStep) {
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
                Toggle("Activate NSFW Sounds", isOn: $monitor.isNSFWSoundsEnabled)
                    .toggleStyle(.switch)

                Picker("Sound", selection: $monitor.selectedSound) {
                    ForEach(monitor.availableSounds) { sound in
                        Label(sound.title, systemImage: sound.symbol)
                            .tag(sound)
                    }
                }
                .pickerStyle(.segmented)

                ForEach(monitor.availableSounds) { sound in
                    SoundCustomizationRow(monitor: monitor, sound: sound) { sound in
                        pendingImportSound = sound
                        isShowingImportDisclaimer = true
                    }
                }

                HStack {
                    Text("Selected sound")
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
        .frame(width: 480, height: 510)
        .padding()
        .alert("Enable Custom Audio?", isPresented: $isShowingImportDisclaimer) {
            Button("Choose File") {
                isShowingFileImporter = true
            }

            Button("Cancel", role: .cancel) {
                pendingImportSound = nil
            }
        } message: {
            Text("SlamDih will copy the selected audio file into its local custom-sound folder. Very long files can delay playback the first time they are loaded.")
        }
        .fileImporter(
            isPresented: $isShowingFileImporter,
            allowedContentTypes: [.audio],
            allowsMultipleSelection: false
        ) { result in
            importCustomAudio(from: result)
        }
        .alert("Import Failed", isPresented: importErrorBinding) {
            Button("OK", role: .cancel) {
                importErrorMessage = nil
            }
        } message: {
            Text(importErrorMessage ?? "The selected audio file could not be imported.")
        }
    }

    private var importErrorBinding: Binding<Bool> {
        Binding {
            importErrorMessage != nil
        } set: { isPresented in
            if !isPresented {
                importErrorMessage = nil
            }
        }
    }

    private func importCustomAudio(from result: Result<[URL], Error>) {
        guard let pendingImportSound else {
            return
        }

        defer {
            self.pendingImportSound = nil
        }

        do {
            guard let url = try result.get().first else {
                return
            }

            try monitor.importCustomSound(from: url, for: pendingImportSound)
        } catch {
            importErrorMessage = error.localizedDescription
        }
    }
}

private struct SoundCustomizationRow: View {
    @Bindable var monitor: SlapMonitor
    let sound: SlapSound
    let importAction: (SlapSound) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Label(sound.title, systemImage: sound.symbol)
                    .symbolRenderingMode(.hierarchical)

                Spacer()

                Button {
                    importAction(sound)
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.borderless)
                .help("Add custom \(sound.title) audio")
            }

            if !customSounds.isEmpty {
                Picker("Audio File", selection: customSelection) {
                    Text("Default \(sound.title)").tag("")

                    ForEach(customSounds) { customSound in
                        Text(customSound.title).tag(customSound.id)
                    }
                }
            }
        }
    }

    private var customSounds: [CustomSlapSound] {
        monitor.customSounds(for: sound)
    }

    private var customSelection: Binding<String> {
        Binding {
            monitor.customSoundSelectionID(for: sound)
        } set: { selection in
            monitor.setCustomSoundSelectionID(selection, for: sound)
        }
    }
}
