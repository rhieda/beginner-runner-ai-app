import HealthKit

protocol HRVRepositoryRepresentable: Actor {
    associatedtype T
    var provider: HealthKitDataRequestable { get }
    var cachedProvider: HealthKitDataRequestable? { get }

    func request(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> T
}

final actor HRVRepository: HRVRepositoryRepresentable {
    typealias Response = [Double]
    
    struct Input {
        var beginDate: Date
        var endDate: Date
    }

    var provider: any HealthKitDataRequestable
    var cachedProvider: (any HealthKitDataRequestable)?

    init(
        provider: any HealthKitDataRequestable,
        cachedProvider: (any HealthKitDataRequestable)? = nil
    ) {
        self.provider = provider
        self.cachedProvider = cachedProvider
    }

    func request(input: Input) async throws -> Response {
        try await request(
            from: input.beginDate,
            to: input.endDate
        )
    }

    func request(
        from beginDate: Date,
        to endDate: Date
    ) async throws -> Response {
        var cachedResponse: Response = []
        if let cachedProvider {
            let cachedData = try await cachedProvider.requestData(
                from: beginDate,
                to: endDate
            )
        }
        fatalError()
    }
}
