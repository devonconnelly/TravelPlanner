import Foundation

struct WeatherResponse: Codable {
    let location: Location
    let current: CurrentWeather
}

struct Location: Codable {
    let name: String
    let region: String
    let country: String
    let lat: Double
    let lon: Double
    let tz_id: String
    let localtime: String
}

struct CurrentWeather: Codable {
    let last_updated: String
    let temp_c: Double
    let is_day: Int
    let condition: Condition
    let wind_kph: Double
    let humidity: Int
    let cloud: Int
    let feelslike_c: Double
}

struct Condition: Codable {
    let text: String
    let icon: String
    let code: Int
}
