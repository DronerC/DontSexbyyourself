import Foundation

/// A tiny utility that reads and writes codable payloads on disk.
public struct DiskStorage<Value: Codable> {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "DiskStorageQueue", qos: .utility)

    public init(filename: String) {
        let directory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first ?? FileManager.default.temporaryDirectory
        if !FileManager.default.fileExists(atPath: directory.path) {
            try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        }
        self.fileURL = directory.appendingPathComponent(filename)
    }

    public func load() -> Value? {
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode(Value.self, from: data)
        } catch {
            return nil
        }
    }

    public func save(_ value: Value) {
        queue.async {
            do {
                let data = try JSONEncoder().encode(value)
                try data.write(to: fileURL, options: .atomic)
            } catch {
                #if DEBUG
                print("DiskStorage save error: \(error)")
                #endif
            }
        }
    }

    public func delete() {
        try? FileManager.default.removeItem(at: fileURL)
    }
}
