
import Foundation
import UIKit

enum FontBook: String {
    case AvenirMedium = "Avenir-Medium"
    case AvenirHeavy = "Avenir-Heavy"
    case AvenirBlack = "Avenir-Black"
    case BariolBold = "Bariol-Bold"
    
    func of(size: CGFloat) -> UIFont {
        return UIFont(name: self.rawValue, size: size)!
    }
}
 
enum Palette {
    case maroon, lightGrey, faintGrey, mustard, darkGrey, brightYellow, darkYellow, red
    
    var color: UIColor {
        switch self {
        case .maroon: return UIColor(hex: 0xBD7C7C)
        case .lightGrey: return UIColor(hex: 0xD2D2D2)
        case .faintGrey: return UIColor(hex: 0xF3F3F3)
        case .mustard: return UIColor(hex: 0xD4B06D)
        case .darkGrey: return UIColor(hex: 0x343434)
        case .brightYellow: return UIColor(hex: 0xFCDF1D)
        case .darkYellow: return UIColor(hex: 0x94712D)
        case .red: return UIColor(hex: 0xE15A67)
        }
    }
}

extension UIColor {
    
    convenience init(hex: Int) {
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    }
    
    class func forGradient(_ red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1.0)
    }
    
}
