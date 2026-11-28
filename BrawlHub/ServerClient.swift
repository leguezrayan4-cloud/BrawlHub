import Foundation

struct ChatMsg: Codable {
    let role: String
    let content: String
}

struct ChatReply: Decodable {
    let reply: String
}

enum ServerError: LocalizedError {
    case notConfigured
    case unreachable
    case server(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Le serveur n'est pas encore configuré dans l'app."
        case .unreachable:
            return "Le serveur ne répond pas. Vérifie ta connexion."
        case .server(let detail):
            return detail
        }
    }
}

struct ServerClient {
    func chat(messages: [ChatMsg]) async throws -> String {
        var req = try makeRequest("/chat", method: "POST")
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(["messages": messages])
        let data = try await perform(req)
        return try JSONDecoder().decode(ChatReply.self, from: data).reply
    }

    func player(tag: String) async throws -> PlayerProfile {
        let clean = tag
            .uppercased()
            .replacingOccurrences(of: "#", with: "")
            .trimmingCharacters(in: .whitespaces)
        let req = try makeRequest("/player/\(clean)", method: "GET")
        let data = try await perform(req)
        return try JSONDecoder().decode(PlayerProfile.self, from: data)
    }

    private func makeRequest(_ path: String, method: String) throws -> URLRequest {
        let base = AppConfig.serverURL
        guard !base.contains("REMPLACE"), let url = URL(string: base + path) else {
            throw ServerError.notConfigured
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.timeoutInterval = 90
        return req
    }

    private func perform(_ req: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: req)
        } catch {
            throw ServerError.unreachable
        }
        let status = (response as? HTTPURLResponse)?.statusCode ?? 0
        guard status == 200 else {
            if status == 404 {
                throw ServerError.server("Joueur introuvable. Vérifie le tag.")
            }
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let detail = json?["detail"] as? String
            throw ServerError.server(detail ?? "Erreur \(status)")
        }
        return data
    }
}
