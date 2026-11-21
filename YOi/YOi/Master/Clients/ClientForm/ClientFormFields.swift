struct ClientFormFields: Equatable {
    var instagram = ""
    var name = ""
    var phone = ""
    var country = PhoneCountry.poland
}

extension ClientFormFields {
    init(client: Client, fallbackCountry: PhoneCountry) {
        let country = PhoneCountry(stored: client.phone) ?? fallbackCountry
        let national = PhoneFormat.national(from: client.phone ?? "", country: country)

        instagram = client.instagram ?? ""
        name = client.name ?? ""
        phone = PhoneFormat.grouped(national, country: country)
        self.country = country
    }
}
