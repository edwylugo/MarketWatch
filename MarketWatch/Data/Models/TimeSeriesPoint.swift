struct TimeSeriesPoint: Decodable, Equatable {
    let datetime: String
    let close: Double

    enum CodingKeys: String, CodingKey { case datetime, close }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        datetime = try c.decode(String.self, forKey: .datetime)
        close = try c.decodeStringOrDouble(forKey: .close) ?? 0
    }
    
    init(datetime: String, close: Double) {
        self.datetime = datetime
        self.close = close
    }
}
