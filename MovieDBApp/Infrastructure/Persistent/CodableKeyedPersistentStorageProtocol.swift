import Foundation

public protocol CodableKeyedPersistentStorageProtocol {
    func save<T: Codable>(_ codable: T, key: String)
    func load<T: Codable>(key: String) -> T?
}

extension UserDefaults: CodableKeyedPersistentStorageProtocol {
    public func save<T>(_ codable: T, key: String) where T : Decodable, T : Encodable {
        let encoder = JSONEncoder()
        let encoded = try? encoder.encode(codable)

        set(encoded, forKey: key)
    }

    public func load<T>(key: String) -> T? where T : Decodable, T : Encodable {
        let decoder = JSONDecoder()

        if let data = value(forKey: key) as? Data {
            return try? decoder.decode(T.self, from: data)
        }
        return nil
    }
}
