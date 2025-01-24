import SwiftUI

struct PinKeypadScreen: View {
    @Binding var pin: String
    let maxDigits: Int
    let onComplete: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - Passcode Circles
            HStack(spacing: 1) {
                ForEach(0..<maxDigits, id: \.self) { index in
                    Circle()
                        .fill(index < pin.count ? Color.gray : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                }.padding(.bottom, 8)
            }

            // MARK: - Keypad
            VStack(spacing: 2) {
                ForEach(0..<3) { row in
                    HStack(spacing: 2) {
                        ForEach(1...3, id: \.self) { col in
                            let number = row * 3 + col
                            NumPadButton(number: number, pin: $pin, maxDigits: maxDigits, onComplete: onComplete)
                        }
                    }
                }

                // MARK: - Last Row (Dummy, 0, Delete)
                HStack(spacing: 2) {
                    DummyButton()
                    NumPadButton(number: 0, pin: $pin, maxDigits: maxDigits, onComplete: onComplete)
                    DeleteButton(pin: $pin)
                }.padding(.bottom, 30)
            }
        }
        .padding()
    }
}

// MARK: - Numeric Button
struct NumPadButton: View {
    let number: Int
    @Binding var pin: String
    let maxDigits: Int
    let onComplete: (String) -> Void

    var body: some View {
        Button(action: {
            if pin.count < maxDigits {
                pin += "\(number)"
                if pin.count == maxDigits {
                    onComplete(pin)
                }
            }
        }) {
            Text("\(number)")
                .font(.title3)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - Delete Button
struct DeleteButton: View {
    @Binding var pin: String

    var body: some View {
        Button(action: {
            if !pin.isEmpty {
                pin.removeLast()
            }
        }) {
            Image(systemName: "delete.left")
                .font(.title3)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Dummy Button
struct DummyButton: View {
    var body: some View {
        Button(action: {}) {
            Text("")
                .font(.title3)
                .foregroundColor(.primary)
        }
        .disabled(true)
    }
}
