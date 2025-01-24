import SwiftUI

struct ContentView: View {
    @State private var accessToken = ""
    @State private var deviceId = ""
    @State private var vehicleId = ""
    @State private var controlToken = ""
    @State private var pin = ""
    @State private var isLocked = false
    @State private var lastControlTokenTime: Date? = nil
    @State private var isLoading: Bool = false
    @State private var hasError: Bool = false
    @State private var showPinScreen: Bool = true

    // MARK: - Credentials
    let userEmail = "your@mail.com"
    let userPassword = "easy123"

    var body: some View {
        ZStack {
            if showPinScreen {
                PinKeypadScreen(
                    pin: $pin,
                    maxDigits: 4,
                    onComplete: { enteredPin in
                        handlePinEntered(enteredPin)
                    }
                )
            } else {
                TabView {
                    LockUnlockScreen(
                        accessToken: $accessToken,
                        deviceId: $deviceId,
                        vehicleId: $vehicleId,
                        controlToken: $controlToken,
                        pin: $pin,
                        isLocked: $isLocked,
                        lastControlTokenTime: $lastControlTokenTime,
                        hasError: $hasError,
                        isLoading: $isLoading,
                        onRefresh: {
                            refreshData()
                        },
                        onFetchStatus: { completion in
                            fetchStatus(completion: completion)
                        }
                    )
                    .tabItem {
                        Label("Main", systemImage: "lock.fill")
                    }
                }
            }
        }
        .onAppear {
            refreshData()
        }
    }

    // MARK: - Handle PIN Entered
    func handlePinEntered(_ enteredPin: String) {
        pin = enteredPin
        generateControlToken()
    }

    // MARK: - Refresh Data
    func refreshData() {
        isLoading = true
        hasError = false
        showPinScreen = true
        pin = ""
        authenticateUser()
    }

    // MARK: - Authenticate User
    func authenticateUser() {
        let credentials: [String: Any] = ["email": userEmail, "password": userPassword]
        guard let url = URL(string: "http://localhost:3000/auth/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: credentials, options: [])
        } catch {
            print("Error serializing JSON data.")
            hasError = true
            isLoading = false
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Authentication error: \(error.localizedDescription)")
                    hasError = true
                    return
                }

                guard let data = data,
                      let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []),
                      let responseDict = jsonResponse as? [String: Any],
                      let token = responseDict["accessToken"] as? String else {
                    print("Failed to authenticate or parse response.")
                    hasError = true
                    return
                }

                accessToken = token
                deviceId = responseDict["deviceId"] as? String ?? ""
                fetchVehicles()
            }
        }.resume()
    }

    // MARK: - Fetch Vehicles
    func fetchVehicles() {
        guard !accessToken.isEmpty, !deviceId.isEmpty else {
            print("Error: Missing access token or device ID.")
            hasError = true
            isLoading = false
            return
        }

        let params = "accessToken=\(accessToken)&deviceId=\(deviceId)"
        guard let url = URL(string: "http://localhost:3000/vehicle?\(params)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    print("Error fetching vehicles: \(error.localizedDescription)")
                    hasError = true
                    return
                }

                guard let data = data,
                      let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []),
                      let vehicles = jsonResponse as? [[String: Any]],
                      let firstVehicle = vehicles.first,
                      let vehicleId = firstVehicle["vehicleId"] as? String else {
                    print("No vehicles found or failed to parse response.")
                    hasError = true
                    return
                }

                self.vehicleId = vehicleId
                fetchStatus { _ in }
            }
        }.resume()
    }

    // MARK: - Fetch Status
    func fetchStatus(completion: @escaping (Bool) -> Void) {
        print("Fetching vehicle status...")
        guard !accessToken.isEmpty, !vehicleId.isEmpty else {
            print("Error: Missing required parameters.")
            hasError = true
            isLoading = false
            completion(false)
            return
        }

        let params = "deviceId=\(deviceId)&accessToken=\(accessToken)"
        guard let url = URL(string: "http://localhost:3000/vehicle/\(vehicleId)/status?\(params)") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching status: \(error.localizedDescription)")
                    hasError = true
                    completion(false)
                    return
                }

                guard let data = data,
                      let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []),
                      let responseDict = jsonResponse as? [String: Any],
                      let doorLock = responseDict["doorLock"] as? Bool else {
                    print("Failed to fetch status or parse response.")
                    hasError = true
                    completion(false)
                    return
                }

                let previousState = isLocked
                isLocked = doorLock
                print("Door lock status updated: \(isLocked)")

                if isLocked != previousState {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }.resume()
    }

    // MARK: - Generate Control Token
    func generateControlToken() {
        guard !accessToken.isEmpty, !deviceId.isEmpty, !pin.isEmpty else {
            print("Error: Missing required parameters.")
            return
        }

        let requestBody: [String: Any] = [
            "accessToken": accessToken,
            "pin": pin,
            "deviceId": deviceId
        ]

        guard let url = URL(string: "http://localhost:3000/pin") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
        } catch {
            print("Error serializing JSON data.")
            return
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error generating control token: \(error.localizedDescription)")
                    showPinScreen = true
                    return
                }

                guard let data = data,
                      let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []),
                      let responseDict = jsonResponse as? [String: Any],
                      let token = responseDict["controlToken"] as? String else {
                    print("Failed to generate control token.")
                    showPinScreen = true
                    return
                }

                controlToken = token
                lastControlTokenTime = Date()
                showPinScreen = false
            }
        }.resume()
    }
}
