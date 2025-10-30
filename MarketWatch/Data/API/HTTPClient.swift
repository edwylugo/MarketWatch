import Alamofire
import RxSwift

struct APIErrorEnvelope: Decodable {
    let status: String?
    let code: Int?
    let message: String?
}

enum APIError: LocalizedError {
    case rateLimited(retryAfter: TimeInterval?)
    case server(message: String?)
    case decoding
    case network(Error)
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .rateLimited: return "Muitas requisições em pouco tempo. Tente novamente em instantes."
        case .server(let msg): return msg ?? "Erro do servidor."
        case .decoding: return "Falha ao interpretar os dados."
        case .network(let e): return e.localizedDescription
        case .unknown(let c): return "Erro inesperado (\(c))."
        }
    }
}

protocol HTTPClientType {
    func get<T: Decodable>(_ path: String, params: [String: String]) -> Single<T>
}

final class HTTPClient: HTTPClientType {
    private let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }

    func get<T: Decodable>(_ path: String, params: [String: String]) -> Single<T> {
        Single.create { single in
            let urlString = self.baseURL + path
            let req = AF.request(urlString, method: .get, parameters: params)
                .validate(statusCode: 200..<300)
                .responseData { resp in
                    let status = resp.response?.statusCode

                    if status == 429 {
                        let retryHeader = resp.response?.allHeaderFields["Retry-After"] as? String
                        single(.failure(APIError.rateLimited(retryAfter: TimeInterval(retryHeader ?? ""))))
                        return
                    }

                    switch resp.result {
                    case .success(let data):
                        if let env = try? JSONDecoder().decode(APIErrorEnvelope.self, from: data),
                           (env.code != nil && env.code != 0) || env.status == "error" {
                            single(.failure(APIError.server(message: env.message)))
                            return
                        }
                        if let decoded = try? JSONDecoder().decode(T.self, from: data) {
                            single(.success(decoded))
                        } else {
                            single(.failure(APIError.decoding))
                        }
                    case .failure(let err):
                        if let code = status { single(.failure(APIError.unknown(code))) }
                        else { single(.failure(APIError.network(err))) }
                    }
                }
            return Disposables.create { req.cancel() }
        }
    }
}

extension PrimitiveSequence where Trait == SingleTrait {
    func retryRateLimited(maxRetries: Int = 2, baseDelay: TimeInterval = 1.0) -> Single<Element> {
        return self.retry { (errors: Observable<Error>) in
            errors.enumerated().flatMap { (attempt, error) -> Observable<Int> in
                guard attempt < maxRetries, case APIError.rateLimited = error else {
                    return Observable.error(error)
                }
                let delay = baseDelay * pow(2.0, Double(attempt))
                return Observable<Int>.timer(.seconds(Int(delay)), scheduler: MainScheduler.instance).take(1)
            }
        }
    }
}
