import Foundation

extension Sequence where Element == Service {
    func sortedByOrder() -> [Service] {
        sorted { lhs, rhs in
            switch (lhs.position, rhs.position) {
            case (nil, nil):
                lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
            case (nil, _):
                true
            case (_, nil):
                false
            case let (left?, right?):
                left == right
                    ? lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
                    : left < right
            }
        }
    }
}

extension Array where Element == Service {
    var nextPosition: Int {
        (compactMap(\.position).max() ?? -1) + 1
    }

    var ids: [String] {
        compactMap(\.id)
    }

    func moving(_ id: String, to targetId: String) -> [Service] {
        guard
            id != targetId,
            let source = firstIndex(where: { $0.id == id }),
            let target = firstIndex(where: { $0.id == targetId })
        else { return self }

        var moved = self
        let service = moved.remove(at: source)
        moved.insert(service, at: target)

        return moved
    }
}
