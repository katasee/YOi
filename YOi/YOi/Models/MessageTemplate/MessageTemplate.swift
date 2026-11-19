import Foundation

struct MessageTemplate: Equatable {
    var style: String?
    var language: String?
    var headers: [String: String]?
    var footers: [String: String]?

    var dayStyle: MessageDayStyle {
        style.flatMap(MessageDayStyle.init(rawValue:)) ?? .standard
    }

    var messageLanguage: MessageLanguage {
        language.flatMap(MessageLanguage.init(rawValue:)) ?? .standard(for: .current)
    }

    mutating func setDayStyle(_ dayStyle: MessageDayStyle) {
        style = dayStyle.rawValue
    }

    mutating func setLanguage(_ messageLanguage: MessageLanguage) {
        language = messageLanguage.rawValue
    }

    func header(for language: MessageLanguage) -> String {
        headers?[language.rawValue] ?? language.defaultHeader
    }

    func footer(for language: MessageLanguage) -> String {
        footers?[language.rawValue] ?? language.defaultFooter
    }

    func hasHeader(for language: MessageLanguage) -> Bool {
        headers?[language.rawValue] != nil
    }

    func hasFooter(for language: MessageLanguage) -> Bool {
        footers?[language.rawValue] != nil
    }

    mutating func setHeader(_ text: String?, for language: MessageLanguage) {
        headers = Self.setting(text, for: language, in: headers)
    }

    mutating func setFooter(_ text: String?, for language: MessageLanguage) {
        footers = Self.setting(text, for: language, in: footers)
    }

    private static func setting(
        _ text: String?,
        for language: MessageLanguage,
        in texts: [String: String]?
    ) -> [String: String]? {
        var texts = texts ?? [:]
        texts[language.rawValue] = text
        return texts.isEmpty ? nil : texts
    }
}
