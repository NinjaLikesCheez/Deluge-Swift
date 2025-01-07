import Deluge
import Combine
import XCTest

class IntegrationTestCase {
    var client: Deluge!
    var cancellables: Set<AnyCancellable>!

    init() {
        client = Deluge(
            baseURL: TestConfig.serverURL,
            password: TestConfig.serverPassword
        )

        cancellables = Set()
    }
}
