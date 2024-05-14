import UIKit

final public class MSHFSiriView: MSHFView {

    private let waveLayer = MSHFJelloLayer()
    private let rWaveLayer = MSHFJelloLayer()
    private let subwaveLayer = MSHFJelloLayer()
    private let rSubwaveLayer = MSHFJelloLayer()
    private let subSubwaveLayer = MSHFJelloLayer()
    private let rSubSubwaveLayer =  MSHFJelloLayer()

    override public func initializeWaveLayers() {
        rSubSubwaveLayer.frame = bounds
        rSubwaveLayer.frame = rSubSubwaveLayer.frame
        rWaveLayer.frame = rSubwaveLayer.frame
        subSubwaveLayer.frame = rWaveLayer.frame
        subwaveLayer.frame = subSubwaveLayer.frame
        waveLayer.frame = rWaveLayer.frame

        layer.addSublayer(waveLayer)
        layer.addSublayer(rWaveLayer)
        layer.addSublayer(subwaveLayer)
        layer.addSublayer(rSubwaveLayer)
        layer.addSublayer(subSubwaveLayer)
        layer.addSublayer(rSubSubwaveLayer)

        waveLayer.zPosition = 0
        rWaveLayer.zPosition = 0
        subwaveLayer.zPosition = -1
        rSubwaveLayer.zPosition = -1
        subSubwaveLayer.zPosition = -2
        rSubSubwaveLayer.zPosition = -2

        configureDisplayLink()
        resetWaveLayers()
    }

    private func midPointForPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        return CGPoint(x: (p1.x + p2.x) / 2, y: (p1.y + p2.y) / 2)
    }

    private func controlPointForPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
        var controlPoint = midPointForPoints(p1, p2)
        let diffY = abs(p2.y - controlPoint.y)

        if p1.y < p2.y {
            controlPoint.y += diffY
        } else if p1.y > p2.y {
            controlPoint.y -= diffY
        }

        return controlPoint
    }

    override public func resetWaveLayers() {
        guard self.points != nil else {
            return
        }

        let path = createPath()

        waveLayer.path = path
        rWaveLayer.path = path
        subwaveLayer.path = path
        rSubwaveLayer.path = path
        subSubwaveLayer.path = path
        rSubSubwaveLayer.path = path
    }

    override public func updateWave(_ waveColor: CGColor, subwaveColor: CGColor) {
        updateWave(waveColor, subwaveColor: subwaveColor, subSubwaveColor: subwaveColor)
    }

    override public func updateWave(_ waveColor: CGColor, subwaveColor: CGColor, subSubwaveColor: CGColor) {
        self.waveColor = waveColor
        self.subwaveColor = subwaveColor
        self.subSubwaveColor = subSubwaveColor
        waveLayer.fillColor = waveColor
        rWaveLayer.fillColor = waveColor
        subwaveLayer.fillColor = subwaveColor
        rSubwaveLayer.fillColor = subwaveColor
        subSubwaveLayer.fillColor = subSubwaveColor
        rSubSubwaveLayer.fillColor = subSubwaveColor

        waveLayer.compositingFilter = "screenBlendMode"
        rWaveLayer.compositingFilter = "screenBlendMode"
        subwaveLayer.compositingFilter = "screenBlendMode"
        rSubwaveLayer.compositingFilter = "screenBlendMode"
        subSubwaveLayer.compositingFilter = "screenBlendMode"
        rSubSubwaveLayer.compositingFilter = "screenBlendMode"
    }

    override public func redraw() {
        super.redraw()

        let path = createPath()
        let scale = CATransform3DMakeScale(1, -1, 1)
        let translate = CATransform3DMakeTranslation(0, self.points.pointee.y + self.waveOffset, 0)
        let transform = CATransform3DConcat(scale, translate)

        waveLayer.path = path
        rWaveLayer.path = path
        rWaveLayer.transform = transform

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: { [weak self] in
            guard let self else {
                return
            }
            self.subwaveLayer.path = path
            self.rSubwaveLayer.path = path
            self.rSubwaveLayer.transform = transform
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: { [weak self] in
            guard let self else {
                return
            }
            self.subSubwaveLayer.path = path
            self.rSubSubwaveLayer.path = path
            self.rSubSubwaveLayer.transform = transform
        })
    }

    override public func setSampleData(_ data: UnsafeMutablePointer<Float>, length: Int32) {
        super.setSampleData(data, length: length)

        points[numberOfPoints - 1].x = bounds.size.width
        points[numberOfPoints - 1].y = waveOffset
        points[0].y = points[numberOfPoints - 1].y
    }

    private func createPath() -> CGPath {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: 0, y: waveOffset))

        var p1 = self.points.pointee
        path.addLine(to: p1)

        for i in 1..<numberOfPoints {
            let p2 = self.points[i]
            let midPoint = midPointForPoints(p1, p2)

            path.addQuadCurve(to: midPoint, control: controlPointForPoints(midPoint, p1))
            path.addQuadCurve(to: p2, control: controlPointForPoints(midPoint, p2))
            p1 = p2
        }

        path.addLine(to: CGPoint(x: frame.size.width, y: waveOffset))
        return path
    }
}
