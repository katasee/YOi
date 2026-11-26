protocol ServiceRepository {
    func observeServices() -> AsyncThrowingStream<[Service], Error>
    @discardableResult
    func add(_ service: Service) async throws -> String
    func update(_ service: Service) async throws
    func delete(id: String) async throws
    func reorder(ids: [String]) throws
}
