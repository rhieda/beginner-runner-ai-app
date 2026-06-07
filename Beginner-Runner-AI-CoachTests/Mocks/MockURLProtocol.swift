import Foundation

class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let handler = MockURLProtocol.requestHandler else {
            return
        }
        
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
    
    override func stopLoading() {}
}

extension URLRequest {
    func getBodyData() -> Data? {
        if let httpBody = self.httpBody {
            return httpBody
        }
        if let httpBodyStream = self.httpBodyStream {
            httpBodyStream.open()
            let bufferSize = 1024
            let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
            defer { buffer.deallocate() }
            var data = Data()
            while httpBodyStream.hasBytesAvailable {
                let read = httpBodyStream.read(buffer, maxLength: bufferSize)
                if read < 0 {
                    return nil
                } else if read == 0 {
                    break
                }
                data.append(buffer, count: read)
            }
            httpBodyStream.close()
            return data
        }
        return nil
    }
}
