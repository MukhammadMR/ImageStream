import ImageStream
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
    var presenter: (any ImageStream.WebViewPresenterProtocol)?
    var loadRequestCalled = false
    
    func load(request: URLRequest) {
        loadRequestCalled = true
    }
    
    func setProgressValue(_ newValue: Float) {}
    func setProgressHidden(_ isHidden: Bool) {}
}
