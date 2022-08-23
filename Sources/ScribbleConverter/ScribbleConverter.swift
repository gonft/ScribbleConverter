#if os(OSX)
    import AppKit
    typealias Color = NSColor
#elseif os(iOS) || os(tvOS)
    import UIKit
    typealias Color = UIColor
#endif
import PencilKit

public class ScribbleConverter {
    private static var scale = 0.0
    private static let kRatio = 0.003703703703704
    
    /// 두 Scribble 필기 데이터를 머지 합니다
    /// - Parameters:
    ///   - src: 원본 Scribble 필기 데이터
    ///   - srcWidth: src 데이터 생성에 사용된 배경 이미지 가로 너비 (잘못된 너비를 사용한경우이며 기존 변환처리된 데이터를 복구하기 위해 사용 됩니다)
    ///   - corectSize: 정확한 배경 이미지 사이즈
    /// - Returns: 머지된 Scribble 필기 데이터
    public static func fixScribble(src: Data, srcWidth: CGFloat, corectSize: CGSize) -> Data? {
        do {
            if #available(iOS 14.0, *) {
                let a = try Scribble.init(serializedData: src)
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let updatedAt = df.date(from: "2022/08/17T00:00:00")!
                let scribble = Scribble.with { s in
                    s.width = corectSize.width
                    s.height = corectSize.height
                    s.strokes = getLines(
                        strokes: a.strokes.filter{
                            let createdAt = df.date(from: String($0.createdAt.prefix(19)));
                            let result = createdAt != nil && createdAt! < updatedAt
                            if result {
                                print("before \($0.createdAt) \(String(describing: createdAt)), \(result)")
                            }
                            return result
                        },
                        scale: corectSize.width / srcWidth
                    ) + getLines(
                        strokes: a.strokes.filter{
                            let createdAt = df.date(from: String($0.createdAt.prefix(19)));
                            let result = createdAt == nil || createdAt! > updatedAt
                            if result {
                                print("after \($0.createdAt) \(String(describing: createdAt)), \(result)")
                            }
                            return result
                        },
                        scale: 1.0
                    )
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
    
    /// 필기데이터 컨버팅
    /// - Parameters:
    ///   - data: 애플 펜슬킷 데이터
    ///   - imageWidth: 원본 이미지 가로 너비
    ///   - offsetY: 변경할 필기 Y축 오프셋
    /// - Returns: 변경된 필기데이터
    public static func scribbleFrom(drawingData data: Data, imageWidth: CGFloat, offsetY: CGFloat = 0.0) -> Data? {
        do {
            if #available(iOS 14.0, *) {
                let drawing = try PKDrawing.init(data: Data(data))
                scale = imageWidth * kRatio
                let scribble = Scribble.with{ s in
                    s.width = drawing.bounds.width * scale;
                    s.height = drawing.bounds.height * scale;
                    s.strokes = getLines(drawing: drawing, offsetY: offsetY);
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
    
    public static func scribbleFrom(pkDrawing drawing: PKDrawing, imageWidth: CGFloat, offsetY: CGFloat = 0.0) -> Data? {
        do {
            if #available(iOS 14.0, *) {
                scale = imageWidth * kRatio
                let scribble = Scribble.with{ s in
                    s.width = drawing.bounds.width * scale;
                    s.height = drawing.bounds.height * scale;
                    s.strokes = getLines(drawing: drawing, offsetY: offsetY);
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

    private static func getLines(strokes: [Stroke], scale: CGFloat) -> [Stroke] {
        var lines = [Stroke]()
        
        for stroke in strokes {
            let points = stroke.points.map{ p0 in
                Point.with{ p1 in
                    p1.x = p0.x * scale;
                    p1.y = p0.y * scale;
                    p1.p = p0.p;
                    p1.altitude = p0.altitude;
                    p1.azimuth = p0.azimuth;
                    p1.opacity = p0.opacity;
                    p1.size = p0.size;
                    p1.timestamp = p0.timestamp;
                }
            }
            
            lines.append(
                Stroke.with{ p0 in
                    p0.points = points;
                    p0.ink = stroke.ink;
                    p0.color = stroke.color;
                    p0.createdAt = stroke.createdAt;
                    p0.options = stroke.options;
                }
            )
            
        }
        
        return lines
    }
    
    @available(iOS 14.0, *)
    private static func getLines(drawing: PKDrawing, offsetY: CGFloat = 0.0) -> [Stroke] {
        
        let formatter = ISO8601DateFormatter()
        var lines = [Stroke]()
        
        for stroke in drawing.strokes {
            var points = stroke.path.map{ p0 in
                Point.with{ p1 in
                    p1.x = (p0.location.x) * scale;
                    p1.y = (p0.location.y + offsetY) * scale;
                    p1.p = p0.force * 0.5;
                    p1.altitude = p0.altitude;
                    p1.azimuth = p0.azimuth;
                    p1.opacity = p0.opacity;
                    p1.size = [p0.size.width, p0.size.height];
                    p1.timestamp = Int64(p0.timeOffset);
                }
            }
            let inkType = stroke.ink.inkType.rawValue.components(separatedBy: ".").last ?? "Unkown"
            var lineWidth = 1.0
            if( (scale / kRatio) < 300 ) {
                lineWidth = 1.0 * ((scale / kRatio) / 1000)
            }
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
                            p1.y = (p0.location.y + offsetY) * scale;
                            p1.p = 1.0;
                            p1.altitude = p0.altitude;
                            p1.azimuth = p0.azimuth;
                            p1.opacity = p0.opacity;
                            p1.size = [p0.size.width, p0.size.height];
                            p1.timestamp = Int64(p0.timeOffset);
                        }
                    }
                    break
                 
                case .pencil:
                    lineWidth *= 9
                    points = stroke.path.map{ p0 in
                        Point.with{ p1 in
                            p1.x = (p0.location.x) * scale;
                            p1.y = (p0.location.y + offsetY) * scale;
                            p1.p = 1.0;
                            p1.altitude = p0.altitude;
                            p1.azimuth = p0.azimuth;
                            p1.opacity = p0.opacity;
                            p1.size = [p0.size.width, p0.size.height];
                            p1.timestamp = Int64(p0.timeOffset);
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
