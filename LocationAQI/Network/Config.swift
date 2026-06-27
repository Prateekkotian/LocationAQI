import Foundation

enum Config {
    // Read from Info.plist, injected at build time via Secrets.xcconfig
    static var aqiToken: String {
        Bundle.main.object(forInfoDictionaryKey: "AQICN_API_TOKEN") as? String ?? ""
    }
}
