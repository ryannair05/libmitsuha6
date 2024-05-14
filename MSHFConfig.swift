import UIKit

private func colorFromPropertyList(value: String) -> CGColor? {
    let parts = value.components(separatedBy: ":")
    let hexPart = parts.first?.filter({ $0 != "#" && $0 != " " }).uppercased()

    var alpha: CGFloat = 1.0
    if parts.count > 1, let alphaString = parts.last, let alphaValue = Float(alphaString) {
        alpha = CGFloat(alphaValue)
    }

    guard let hexString = hexPart, let hex = Int(hexString, radix: 16) else { return nil }

    let red, green, blue: CGFloat
    switch hexString.count {
    case 3:
        (red, green, blue) = (
            CGFloat((hex & 0xF00) >> 8) / 15.0,
            CGFloat((hex & 0x0F0) >> 4) / 15.0,
            CGFloat(hex & 0x00F) / 15.0
        )
    case 6:
        (red, green, blue) = (
            CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            CGFloat((hex & 0x00FF00) >> 8) / 255.0,
            CGFloat(hex & 0x0000FF) / 255.0
        )
    default:
        return nil
    }

    return CGColor(red: red, green: green, blue: blue, alpha: alpha)
}

@objc (MSHFConfig) final public class MSHFConfig: NSObject {

    @objc private var enabled = false
    @objc private var style = 0
    @objc private var colorMode = 0
    @objc private var waveOffset: CGFloat = 0.0
    @objc private var waveOffsetOffset: CGFloat = 0.0
    @objc private var view: MSHFView?
    private var application: String?
    private var dynamicColorAlpha: CGFloat = 0.7
    private var waveColor: CGColor?
    private var calculatedColor: CGColor?
    private var prefs: [String: Any]

    @objc init(dictionary dict: [String: Any]) {
        prefs = dict
        if let app = prefs["application"] as? String {
            application = app
        }
        super.init()
        setDictionary()
    }

    @objc init(appName name: String) {
        application = name
        prefs = [:]
        super.init()
        parseConfig()
    }

    @objc public func initializeView(withFrame frame: CGRect) -> MSHFView? {
        let barSpacing = prefs["barSpacing"] as? CGFloat ?? 5
        let barCornerRadius = prefs["barCornerRadius"] as? CGFloat ?? 0
        let lineThickness = prefs["lineThickness"] as? CGFloat ?? 5

        view = switch style {
            case 1:
                MSHFBarView(frame: frame, barSpacing: barSpacing, barCornerRadius: barCornerRadius)
            case 2:
                MSHFLineView(frame: frame, lineThickness: lineThickness)
            case 3:
                MSHFDotView(frame: frame, barSpacing: barSpacing)
            case 4:
                MSHFSiriView(frame: frame)
            default:
                MSHFJelloView(frame: frame)
        }

        configureView()

        return view
    }

    private func configureView() {
        let view = view.unsafelyUnwrapped

        let fps = prefs["fps"] as? Float ?? 24
        view.displayLink!.preferredFrameRateRange = CAFrameRateRange(minimum: fps/2, maximum: fps, preferred: 0)
        if let numberOfPoints = prefs["numberOfPoints"] as? Int {
            view.numberOfPoints = numberOfPoints
        }
        view.waveOffset = waveOffset + waveOffsetOffset
        if let gain = prefs["gain"] as? Float {
            view.gain = gain
        }
        if let gain = prefs["limiter"] as? Float {
            view.limiter = gain
        }
        if let gain = prefs["sensitivity"] as? CGFloat {
            view.sensitivity = gain
        }
        if let enableFFT = prefs["enableFFT"] as? Bool {
            view.audioProcessing?.fft = enableFFT
        }
        if let disableBatterySaver = prefs["disableBatterySaver"] as? Bool {
            view.disableBatterySaver = disableBatterySaver
        }

        view.siriEnabled = colorMode == 1

        if let waveColor, colorMode == 2 {
            view.updateWave(waveColor, subwaveColor: waveColor)
        } else if colorMode == 1 {
            view.updateWave(waveColor, subwaveColor: waveColor, subSubwaveColor: waveColor)
        } else if let calculatedColor {
            view.updateWave(calculatedColor, subwaveColor: calculatedColor)
        }
    }

    private func getAverageColor(from image: UIImage, withAlpha alpha: CGFloat) -> CGColor {
        let size = CGSize(width: 1, height: 1)
        let renderer = UIGraphicsImageRenderer(size: size)

        let artwork = renderer.image { ctx in
            ctx.cgContext.interpolationQuality = .medium
            image.draw(in: CGRect(origin: .zero, size: size), blendMode: .copy, alpha: 1)
        }

        let data = UnsafeBufferPointer(start: CFDataGetBytePtr(artwork.cgImage?.dataProvider?.data), count: 4).map { CGFloat($0) }

        return CGColor(red: data[0] / 255.0, green: data[1] / 255.0, blue: data[2] / 255.0, alpha: alpha)
    }

    @objc public func colorizeView(_ image: UIImage?) {
        guard let view else {
            return
        }

        if colorMode == 1 {
            let color = CGColor(red: 1, green: 0, blue: 0, alpha: dynamicColorAlpha)
            let scolor = CGColor(red: 0, green: 1, blue: 0, alpha: dynamicColorAlpha)
            let sscolor = CGColor(red: 0, green: 0, blue: 1, alpha: dynamicColorAlpha)

            view.updateWave(color, subwaveColor: scolor, subSubwaveColor: sscolor)
        } else if let image, colorMode == 0 {
            calculatedColor = getAverageColor(from: image, withAlpha: dynamicColorAlpha)
            view.updateWave(calculatedColor, subwaveColor: calculatedColor)
        } else {
            view.updateWave(waveColor, subwaveColor: waveColor)
        }
    }

    private func setDictionary() {
        enabled = prefs["enabled"] as? Bool ?? true

        style = prefs["style"] as? Int ?? 0
        colorMode = prefs["colorMode"] as? Int ?? 0
        if let colorAlpha = prefs["dynamicColorAlpha"] as? CGFloat {
            dynamicColorAlpha = colorAlpha
        }
        waveOffset = prefs["waveOffset"] as? CGFloat ?? 0
        if let hexString = prefs["waveColor"] as? String, let color = colorFromPropertyList(value: hexString) {
            waveColor = color
        } else {
            waveColor = CGColor(gray: 0.5, alpha: 0.5)
        }
    }

    private func parseConfig() {
        guard let name = self.application else {
            return
        }

        if NSHomeDirectory() == "/var/mobile", let file = UserDefaults(suiteName: "com.ryannair05.mitsuhasix") {
            let prefPrefix = "MSHF" + name
            let dropCount = prefPrefix.count

            for (key, value) in file.dictionaryRepresentation() where key.hasPrefix(prefPrefix) {
                let removedKey = key.dropFirst(dropCount)
                let lowerCaseKey = removedKey.prefix(1).lowercased() + removedKey.dropFirst()

                prefs[lowerCaseKey] = value
            }
        } else {
            let MSHFPrefsFile = "/var/jb/var/mobile/Library/Preferences/com.ryannair05.mitsuhasix.plist"

            if let file = NSDictionary(contentsOfFile: MSHFPrefsFile) {
                let prefPrefix = "MSHF" + name
                let dropCount = prefPrefix.count

                for (key, value) in file {
                    guard let key = key as? String, key.hasPrefix(prefPrefix) else {
                        continue
                    }

                    let removedKey = key.dropFirst(dropCount)
                    let lowerCaseKey = removedKey.prefix(1).lowercased() + removedKey.dropFirst()

                    prefs[lowerCaseKey] = value
                }
            }
        }

        setDictionary()
    }

    @objc private func reload() {
        parseConfig()
        configureView()
    }
}
