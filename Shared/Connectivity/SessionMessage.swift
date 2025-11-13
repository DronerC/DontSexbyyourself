import Foundation

public enum SessionMessage: Codable {
    case start(Date)
    case end(sessionID: UUID, endDate: Date)
    case delete(sessionID: UUID)
    case replaceAll([BehaviorSession])
}
