import Foundation

class ApiHandler: ObservableObject {
    static let shared = ApiHandler()
    private init() {}

    private let baseURL = "https://map523-travel-planner-api.vercel.app/destinations"

    func getAllDestinations(completion: @escaping (Result<[DestinationDTO], ApiError>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(.FailedToGetURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.failedToFetchData))
                return
            }

            let decoder = JSONDecoder()

            if let destinations = try? decoder.decode([DestinationDTO].self, from: data) {
                completion(.success(destinations))
            } else {
                completion(.failure(.failedToDecodeData))
            }
        }.resume()
    }

    func getDestinationByID(id: Int, completion: @escaping (Result<DestinationDTO, ApiError>) -> Void) {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            completion(.failure(.FailedToGetURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.failedToFetchData))
                return
            }

            let decoder = JSONDecoder()

            if let destination = try? decoder.decode(DestinationDTO.self, from: data) {
                completion(.success(destination))
            } else {
                completion(.failure(.failedToDecodeData))
            }
        }.resume()
    }
    
    func fetchWeather(for city: String, completion: @escaping (Result<WeatherResponse, ApiError>) -> Void) {
        let apiKey = "73c9812286fd476187025208251504"
        let urlStr = "https://api.weatherapi.com/v1/current.json?key=\(apiKey)&q=\(city)&aqi=no"

        guard let url = URL(string: urlStr) else {
            completion(.failure(.FailedToGetURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.failedToFetchData))
                return
            }
            
            let decoder = JSONDecoder()

            if let weather = try? decoder.decode(WeatherResponse.self, from: data) {
                completion(.success(weather))
            } else {
                completion(.failure(.failedToDecodeData))
            }
        }.resume()
    }
    
}

// MARK: - API Error Enum
enum ApiError: String, Error {
    case FailedToGetURL = "Failed to get URL. Please try again"
    case failedToDecodeData = "Failed to decode data. Please try again"
    case failedToFetchData = "Failed to fetch data. Please check your network and try again"
}
