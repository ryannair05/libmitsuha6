import QuartzCore

final internal class MSHFJelloLayer: CAShapeLayer {
    override func action(forKey event: String) -> CAAction? {
        guard event == "path" else {
            return super.action(forKey: event)
        }

        let animation = CABasicAnimation(keyPath: event)
        animation.duration = 0.15
        return animation
    }
}
