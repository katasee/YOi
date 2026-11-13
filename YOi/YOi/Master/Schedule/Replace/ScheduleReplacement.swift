protocol ScheduleReplacement {
    var message: String { get }
    var entries: [ConflictEntry] { get }
}
