import Foundation
import Network
import Combine

// ==============================================================================
// 📡 ARCHITECTURAL LAYER: [CONNECTIVITY MONITOR]
// 📄 FILE: NetworkMonitor.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE WEATHER ROOFTOP RADAR TOWER 📡🗼
// ------------------------------------------------------------------------------
// Imagine you have a tall radar antenna sitting on the roof of your house.
// It constantly scans the sky to see:
//   - "Is the sun shining? (Wi-Fi is strong!)"
//   - "Is it a heavy thunderstorm? (Internet connection lost!)"
//
// NetworkMonitor is our iPhone's radar tower!
// Using Apple's `Network.NWPathMonitor`, it watches the phone's Wi-Fi and Cellular
// connections 24/7.
//
// The moment connection drops:
//   It shouts: "Hey App! We just went OFFLINE! Save all notes into the local vault!"
// The instant the signal returns:
//   It shouts: "Hey App! We're back ONLINE! Let's sync all pending notes immediately!"
//
// It also has a special "Simulation Switch" so developers and testers can pretend
// to turn off the internet right from the screen without touching real Wi-Fi settings!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'NWPathMonitor'    -> Apple's official radar antenna that tracks internet connectivity.
// 2. 'DispatchQueue'    -> A background conveyor belt where our antenna does its scanning.
// 3. '@Published'       -> Live Microphone: Notifies SwiftUI views when connection changes.
// 4. 'ObservableObject' -> An object that can broadcast its state changes to SwiftUI views.
// 5. '@MainActor'       -> Ensures UI-bound variables are only modified on the Main Thread.
// ==============================================================================

@MainActor
public class NetworkMonitor: ObservableObject {
    
    // --------------------------------------------------------------------------
    // 🔑 1. SHARED SINGLETON INSTANCE
    // --------------------------------------------------------------------------
    public static let shared = NetworkMonitor()

    // --------------------------------------------------------------------------
    // 📡 2. INTERNAL NWPATHMONITOR & BACKGROUND QUEUE
    // --------------------------------------------------------------------------
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "com.zephyrnotes.networkmonitor", qos: .background)

    // --------------------------------------------------------------------------
    // 📢 3. PUBLISHED CONNECTIVITY STATES
    // --------------------------------------------------------------------------
    
    @Published public private(set) var isRealNetworkConnected: Bool = true
    
    @Published public var isSimulatingOffline: Bool = false {
        didSet {
            Task {
                await MockNetworkService.shared.setOfflineSimulation(isSimulatingOffline)
            }
        }
    }
    
    @Published public private(set) var isExpensive: Bool = false

    // --------------------------------------------------------------------------
    // 🟢 4. EFFECTIVE CONNECTION STATUS (Combines Real + Simulated Status)
    // --------------------------------------------------------------------------
    public var isConnected: Bool {
        return !isSimulatingOffline && isRealNetworkConnected
    }

    // --------------------------------------------------------------------------
    // 🎬 5. INITIALIZER (Starts Radar Scanning)
    // --------------------------------------------------------------------------
    private init() {
        startMonitoring()
    }

    // --------------------------------------------------------------------------
    // 🚀 6. RADAR MONITORING LOGIC
    // --------------------------------------------------------------------------
    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                let isNowConnected = (path.status == .satisfied)
                let isExp = path.isExpensive
                
                self.isRealNetworkConnected = isNowConnected
                self.isExpensive = isExp
                
                print("📡 [NetworkMonitor] Status: \(isNowConnected ? "ONLINE 🟢" : "OFFLINE 🔴") | Expensive: \(isExp)")
            }
        }
        monitor.start(queue: queue)
    }

    deinit {
        monitor.cancel()
    }
}
