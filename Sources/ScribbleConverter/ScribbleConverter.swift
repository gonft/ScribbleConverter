#if os(OSX)
    import AppKit
    typealias Color = NSColor
#elseif os(iOS) || os(tvOS)
    import UIKit
    typealias Color = UIColor
#endif
import PencilKit

public final class ScribbleConverter {
    var scale = 0.0
    
    public static func scribbleFrom(drawingData data: Data, imageWidth: CGFloat) -> Data? {
        do {
            if #available(iOS 14.0, *) {
                let drawing = try PKDrawing.init(data: Data(data))
                scale = imageWidth * 0.003703703703704
                let scribble = Scribble.with{ s in
                    s.width = drawing.bounds.width * scale;
                    s.height = drawing.bounds.height * scale;
                    s.strokes = getLines(drawing: drawing);
                }
                return try scribble.serializedData()
            } else {
                print("not available pencilkit")
            }
        } catch {
            print("pencilkit data convert failed")
        }
        return nil
    }
    
    public static func scribbleFrom(pkDrawing drawing: PKDrawing, imageWidth: CGFloat) -> Data? {
        do {
            if #available(iOS 14.0, *) {
                scale = imageWidth * 0.003703703703704
                let scribble = Scribble.with{ s in
                    s.width = drawing.bounds.width * scale;
                    s.height = drawing.bounds.height * scale;
                    s.strokes = getLines(drawing: drawing);
                }
                return try scribble.serializedData()
            } else {
                print("not available pencilkit")
            }
        } catch {
            print("pencilkit data convert failed")
        }
        return nil
    }
    
    @available(iOS 14.0, *)
    private static func getLines(drawing: PKDrawing) -> [Stroke] {
        
        let formatter = ISO8601DateFormatter()
        var lines = [Stroke]()
        
        for stroke in drawing.strokes {
            var points = stroke.path.map{ p0 in
                Point.with{ p1 in
                    p1.x = (p0.location.x) * scale;
                    p1.y = (p0.location.y) * scale;
                    p1.p = p0.force * 0.5;
                    p1.altitude = p0.altitude;
                    p1.azimuth = p0.azimuth;
                    p1.opacity = p0.opacity;
                    p1.size = [p0.size.width, p0.size.height];
                    p1.timestamp = p0.timeOffset;
                }
            }
            let inkType = stroke.ink.inkType.rawValue.components(separatedBy: ".").last ?? "Unkown"
            var lineWidth = 1.0
            let thinning = 0.5
            let smoothing = 0.5
            let streamline = 0.5
            switch stroke.ink.inkType {
                case .pen:
                   lineWidth *= 3
                    break;
                    
                case .marker:
                    lineWidth *= 2.5
                    points = stroke.path.map{ p0 in
                        Point.with{ p1 in
                            p1.x = (p0.location.x) * scale;
                            p1.y = (p0.location.y) * scale;
                            p1.p = 1.0;
                            p1.altitude = p0.altitude;
                            p1.azimuth = p0.azimuth;
                            p1.opacity = p0.opacity;
                            p1.size = [p0.size.width, p0.size.height];
                            p1.timestamp = p0.timeOffset;
                        }
                    }
                    break
                 
                case .pencil:
                    lineWidth *= 9
                    points = stroke.path.map{ p0 in
                        Point.with{ p1 in
                            p1.x = (p0.location.x) * scale;
                            p1.y = (p0.location.y) * scale;
                            p1.p = 1.0;
                            p1.altitude = p0.altitude;
                            p1.azimuth = p0.azimuth;
                            p1.opacity = p0.opacity;
                            p1.size = [p0.size.width, p0.size.height];
                            p1.timestamp = p0.timeOffset;
                        }
                    }
                    break
                    
                @unknown default:
                    break
            }
            
            let avgSize = points.map{($0.size[0] + $0.size[1]) * 0.5 }.reduce(0.0){($0 + $1)} / CGFloat(points.count)
            
            lines.append(
                Stroke.with{ p0 in
                    p0.points = points;
                    p0.ink = inkType;
                    p0.color = stroke.ink.color.hexa;
                    p0.createdAt = formatter.string(from: stroke.path.creationDate);
                    p0.options = StrokeOptions.with{ o in
                        o.size = avgSize * lineWidth;
                        o.thinning = thinning;
                        o.smoothing = smoothing;
                        o.streamline = streamline;
                        o.simulatePressure = false;
                    };
                }
            )
        }
        
        return lines
    }
}

// MARK: Extensions

extension Color
{
    var hexa: UInt32 {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        var value: UInt32 = 0
        value += UInt32(alpha * 255) << 24
        value += UInt32(red   * 255) << 16
        value += UInt32(green * 255) << 8
        value += UInt32(blue  * 255)
        return value
    }
}
