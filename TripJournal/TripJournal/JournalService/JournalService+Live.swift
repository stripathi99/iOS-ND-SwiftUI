import Combine
import Foundation

enum HTTPMethods: String {
    case POST, GET, PUT, DELETE
}

enum MIMEType: String {
    case JSON = "application/json"
    case form = "application/x-www-form-urlencoded"
}

enum HTTPHeaders: String {
    case accept
    case contentType = "Content-Type"
    case authorization = "Authorization"
}

enum NetworkError: Error {
    case badUrl
    case badResponse
    case failedToDecodeResponse
    case invalidValue
}

enum SessionError: Error {
    case expired
}

extension SessionError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .expired:
            return "Your session has expired. Please log in again."
        }
    }
}

/// An live version of the `JournalService`.
class JournalServiceLive: JournalService {
    
    var tokenExpired: Bool = false
    
    @Published private var token: Token? {
        didSet {
            if let token = token {
                try? KeychainHelper.shared.saveToken(token)
            } else {
                try? KeychainHelper.shared.deleteToken()
            }
        }
    }
    
    var isAuthenticated: AnyPublisher<Bool, Never> {
        $token
            .map { $0 != nil }
            .eraseToAnyPublisher()
    }
    
    enum EndPoints {
        static let base = "http://localhost:8000/"
        
        case trips
        case login
        case media
        case events
        case register
        case handleTrip(String)
        case handleEvent(String)
        case handleMedia(String)
        
        private var stringValue: String {
            switch self {
            case .login:
                return EndPoints.base + "token"
            case .trips:
                return EndPoints.base + "trips"
            case .media:
                return EndPoints.base + "media"
            case .events:
                return EndPoints.base + "events"
            case .register:
                return EndPoints.base + "register"
            case .handleTrip(let tripId):
                return EndPoints.base + "trips/\(tripId)"
            case .handleMedia(let mediaId):
                return EndPoints.base + "media/\(mediaId)"
            case .handleEvent(let eventId):
                return EndPoints.base + "events/\(eventId)"
            }
        }
        
        var url: URL {
            return URL(string: stringValue)!
        }
    }
    
    // Shared URLSession instance
    private let urlSession: URLSession
    
    init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0
        configuration.timeoutIntervalForResource = 60.0
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        
        self.urlSession = URLSession(configuration: configuration)
        
        if let savedToken = try? KeychainHelper.shared.getToken() {
            if !isTokenExpired(savedToken) {
                self.token = savedToken
            } else {
                self.tokenExpired = true
                self.token = nil
            }
        } else {
            self.token = nil
        }
    }
    
    func register(username: String, password: String) async throws -> Token {
        let request = try createRegisterRequest(username: username, password: password)
        return try await performNetworkRequest(request, responseType: Token.self)
    }
    
    func logOut() {
        token = nil
    }
    
    func logIn(username: String, password: String) async throws -> Token {
        let request = try createLoginRequest(username: username, password: password)
        return try await performNetworkRequest(request, responseType: Token.self)
    }
    
    func createTrip(with request: TripCreate) async throws -> Trip {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: EndPoints.trips.url)
        requestURL.httpMethod = HTTPMethods.POST.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        
        let tripData: [String: Any] = [
            "name": request.name,
            "start_date": dateFormatter.string(from: request.startDate),
            "end_date": dateFormatter.string(from: request.endDate)
        ]
        
        requestURL.httpBody = try JSONSerialization.data(withJSONObject: tripData)
        return try await performNetworkRequest(requestURL, responseType: Trip.self)
    }
    
    func getTrips() async throws -> [Trip] {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: EndPoints.trips.url)
        requestURL.httpMethod = HTTPMethods.GET.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        
        return try await performNetworkRequest(requestURL, responseType: [Trip].self)
    }
    
    func getTrip(withId tripId: Trip.ID) async throws -> Trip {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: EndPoints.handleTrip(tripId.description).url)
        requestURL.httpMethod = HTTPMethods.GET.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        
        return try await performNetworkRequest(requestURL, responseType: Trip.self)
    }
    
    func updateTrip(withId tripId: Trip.ID, and updateRequest: TripUpdate) async throws -> Trip {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: EndPoints.handleTrip(tripId.description).url)
        requestURL.httpMethod = HTTPMethods.PUT.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        
        let tripData: [String: Any] = [
            "name": updateRequest.name,
            "start_date": dateFormatter.string(from: updateRequest.startDate),
            "end_date": dateFormatter.string(from: updateRequest.endDate)
        ]
        
        requestURL.httpBody = try JSONSerialization.data(withJSONObject: tripData)
        return try await performNetworkRequest(requestURL, responseType: Trip.self)
    }
    
    func deleteTrip(withId tripId: Trip.ID) async throws {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: EndPoints.handleTrip(tripId.description).url)
        requestURL.httpMethod = HTTPMethods.DELETE.rawValue
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        
        try await performVoidNetworkRequest(requestURL)
    }
    
    func createEvent(with request: EventCreate) async throws -> Event {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: EndPoints.events.url)
        requestURL.httpMethod = HTTPMethods.POST.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        
        let eventDate: [String: Any] = [
            "name": request.name,
            "date": dateFormatter.string(from: request.date),
            "note": request.note ?? "",
            "location": [
                "latitude": request.location?.latitude ?? 0,
                "longitude": request.location?.longitude ?? 0,
                "address": request.location?.address ?? ""
            ],
            "transition_from_previous": request.transitionFromPrevious as Any,
            "trip_id": request.tripId
        ]
        
        requestURL.httpBody = try JSONSerialization.data(withJSONObject: eventDate)
        return try await performNetworkRequest(requestURL, responseType: Event.self)
    }
    
    func updateEvent(withId eventId: Event.ID, and updateRequest: EventUpdate) async throws -> Event {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: EndPoints.handleEvent(eventId.description).url)
        requestURL.httpMethod = HTTPMethods.PUT.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime]
        
        let eventDate: [String: Any] = [
            "name": updateRequest.name,
            "date": dateFormatter.string(from: updateRequest.date),
            "note": updateRequest.note ?? "",
            "location": [
                "latitude": updateRequest.location?.latitude ?? 0,
                "longitude": updateRequest.location?.longitude ?? 0,
                "address": updateRequest.location?.address ?? ""
            ],
            "transition_from_previous": updateRequest.transitionFromPrevious as Any
        ]
        
        requestURL.httpBody = try JSONSerialization.data(withJSONObject: eventDate)
        return try await performNetworkRequest(requestURL, responseType: Event.self)
    }
    
    func deleteEvent(withId eventId: Event.ID) async throws {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: EndPoints.handleEvent(eventId.description).url)
        requestURL.httpMethod = HTTPMethods.DELETE.rawValue
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        
        try await performVoidNetworkRequest(requestURL)
    }
    
    func createMedia(with request: MediaCreate) async throws -> Media {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: EndPoints.media.url)
        requestURL.httpMethod = HTTPMethods.POST.rawValue
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        requestURL.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        let mediaData: [String: Any] = [
            "caption": "test-caption",
            "base64_data": request.base64Data.base64EncodedString(),
            "event_id": request.eventId
        ]
        
        print("mediaData: \(mediaData)")
        
        requestURL.httpBody = try JSONSerialization.data(withJSONObject: mediaData)
        return try await performNetworkRequest(requestURL, responseType: Media.self)
    }
    
    func deleteMedia(withId mediaId: Media.ID) async throws {
        guard let token = token else {
            throw NetworkError.invalidValue
        }
        
        var requestURL = URLRequest(url: EndPoints.handleMedia(mediaId.description).url)
        requestURL.httpMethod = HTTPMethods.DELETE.rawValue
        requestURL.addValue("Bearer \(token.accessToken)", forHTTPHeaderField: HTTPHeaders.authorization.rawValue)
        
        try await performVoidNetworkRequest(requestURL)
    }
    
    func checkIfTokenExpired() {
        if let currentToken = token,
           isTokenExpired(currentToken) {
            tokenExpired = true
            token = nil
        }
    }
    
    // utility private functions
    private func createRegisterRequest(username: String, password: String) throws -> URLRequest {
        var request = URLRequest(url: EndPoints.register.url)
        request.httpMethod = HTTPMethods.POST.rawValue
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        let registerRequest = LoginRequest(username: username, password: password)
        request.httpBody = try JSONEncoder().encode(registerRequest)
        
        return request
    }
    
    private func createLoginRequest(username: String, password: String) throws -> URLRequest {
        var request = URLRequest(url: EndPoints.login.url)
        request.httpMethod = HTTPMethods.POST.rawValue
        request.addValue(MIMEType.JSON.rawValue, forHTTPHeaderField: HTTPHeaders.accept.rawValue)
        request.addValue(MIMEType.form.rawValue, forHTTPHeaderField: HTTPHeaders.contentType.rawValue)
        
        let loginData = "grant_type=&username=\(username)&password=\(password)"
        request.httpBody = loginData.data(using: .utf8)
        
        return request
    }
    
    private func performNetworkRequest<T: Decodable>(_ request: URLRequest, responseType: T.Type) async throws -> T {
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.badResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let object = try decoder.decode(T.self, from: data)
            if var token = object as? Token {
                token.expirationDate = Token.defaultExpirationDate()
                self.token = token
            }
            return object
        } catch {
            throw NetworkError.failedToDecodeResponse
        }
    }
    
    private func performVoidNetworkRequest(_ request: URLRequest) async throws {
        let response = try await urlSession.data(for: request).1
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.badResponse
        }
    }
    
    private func isTokenExpired(_ token: Token) -> Bool {
        guard let expirationDate = token.expirationDate else {
            return false
        }
        return expirationDate <= Date()
    }
}
