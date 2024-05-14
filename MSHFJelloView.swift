import UIKit

final public class MSHFJelloView: MSHFView {

  private let waveLayer = MSHFJelloLayer()
  private let subwaveLayer = MSHFJelloLayer()
  private var subSubwaveLayer: MSHFJelloLayer?

  override public func initializeWaveLayers() {
    layer.sublayers = nil

    subwaveLayer.frame = bounds
    waveLayer.frame = subwaveLayer.frame

    layer.addSublayer(waveLayer)
    layer.addSublayer(subwaveLayer)

    waveLayer.zPosition = 0
    subwaveLayer.zPosition = -1

    if siriEnabled {
      subSubwaveLayer = MSHFJelloLayer()

      subSubwaveLayer!.frame = bounds

      layer.addSublayer(subSubwaveLayer!)

      subSubwaveLayer!.zPosition = -2
    }

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
      subwaveLayer.path = path
      if siriEnabled {
          subSubwaveLayer!.path = path
      }
  }

  @objc override public func updateWave(_ waveColor: CGColor, subwaveColor: CGColor) {
      self.waveColor = waveColor
      self.subwaveColor = subwaveColor
      waveLayer.fillColor = waveColor
      subwaveLayer.fillColor = subwaveColor
  }

  @objc override public func updateWave(_ waveColor: CGColor, subwaveColor: CGColor, subSubwaveColor: CGColor) {
      if subSubwaveLayer == nil {
          initializeWaveLayers()
      }

      self.waveColor = waveColor
      self.subwaveColor = subwaveColor
      self.subSubwaveColor = subSubwaveColor
      waveLayer.fillColor = waveColor
      subwaveLayer.fillColor = subwaveColor
      subSubwaveLayer!.fillColor = subSubwaveColor
      waveLayer.compositingFilter = "screenBlendMode"
      subwaveLayer.compositingFilter = "screenBlendMode"
      subSubwaveLayer!.compositingFilter = "screenBlendMode"
  }

  override public func redraw() {
    super.redraw()

    let path = createPath()
    waveLayer.path = path

    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
      self?.subwaveLayer.path = path
    }

    if siriEnabled {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) { [weak self] in
          self?.subSubwaveLayer?.path = path
        }
    }
  }

  override public func setSampleData(_ data: UnsafeMutablePointer<Float>, length: Int32) {
    super.setSampleData(data, length: length)

    points[0].y = waveOffset
    points[numberOfPoints - 1] = CGPoint(x: bounds.size.width, y: waveOffset)
  }

  private func createPath() -> CGPath {
      let path = CGMutablePath()
      let height = frame.size.height
      path.move(to: CGPoint(x: 0, y: height))

      var p1 = self.points.pointee
      path.addLine(to: p1)

      for i in 1..<numberOfPoints {
          let p2 = self.points[i]
          let midPoint = midPointForPoints(p1, p2)

          path.addQuadCurve(to: midPoint, control: controlPointForPoints(midPoint, p1))
          path.addQuadCurve(to: p2, control: controlPointForPoints(midPoint, p2))

          p1 = p2
      }

      path.addLine(to: CGPoint(x: frame.size.width, y: height))
      return path
  }
}
