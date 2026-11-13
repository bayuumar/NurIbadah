import Foundation
import CoreLocation

// MARK: - Indonesian City Model
struct CityLocation: Identifiable, Codable, Equatable, Hashable {
    let id: String
    let name: String
    let province: String
    let latitude: Double
    let longitude: Double
    let timezoneOffsetHours: Double // +7 (WIB), +8 (WITA), +9 (WIT)
    let timezoneName: String // "WIB", "WITA", "WIT"
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var timeZone: TimeZone {
        TimeZone(secondsFromGMT: Int(timezoneOffsetHours * 3600)) ?? .current
    }
    
    static let defaultCity = CityLocation(
        id: "jakarta",
        name: "Jakarta",
        province: "DKI Jakarta",
        latitude: -6.2088,
        longitude: 106.8456,
        timezoneOffsetHours: 7.0,
        timezoneName: "WIB"
    )
}
