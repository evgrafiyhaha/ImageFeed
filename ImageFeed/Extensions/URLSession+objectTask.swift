import Foundation

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let task = data(for: request) { (result: Result<Data, Error>) in

            let urlString = request.url?.absoluteString ?? "Unknown URL"

            switch result {
            case .success(let data):
                do {
                    let object = try decoder.decode(T.self, from: data)
                    completion(.success(object))
                } catch {
                    completion(.failure(error))
                    print("[URLSession.objectTask]: DecodingError - \(error.localizedDescription), URL: \(urlString), Данные: \(String(data: data, encoding: .utf8) ?? "неизвестные данные")")
                }
            case .failure(let error):
                print("[URLSession.objectTask]: NetworkError - \(error.localizedDescription), URL: \(urlString)")
                completion(.failure(error))

            }
        }
        return task
    }
}
