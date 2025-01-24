import SwiftUI

struct LockUnlockScreen: View {
    @Binding var accessToken: String
    @Binding var deviceId: String
    @Binding var vehicleId: String
    @Binding var controlToken: String
    @Binding var pin: String
    @Binding var isLocked: Bool
    @Binding var lastControlTokenTime: Date?
    @Binding var hasError: Bool
    @Binding var isLoading: Bool

    var onRefresh: () -> Void
    var onFetchStatus: (@escaping (Bool) -> Void) -> Void

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading...")
                    .progressViewStyle(CircularProgressViewStyle())
                    .padding()
            } else if hasError {
                VStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.red)
                        .padding(.bottom, 10)

                    Button(action: onRefresh) {
                        Text("Refresh")
                            .font(.title)
                            .padding()
                    }
                }
            } else {
                Image(systemName: isLocked ? "lock.fill" : "lock.open.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .padding(.bottom, 10)

                Button(action: sendLockCommand) {
                    Text("Lock")
                        .font(.title)
                }
                .disabled(isLocked)
                .padding(.bottom, 5)

                Button(action: sendUnlockCommand) {
                    Text("Unlock")
                        .font(.title)
                }
                .disabled(!isLocked)
            }
        }
        .padding()
    }

    // MARK: - Lock Command
    func sendLockCommand() {
        isLoading = true
        sendControlDoorRequest(action: "close")
    }

    // MARK: - Unlock Command
    func sendUnlockCommand() {
        isLoading = true
        sendControlDoorRequest(action: "open")
    }

    // MARK: - Polling Status
    func startPollingStatus(maxDuration: TimeInterval = 45, interval: TimeInterval = 5) {
        let maxAttempts = Int(maxDuration / interval)
        var attempts = 0

        func poll() {
            if attempts >= maxAttempts {
                print("Polling stopped: maximum duration reached.")
                isLoading = false
                hasError = true
                return
            }

            attempts += 1
            print("Polling attempt \(attempts)...")

            onFetchStatus { success in
                DispatchQueue.main.async {
                    if success {
                        print("Status updated successfully. Polling stopped.")
                        isLoading = false
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
                            poll()
                        }
                    }
                }
            }
        }

        isLoading = true
        poll()
    }

    // MARK: - Send Control Door Request
    func sendControlDoorRequest(action: String) {
        guard !controlToken.isEmpty, !vehicleId.isEmpty else {
            print("Error: Missing required parameters.")
            return
        }

        let requestBody: [String: Any] = [
            "controlToken": controlToken,
            "vehicleId": vehicleId,
            "action": action,
            "deviceId": deviceId
        ]

        guard let url = URL(string: "http://localhost:3000/vehicle/control-door") else {
            print("Error: Invalid URL.")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error serializing JSON data: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error sending control door request: \(error.localizedDescription)")
                return
            }

            if let response = response as? HTTPURLResponse {
                if response.statusCode == 200 {
                    print("Door action '\(action)' successful.")
                    startPollingStatus()
                } else {
                    print("Error: Unexpected response status code \(response.statusCode).")
                }
            }
        }.resume()
    }
}
