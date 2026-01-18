//
//  BackendSettingsView.swift
//  RockClimber
//
//  Created on 2026-01-17
//

import SwiftUI

struct BackendSettingsView: View {
    @AppStorage(APIClient.backendBaseURLOverrideKey) private var baseURLOverride = ""

    @State private var draftBaseURL = ""
    @State private var testStatus: TestStatus?
    @State private var isTesting = false

    @Environment(\.dismiss) private var dismiss

    enum TestStatus: Equatable {
        case success
        case failure(String)
    }

    init() {
        _draftBaseURL = State(initialValue: UserDefaults.standard.string(forKey: APIClient.backendBaseURLOverrideKey) ?? "")
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Backend URL") {
                    TextField("http://127.0.0.1:8000", text: $draftBaseURL)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.URL)
                        .autocorrectionDisabled()

                    Text("Current: \(APIClient.shared.baseURLString)")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    HStack {
                        Button("Use Default") {
                            draftBaseURL = ""
                            testStatus = nil
                        }

                        Spacer()

                        Button("Save") {
                            baseURLOverride = draftBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)
                            testStatus = nil
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }

                Section("Connection") {
                    Button {
                        Task { await testConnection() }
                    } label: {
                        if isTesting {
                            HStack(spacing: 8) {
                                ProgressView()
                                Text("Testing…")
                            }
                        } else {
                            Text("Test Connection")
                        }
                    }
                    .disabled(isTesting)

                    switch testStatus {
                    case .success:
                        Text("Success")
                            .foregroundColor(.green)
                    case .failure(let message):
                        Text(message)
                            .foregroundColor(.red)
                    case .none:
                        EmptyView()
                    }
                }

                Section("Tips") {
                    Text("iOS Simulator: use http://127.0.0.1:8000 when the backend runs on your Mac.")
                    Text("Physical device: use http://<your-mac-lan-ip>:8000 and run the backend with --host 0.0.0.0.")
                }
                .font(.footnote)
                .foregroundColor(.secondary)
            }
            .navigationTitle("Backend Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    @MainActor
    private func testConnection() async {
        isTesting = true
        testStatus = nil
        defer { isTesting = false }

        baseURLOverride = draftBaseURL.trimmingCharacters(in: .whitespacesAndNewlines)

        do {
            _ = try await APIClient.shared.requestData(path: "/openapi.json", method: .get)
            testStatus = .success
        } catch let apiError as APIError {
            testStatus = .failure(apiError.message)
        } catch {
            testStatus = .failure(error.localizedDescription)
        }
    }
}

#Preview {
    BackendSettingsView()
}

