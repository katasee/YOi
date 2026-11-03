#if DEBUG
import Foundation

enum ClientsPreviewData {
    static let clients: [Client] = [
        Client(id: "client-olya", name: "Оля", instagram: "olya.nails", phone: "+48600123456", createdAt: daysAgo(1)),
        Client(id: "client-kate", name: "Катя", instagram: "kate_m", createdAt: daysAgo(3)),
        Client(id: "client-marina", name: "Марина", phone: "+48511222333", createdAt: daysAgo(8)),
        Client(id: "client-sonya", instagram: "sonya.art", createdAt: daysAgo(12)),
        Client(id: "client-long", name: "Олександра-Вікторія Коваленко-Шевчук", instagram: "oleksandra.viktoria.kovalenko", phone: "+48733444555", createdAt: daysAgo(20)),
        Client(id: "client-legacy", name: "Ірина", phone: "600 12 34", createdAt: daysAgo(35)),
        Client(id: "client-name-only", name: "Наталя", createdAt: daysAgo(40)),
        Client(id: "client-empty-handle", name: "Катя", instagram: "", createdAt: daysAgo(45))
    ]

    static let visits: [Slot] = [
        Slot(id: "visit-planned-1500", date: day(4), time: "15:00", clientId: "client-olya", serviceId: "svc-classic", serviceName: "Класичний манікюр", servicePrice: 500),
        Slot(id: "visit-planned-1000", date: day(4), time: "10:00", clientId: "client-olya", serviceId: "svc-gel", serviceName: "Гель-лак", servicePrice: 600),
        Slot(id: "visit-past-service", date: day(-6), time: "11:00", clientId: "client-olya", serviceId: "svc-classic", serviceName: "Класичний манікюр", servicePrice: 500),
        Slot(id: "visit-past-none", date: day(-20), time: "12:00", clientId: "client-olya"),
        Slot(id: "visit-pair-1000", date: day(-34), time: "10:00", clientId: "client-olya", serviceId: "svc-gel", serviceName: "Гель-лак", servicePrice: 600),
        Slot(id: "visit-pair-1500", date: day(-34), time: "15:00", clientId: "client-olya", serviceId: "svc-classic", serviceName: "Класичний манікюр", servicePrice: 500),
        Slot(id: "visit-other", date: day(-2), time: "09:00", clientId: "client-marina"),
        Slot(id: "visit-free", date: day(1), time: "13:00")
    ]

    private static func day(_ offset: Int) -> String {
        DateFormat.date.string(from: Date(timeIntervalSinceNow: Double(offset) * 86_400))
    }

    private static func daysAgo(_ days: Int) -> Date {
        Date(timeIntervalSinceNow: -Double(days) * 86_400)
    }
}
#endif
