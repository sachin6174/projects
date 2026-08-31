import Foundation

// ==============================================================================
// 🌐 ARCHITECTURAL LAYER: [NETWORK / ENDPOINT]
// 📄 FILE: NetworkEndpoint.swift (ZephyrNotesApp)
// ==============================================================================
//
// 🧸 STORY TIME: THE GPS ADDRESS BOOK FOR THE CLOUD 🗺️📍
// ------------------------------------------------------------------------------
// Imagine you are sending a letter through the postal service.
// You need two things:
//   1. An exact Street Address (e.g. "https://api.zephyrnotes.com/v1/notes").
//   2. An Action Type (e.g. "GET" = read the mailbox, "POST" = drop a new parcel,
//      "PUT" = replace a parcel, "DELETE" = take away a parcel).
//
// NetworkEndpoint is our central GPS navigation system!
// Instead of writing messy, error-prone URLs in random files, all API routes
// are defined here in one neat, type-safe enum!
//
// ==============================================================================
// 📖 DICTIONARY OF MAGIC WORDS (Keywords Explained for Kids!)
// ==============================================================================
// 1. 'HTTPMethod'       -> The verb: GET (fetch), POST (create), PUT (update), DELETE (remove).
// 2. 'URLRequest'       -> Apple's official shipping label containing URL, headers, and body bytes.
// 3. 'Endpoint'         -> A specific destination on the remote web server.
// 4. 'URLComponents'    -> A helper tool for constructing valid web addresses with query parameters.
// ==============================================================================

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

public enum NetworkEndpoint: Sendable {
    case fetchAllNotes
    case fetchNote(id: UUID)
    case createNote(note: NoteDTO)
    case updateNote(note: NoteDTO)
    case deleteNote(id: UUID)
    case batchSync(notes: [NoteDTO])

    public var baseURL: String {
        return "https://api.zephyrnotes.com/v1"
    }

    public var path: String {
        switch self {
        case .fetchAllNotes, .batchSync:
            return "/notes"
        case .fetchNote(let id):
            return "/notes/\(id.uuidString)"
        case .createNote:
            return "/notes"
        case .updateNote(let note):
            return "/notes/\(note.id.uuidString)"
        case .deleteNote(let id):
            return "/notes/\(id.uuidString)"
        }
    }

    public var method: HTTPMethod {
        switch self {
        case .fetchAllNotes, .fetchNote:
            return .get
        case .createNote, .batchSync:
            return .post
        case .updateNote:
            return .put
        case .deleteNote:
            return .delete
        }
    }

    public var body: Data? {
        switch self {
        case .createNote(let note), .updateNote(let note):
            return try? NoteDTO.jsonEncoder.encode(note)
        case .batchSync(let notes):
            return try? NoteDTO.jsonEncoder.encode(notes)
        case .fetchAllNotes, .fetchNote, .deleteNote:
            return nil
        }
    }

    public func makeURLRequest() throws -> URLRequest {
        guard let url = URL(string: baseURL + path) else {
            throw NetworkError.invalidURL(url: baseURL + path)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15.0
        request.httpBody = body

        return request
    }
}
