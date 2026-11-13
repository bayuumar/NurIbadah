import Foundation
import UIKit

// MARK: - Image Compression Helper
final class ImageCompressor {
    /// Mengompresi UIImage menjadi data JPEG yang efisien (resolusi maksimum 1280px dan kompresi 0.75)
    static func compress(image: UIImage, maxDimension: CGFloat = 1280, quality: CGFloat = 0.75) -> Data? {
        let size = image.size
        var newSize = size
        
        let widthRatio = maxDimension / size.width
        let heightRatio = maxDimension / size.height
        let scale = min(widthRatio, heightRatio)
        
        if scale < 1.0 {
            newSize = CGSize(width: size.width * scale, height: size.height * scale)
        }
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
        
        return resizedImage.jpegData(compressionQuality: quality)
    }
    
    /// Mengubah Data menjadi UIImage
    static func image(from data: Data?) -> UIImage? {
        guard let data = data else { return nil }
        return UIImage(data: data)
    }
}
