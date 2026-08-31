import Foundation

// ==============================================================================
// 🌐 ARCHITECTURAL LAYER: [NETWORK / REAL PRODUCTION URLSESSION SERVICE]
// 📄 FILE: URLSessionNetworkService.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE SUPERFAST ROCKET POSTMAN 🚀📫
// ------------------------------------------------------------------------------
// Imagine you want to send packages to a real physical warehouse located
// halfway around the world in Tokyo or New York.
//
// URLSession is Apple's high-speed rocket ship!
// It connects through the iPhone's antenna, beams packets across fiber optic cables,
// talks to real backend servers, checks HTTP status codes (like 200 OK or 404 Not Found),
// and decodes JSON responses with lightning speed.
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'URLSession'       -> Apple's official networking engine that transmits data over the Internet.
// 2. 'URLResponse'      -> The receipt returned by the server containing HTTP status codes.
// 3. 'HTTPURLResponse'  -> Subclass representing HTTP/HTTPS web responses.
// 4. '200...299'        -> The "All Good!" range of HTTP success status codes.
// ==============================================================================

public final class URLSessionNetworkService: NetworkServiceProtocol, Sendable {
    
    // --------------------------------------------------------------------------
    // 🔑 1. PROPERTIES
    // --------------------------------------------------------------------------
    private let session: URLSession
    
    // --------------------------------------------------------------------------
    // 🎬 2. INITIALIZER
    // --------------------------------------------------------------------------
    public init(session: URLSession = .shared) {
        self.session = session
    }

    // --------------------------------------------------------------------------
    // 🚀 3. CORE REQUEST DISPATCHER
    // --------------------------------------------------------------------------
    private func execute<T: Decodable>(_ endpoint: NetworkEndpoint) async throws -> T {
        let request = try endpoint.makeURLRequest()
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.unknown(message: "Invalid non-HTTP response received.")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "HTTP \(httpResponse.statusCode)"
                throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
            }
            
            do {
                return try NoteDTO.jsonDecoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingError(message: error.localizedDescription)
            }
        } catch let urlError as URLError {
            if urlError.code == .notConnectedToInternet || urlError.code == .networkConnectionLost {
                throw NetworkError.noInternetConnection
            } else if urlError.code == .timedOut {
                throw NetworkError.timeout
            } else {
                throw NetworkError.unknown(message: urlError.localizedDescription)
            }
        }
    }

    // --------------------------------------------------------------------------
    // 📥 4. PROTOCOL IMPLEMENTATION METHODS
    // --------------------------------------------------------------------------
    public func fetchNotes() async throws -> [NoteDTO] {
        return try await execute(.fetchAllNotes)
    }

    public func fetchNote(id: UUID) async throws -> NoteDTO {
        return try await execute(.fetchNote(id: id))
    }

    public func createNote(_ note: NoteDTO) async throws -> NoteDTO {
        return try await execute(.createNote(note: note))
    }

    public func updateNote(_ note: NoteDTO) async throws -> NoteDTO {
        return try await execute(.updateNote(note: note))
    }

    public func deleteNote(id: UUID) async throws {
        let request = try NetworkEndpoint.deleteNote(id: id).makeURLRequest()
        let (_, response) = try await session.data(for: request)
        if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: "Failed to delete note.")
        }
    }

    public func syncBatch(notes: [NoteDTO]) async throws -> [NoteDTO] {
        return try await execute(.batchSync(notes: notes))
    }
}
