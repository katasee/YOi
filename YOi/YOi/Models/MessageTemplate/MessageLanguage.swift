import Foundation

enum MessageLanguage: String, CaseIterable, Identifiable {
    case uk
    case pl
    case en

    static func standard(for locale: Locale) -> MessageLanguage {
        locale.language.languageCode
            .flatMap { MessageLanguage(rawValue: $0.identifier) } ?? .uk
    }

    var id: String {
        rawValue
    }

    var locale: Locale {
        switch self {
        case .uk: Locale(identifier: "uk_UA")
        case .pl: Locale(identifier: "pl_PL")
        case .en: Locale(identifier: "en_GB")
        }
    }

    var nativeName: String {
        switch self {
        case .uk: "Українська"
        case .pl: "Polski"
        case .en: "English"
        }
    }

    var defaultHeader: String {
        switch self {
        case .uk: "Вільні віконця:"
        case .pl: "Wolne terminy:"
        case .en: "Free slots:"
        }
    }

    var defaultFooter: String {
        switch self {
        case .uk: "Напишіть, який час вам зручний"
        case .pl: "Proszę dać znać, który termin pasuje"
        case .en: "Let me know which time suits you"
        }
    }
}
