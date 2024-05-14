import UIKit

final public class MSHFLineView: MSHFView {

    internal var lineThickness: CGFloat = 5.0 {
        didSet(thickness) {
            waveLayer.lineWidth = thickness
            subwaveLayer?.lineWidth = thickness
            subSubwaveLayer?.lineWidth = thickness
        }
    }
    private var waveLayer =  MSHFJelloLayer()
    private var subwaveLayer: MSHFJelloLayer?
    private var subSubwaveLayer: MSHFJelloLayer?

    convenience init(frame: CGRect, lineThickness: CGFloat) {
        self.init(frame: frame)
        self.lineThickness = lineThickness
    }

    override public func initializeWaveLayers() {
        let clearColor = CGColor(red: 0, green: 0, blue: 0, alpha: 0)

        layer.sublayers = nil

        waveLayer.frame = bounds

        layer.addSublayer(waveLayer)

        waveLayer.zPosition = 0
        waveLayer.lineWidth = 5
        waveLayer.fillColor = clearColor

        if siriEnabled {
            subwaveLayer = MSHFJelloLayer()
            subSubwaveLayer = MSHFJelloLayer()

            subSubwaveLayer!.frame = waveLayer.frame
            subwaveLayer!.frame = subSubwaveLayer!.frame

            layer.addSublayer(subwaveLayer!)
            layer.addSublayer(subSubwaveLayer!)

            subwaveLayer!.zPosition = -1
            subSubwaveLayer!.zPosition = -2
            subwaveLayer!.lineWidth = 5
            subSubwaveLayer!.lineWidth = 5
            subwaveLayer!.fillColor = clearColor
            subSubwaveLayer!.fillColor = clearColor
        }

        configureDisplayLink()
        resetWaveLayers()
    }

    override public func resetWaveLayers() {
        guard self.points != nil else {
            return
        }

        let path = createPath()

        waveLayer.path = path
        if siriEnabled {
            subwaveLayer!.path = path
            subSubwaveLayer!.path = path
        }
    }

    @objc override public func updateWave(_ waveColor: CGColor, subwaveColor: CGColor) {
        self.waveColor = waveColor
        self.waveLayer.strokeColor = waveColor
    }

    @objc override public func updateWave(_ waveColor: CGColor, subwaveColor: CGColor, subSubwaveColor: CGColor) {
        if subwaveLayer == nil || subSubwaveLayer == nil {
            initializeWaveLayers()
        }
        self.waveColor = waveColor
        self.subwaveColor = subwaveColor
        self.subSubwaveColor = subSubwaveColor
        waveLayer.strokeColor = waveColor
        subwaveLayer!.strokeColor = subwaveColor
        subSubwaveLayer!.strokeColor = subSubwaveColor
        waveLayer.compositingFilter = "screenBlendMode"
        subwaveLayer!.compositingFilter = "screenBlendMode"
        subSubwaveLayer!.compositingFilter = "screenBlendMode"
    }

    override public func redraw() {
        super.redraw()

        let path = createPath()
        waveLayer.path = path

        if siriEnabled {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.subwaveLayer?.path = path
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                self?.subSubwaveLayer?.path = path
            }
        }
    }

    override public func setSampleData(_ data: UnsafeMutablePointer<Float>, length: Int32) {
        super.setSampleData(data, length: length)

        points[numberOfPoints - 1] = CGPoint(x: bounds.size.width, y: waveOffset)
    }

    private func createPath() -> CGPath {
        let path = CGMutablePath()

        path.move(to: CGPoint(x: 0, y: waveOffset))

        for i in 1..<numberOfPoints {
            path.addLine(to: self.points[i])
        }

        return path
    }
}
