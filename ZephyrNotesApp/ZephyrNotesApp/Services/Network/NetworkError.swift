import Foundation

// ==============================================================================
// 🌐 ARCHITECTURAL LAYER: [NETWORK / ERROR HANDLING]
// 📄 FILE: NetworkError.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE DOCTOR'S DIAGNOSTIC REPORT 🩺📋
// ------------------------------------------------------------------------------
// Imagine your radio transmitter is making strange static sounds when trying
// to talk to the space station.
//
// Instead of just saying "Something broke!", a smart engineer gives a precise
// diagnosis:
//   - "No battery!" (No Internet Connection)
//   - "Wrong channel frequency!" (Invalid URL)
//   - "Space station refused our transmission!" (Server Error 500)
//   - "We couldn't read the alien handwriting!" (Decoding Error)
//
// NetworkError is our app's diagnostic reporting system that tells the user
// and developer EXACTLY what happened during any network call!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'Error'                  -> Swift's protocol for types that represent failure states.
// 2. 'LocalizedError'         -> Protocol that provides human-readable `errorDescription`.
// 3. 'statusCode'             -> 3-digit HTTP response code from web servers (e.g. 404, 500).
// 4. 'decodingError'          -> JSON syntax mismatch when parsing incoming network data.
// ==============================================================================

public enum NetworkError: LocalizedError, Sendable, Equatable {
    case invalidURL(url: String)
    case noInternetConnection
    case serverError(statusCode: Int, message: String)
    case decodingError(message: String)
    case encodingError(message: String)
    case timeout
    case notFound(id: UUID)
    case unknown(message: String)

    public var errorDescription: String? {
        switch self {
        case .invalidURL(let url):
            return "Invalid URL address: \(url)"
        case .noInternetConnection:
            return "No Internet Connection. Your changes are saved locally and will sync once reconnected."
        case .serverError(let code, let message):
            return "Server Error [\(code)]: \(message)"
        case .decodingError(let message):
            return "Failed to parse JSON response: \(message)"
        case .encodingError(let message):
            return "Failed to encode data payload: \(message)"
        case .timeout:
            return "Network request timed out. Please check your connection."
        case .notFound(let id):
            return "Note with ID \(id) was not found on the server."
        case .unknown(let message):
            return "An unexpected network error occurred: \(message)"
        }
    }
}
