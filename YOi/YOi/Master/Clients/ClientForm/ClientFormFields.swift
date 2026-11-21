struct ClientFormFields: Equatable {
    var instagram = ""
    var name = ""
    var phone = ""
    var country: PhoneCountry
}

extension ClientFormFields {
    init(client: Client, fallbackCountry: PhoneCountry) {
        let parsed = PhoneFormat.parsed(client.phone)
        let country = parsed?.country ?? fallbackCountry
        let national = parsed?.national ?? PhoneFormat.national(from: client.phone ?? "", country: country)

        instagram = client.instagram ?? ""
        name = client.name ?? ""
        phone = PhoneFormat.grouped(national, country: country)
        self.country = country
    }
}
