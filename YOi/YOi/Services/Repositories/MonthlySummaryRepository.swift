protocol MonthlySummaryRepository {
    func observeSummaries() -> AsyncThrowingStream<[MonthlySummary], Error>
    func fetchSummaryIds() async throws -> Set<String>
    func add(_ summaries: [MonthlySummary]) throws
    func delete(ids: [String]) throws
}
