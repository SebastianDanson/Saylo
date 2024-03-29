//
//  Extensions.swift
//  VideoMessengerApp
//
//  Created by Student on 2021-09-24.
//
import UIKit
import SwiftUI
import Combine
import AVFoundation

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension Color {
    
    static let mainBlue = Color(UIColor.mainBlue)
    static let lightGray = Color(UIColor.lightGray)
    static let lighterGray = Color(UIColor.lighterGray)
    static let iconGray = Color(UIColor.iconGray)
    static let mainGray = Color(UIColor.mainGray)
    static let topGray = Color(UIColor.topGray)
    static let bottomGray = Color(UIColor.bottomGray)
    static let lightestGray = Color(UIColor.lightestGray)
    static let toolBarIconGray = Color(UIColor.toolBarIconGray)
    static let toolBarIconDarkGray = Color(UIColor.toolBarIconDarkGray)
    static let videoPlayerGray = Color(UIColor.videoPlayerGray)
    static let backgroundGray = Color(UIColor.backgroundGray)
    static let mainBackgroundBlue = Color(UIColor.mainBackgroundBlue)
    static let lightBlue = Color(UIColor.lightBlue)
    static let chevronGray = Color(UIColor.chevronGray)
    static let dividerGray = Color(UIColor.dividerGray)
    static let textGray = Color(UIColor.textGray)
    static let borderGray = Color(UIColor.borderGray)
    static let systemWhite = Color(UIColor.systemWhite)
    static let systemBlack = Color(UIColor.systemBlack)
    static let point7AlphaSystemWhite = Color(UIColor.point7AlphaSystemWhite)
    static let point3AlphaSystemBlack = Color(UIColor.point3AlphaSystemBlack)
    static let popUpSystemWhite = Color(UIColor.popUpSystemWhite)
    static let iconSystemWhite = Color(UIColor.iconSystemWhite)
    static let textBackground = Color(UIColor.textBackground)
    static let systemCyan = Color(UIColor.systemCyan)
    static let systemMint = Color(UIColor.systemMint)
    static let darkgray = Color(red: 49/255, green: 49/255, blue: 49/255)
    static let alternateMainBlue = Color(UIColor.alternateMainBlue)
    static let fadedBlack = Color(UIColor.fadedBlack)
    static let darkBackground = Color(red: 80/255, green: 79/255, blue: 75/255)
    static let lineGray = Color(UIColor.lineGray)
    static let backgroundWhite = Color(UIColor.backgroundWhite)
    static let createGroupBlue = Color(UIColor.createGroupBlue)
    static let createGroupText = Color(UIColor.createGroupText)
}

extension UIImage {
    /// Average color of the image, nil if it cannot be found
    var averageColor: UIColor? {
        // convert our image to a Core Image Image
        guard let inputImage = CIImage(image: self) else { return nil }
        
        // Create an extent vector (a frame with width and height of our current input image)
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)
        
        // create a CIAreaAverage filter, this will allow us to pull the average color from the image later on
        guard let filter = CIFilter(name: "CIAreaAverage",
                                    parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        // A bitmap consisting of (r, g, b, a) value
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])
        
        // Render our output image into a 1 by 1 image supplying it our bitmap to update the values of (i.e the rgba of the 1 by 1 image will fill out bitmap array
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)
        
        // Convert our bitmap images of r, g, b, a to a UIColor
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}

extension UIColor {
    
    static let fadedBlack = UIColor(white: 0, alpha: 0.3)
    static let alternateMainBlue = UIColor(red: 76/255, green: 165/255, blue: 239/255, alpha: 1)

    static let systemWhite = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .black : .white
    }
    
    static let systemBlack = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .white : .black
    }
    
    static let backgroundWhite = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor(red: 32/255, green: 32/255, blue: 34/255, alpha: 1) : .white
    }
    
    static let mainBlue = UIColor(red: 15/255, green: 168/255, blue: 246/255, alpha: 1)
    
    static let sliderGray = UIColor(red: 87/255, green: 88/255, blue: 92/255, alpha: 1)

    
    static let lightGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray2 : UIColor(red: 0.67, green: 0.67, blue: 0.67, alpha: 1)
    }
    
    static let lighterGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray5 : UIColor(red: 228/255, green: 228/255, blue: 228/255, alpha: 1)
    }
    
    static let iconGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray : UIColor(red: 153/255, green: 153/255, blue: 153/255, alpha: 1)
    }
    
    static let mainGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray : UIColor(red: 83/255, green: 92/255, blue: 104/255, alpha: 1)
    }
    
    static let topGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray2 : UIColor(red: 165/255, green: 170/255, blue: 183/255, alpha: 1)
    }
    
    static let bottomGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray : UIColor(red: 135/255, green: 140/255, blue: 150/255, alpha: 1)
    }
    
    static let lightestGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray6 : UIColor(red: 248/255, green: 248/255, blue: 248/255, alpha: 1)
    }
    
    static let toolBarIconGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray6 : UIColor(red: 241/255, green: 242/255, blue: 244/255, alpha: 1)
    }
    
    static let toolBarIconDarkGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor(red: 222/255, green: 222/255, blue: 222/255, alpha: 1) : UIColor(red: 80/255, green: 89/255, blue: 100/255, alpha: 1)
    }
    
    static let videoPlayerGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray : UIColor(red: 115/255, green: 115/255, blue: 115/255, alpha: 1)
    }
    
    static let backgroundGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .black : UIColor(red: 246/255, green: 246/255, blue: 247/255, alpha: 1)
    }
    
    static let lightBlue = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .black : UIColor(red: 99/255, green: 163/255, blue: 233/255, alpha: 1)
    }
    
    static let mainBackgroundBlue = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .black : UIColor(red: 80/255, green: 140/255, blue: 200/255, alpha: 1)
    }
    
    static let chevronGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray3 : UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
    }
    
    static let dividerGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray5 : UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 1)
    }
    
    static let borderGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray5 : UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }
    
    static let textGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemGray : UIColor(red: 83/255, green: 92/255, blue: 104/255, alpha: 1)
    }
    
    static let point7AlphaSystemWhite = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor(white: 0, alpha: 0.7) : UIColor(white: 1, alpha: 0.7)
    }
    
    static let point3AlphaSystemBlack = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 0.3) : UIColor(white: 0, alpha: 0.3)
    }
    
    static let popUpSystemWhite = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1) : .white
    }
    
    static let iconSystemWhite = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1) : .white
    }
    
    static let systemMint = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor(red: 102/255, green: 212/255, blue: 207/255, alpha: 1) :
        UIColor(red: 0/255, green: 199/255, blue: 190/255, alpha: 1)
    }
    
    static let systemCyan = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor(red: 100/255, green: 210/255, blue: 255/255, alpha: 1) :
        UIColor(red: 50/255, green: 173/255, blue: 230/255, alpha: 1)
    }
    
    static let lineGray = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? UIColor.systemGray5 :
        UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1)
    }
    
    static let textBackground = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ?
        UIColor(red: 28/255, green: 28/255, blue: 30/255, alpha: 1) :
        UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    }
    
    static let createGroupBlue = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .systemBlue : .mainBlue
    }
    
    static let createGroupText = UIColor { (trait: UITraitCollection) -> UIColor in
        return trait.userInterfaceStyle == .dark ? .white : .mainBlue
    }
    
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return (red, green, blue, alpha)
    }
}

extension UIView {
    
    func listSubViews() -> [UIView] {
        return subviews + subviews.flatMap { $0.listSubViews() }
    }
    
    func anchor(top: NSLayoutYAxisAnchor? = nil,
                left: NSLayoutXAxisAnchor? = nil,
                bottom: NSLayoutYAxisAnchor? = nil,
                right: NSLayoutXAxisAnchor? = nil,
                paddingTop: CGFloat = 0,
                paddingLeft: CGFloat = 0,
                paddingBottom: CGFloat = 0,
                paddingRight: CGFloat = 0,
                width: CGFloat? = nil,
                height: CGFloat? = nil) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left {
            leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -paddingBottom).isActive = true
        }
        
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -paddingRight).isActive = true
        }
        
        if let width = width {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if let height = height {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    func centerX(inView view: UIView, constant: CGFloat = 0) {
        translatesAutoresizingMaskIntoConstraints = false
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: constant).isActive = true
    }
    
    func centerY(inView view: UIView, leftAnchor: NSLayoutXAxisAnchor? = nil,
                 paddingLeft: CGFloat = 0, constant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: constant).isActive = true
        
        if let left = leftAnchor {
            anchor(left: left, paddingLeft: paddingLeft)
        }
    }
    
    func setDimensions(height: CGFloat, width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    func setHeight(height: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }
    
    func setWidth(width: CGFloat) {
        translatesAutoresizingMaskIntoConstraints = false
        widthAnchor.constraint(equalToConstant: width).isActive = true
    }
}

extension TimeInterval {
    var minuteSecond: String {
        String(format:"%d:%02d", minute, second)
    }
    var hour: Int {
        self.isNaN ? 0 : Int((self/3600).truncatingRemainder(dividingBy: 3600))
    }
    var minute: Int {
        self.isNaN ? 0 : Int((self/60).truncatingRemainder(dividingBy: 60))
    }
    var second: Int {
        self.isNaN ? 0 : Int(truncatingRemainder(dividingBy: 60))
    }
}

extension Date {
    func getFormattedDate() -> String {
        let dateformat = DateFormatter()
        if ConversationViewModel.shared.showSavedPosts {
            dateformat.dateFormat = "MMM dd, yyyy"
        } else {
            dateformat.dateFormat = "h:mm a"
        }
        return dateformat.string(from: self)
    }
}


extension String {
    
    mutating func removeTrailingSpaces() {
        for _ in 0..<self.count {
            
            if let last = self.last, last == " " {
                self.removeLast()
            } else {
                break
            }
        }
    }
    
    public func levenshtein(_ other: String) -> Int {
        let sCount = self.count
        let oCount = other.count
        
        guard sCount != 0 else {
            return oCount
        }
        
        guard oCount != 0 else {
            return sCount
        }
        
        let line : [Int]  = Array(repeating: 0, count: oCount + 1)
        var mat : [[Int]] = Array(repeating: line, count: sCount + 1)
        
        for i in 0...sCount {
            mat[i][0] = i
        }
        
        for j in 0...oCount {
            mat[0][j] = j
        }
        
        for j in 1...oCount {
            for i in 1...sCount {
                if self.characterAtIndex(index: i-1) == other.characterAtIndex(index: j-1) {
                    mat[i][j] = mat[i - 1][j - 1]       // no operation
                }
                else {
                    let del = mat[i - 1][j] + 1         // deletion
                    let ins = mat[i][j - 1] + 1         // insertion
                    let sub = mat[i - 1][j - 1] + 1     // substitution
                    mat[i][j] = min(min(del, ins), sub)
                }
            }
        }
        
        return mat[sCount][oCount]
    }
    
    func characterAtIndex(index: Int) -> Character? {
        var cur = 0
        for char in self {
            if cur == index {
                return char
            }
            cur += 1
        }
        return nil
    }
    
    
    func isValidPhoneNumber() -> Bool {
        let regEx = "^\\+(?:[0-9]?){6,14}[0-9]$"
        let phoneCheck = NSPredicate(format: "SELF MATCHES[c] %@", regEx)
        return phoneCheck.evaluate(with: self)
    }
    
    
    
    func toEnglishNumber() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: "EN")
        guard let result = numberFormatter.number(from: self) else {
            
            return self
        }
        return result.stringValue
    }
}

extension Publishers {
    // 1.
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        // 2.
        let willShow = NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)
            .map { $0.keyboardHeight }
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        // 3.
        return MergeMany(willShow, willHide)
            .eraseToAnyPublisher()
        
    }
}

extension Notification {
    var keyboardHeight: CGFloat {
        return (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}

extension UINavigationController: UIGestureRecognizerDelegate {
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}


extension UserDefaults {
    
    func save<T:Encodable>(customObject object: T, inKey key: String) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(object) {
            self.set(encoded, forKey: key)
        }
    }
    
    func retrieve<T:Decodable>(object type:T.Type, fromKey key: String) -> T? {
        if let data = self.data(forKey: key) {
            let decoder = JSONDecoder()
            if let object = try? decoder.decode(type, from: data) {
                return object
            }else {
                print("Couldnt decode object")
                return nil
            }
        }else {
            print("Couldnt find key")
            return nil
        }
    }
    
}


extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}


extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont
        
        if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            font = UIFont(descriptor: descriptor, size: size)
        } else {
            font = systemFont
        }
        return font
    }
}


extension AVCaptureVideoOrientation {
    
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
    
    func angleOffsetFromPortraitOrientation(at position: AVCaptureDevice.Position) -> Double {
        switch self {
        case .portrait:
            return position == .front ? .pi : 0
        case .portraitUpsideDown:
            return position == .front ? 0 : .pi
        case .landscapeRight:
            return -.pi / 2.0
        case .landscapeLeft:
            return .pi / 2.0
        default:
            return 0
        }
    }
}

extension AVCaptureConnection {
    func videoOrientationTransform(relativeTo destinationVideoOrientation: AVCaptureVideoOrientation) -> CGAffineTransform {
        let videoDevice: AVCaptureDevice
        if let deviceInput = inputPorts.first?.input as? AVCaptureDeviceInput, deviceInput.device.hasMediaType(.video) {
            videoDevice = deviceInput.device
        } else {
            // Fatal error? Programmer error?
            print("Video data output's video connection does not have a video device")
            return .identity
        }
        
        let fromAngleOffset = videoOrientation.angleOffsetFromPortraitOrientation(at: videoDevice.position)
        let toAngleOffset = destinationVideoOrientation.angleOffsetFromPortraitOrientation(at: videoDevice.position)
        let angleOffset = CGFloat(toAngleOffset - fromAngleOffset)
        let transform = CGAffineTransform(rotationAngle: angleOffset)
        
        return transform
    }
}

extension AVCaptureSession.InterruptionReason: CustomStringConvertible {
    public var description: String {
        var descriptionString = ""
        
        switch self {
        case .videoDeviceNotAvailableInBackground:
            descriptionString = "video device is not available in the background"
        case .audioDeviceInUseByAnotherClient:
            descriptionString = "audio device is in use by another client"
        case .videoDeviceInUseByAnotherClient:
            descriptionString = "video device is in use by another client"
        case .videoDeviceNotAvailableWithMultipleForegroundApps:
            descriptionString = "video device is not available with multiple foreground apps"
        case .videoDeviceNotAvailableDueToSystemPressure:
            descriptionString = "video device is not available due to system pressure"
        @unknown default:
            descriptionString = "unknown (\(self.rawValue)"
        }
        
        return descriptionString
    }
}

func allocateOutputBufferPool(with inputFormatDescription: CMFormatDescription, outputRetainedBufferCountHint: Int) -> (
    outputBufferPool: CVPixelBufferPool?,
    outputColorSpace: CGColorSpace?,
    outputFormatDescription: CMFormatDescription?) {
        
        let inputMediaSubType = CMFormatDescriptionGetMediaSubType(inputFormatDescription)
        if inputMediaSubType != kCVPixelFormatType_Lossy_32BGRA && inputMediaSubType != kCVPixelFormatType_Lossless_32BGRA &&
            inputMediaSubType != kCVPixelFormatType_32BGRA {
            assertionFailure("Invalid input pixel buffer type \(inputMediaSubType)")
            return (nil, nil, nil)
        }
        
        let inputDimensions = CMVideoFormatDescriptionGetDimensions(inputFormatDescription)
        var pixelBufferAttributes: [String: Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: UInt(inputMediaSubType),
            kCVPixelBufferWidthKey as String: Int(inputDimensions.width),
            kCVPixelBufferHeightKey as String: Int(inputDimensions.height),
            kCVPixelBufferIOSurfacePropertiesKey as String: [:]
        ]
        
        // Get pixel buffer attributes and color space from the input format description
        var cgColorSpace: CGColorSpace? = CGColorSpaceCreateDeviceRGB()
        if let inputFormatDescriptionExtension = CMFormatDescriptionGetExtensions(inputFormatDescription) as Dictionary? {
            let colorPrimaries = inputFormatDescriptionExtension[kCVImageBufferColorPrimariesKey]
            
            if let colorPrimaries = colorPrimaries {
                var colorSpaceProperties: [String: AnyObject] = [kCVImageBufferColorPrimariesKey as String: colorPrimaries]
                
                if let yCbCrMatrix = inputFormatDescriptionExtension[kCVImageBufferYCbCrMatrixKey] {
                    colorSpaceProperties[kCVImageBufferYCbCrMatrixKey as String] = yCbCrMatrix
                }
                
                if let transferFunction = inputFormatDescriptionExtension[kCVImageBufferTransferFunctionKey] {
                    colorSpaceProperties[kCVImageBufferTransferFunctionKey as String] = transferFunction
                }
                
                pixelBufferAttributes[kCVBufferPropagatedAttachmentsKey as String] = colorSpaceProperties
            }
            
            if let cvColorspace = inputFormatDescriptionExtension[kCVImageBufferCGColorSpaceKey],
                CFGetTypeID(cvColorspace) == CGColorSpace.typeID {
                cgColorSpace = (cvColorspace as! CGColorSpace)
            } else if (colorPrimaries as? String) == (kCVImageBufferColorPrimaries_P3_D65 as String) {
                cgColorSpace = CGColorSpace(name: CGColorSpace.displayP3)
            }
        }
        
        // Create a pixel buffer pool with the same pixel attributes as the input format description.
        let poolAttributes = [kCVPixelBufferPoolMinimumBufferCountKey as String: outputRetainedBufferCountHint]
        var cvPixelBufferPool: CVPixelBufferPool?
        CVPixelBufferPoolCreate(kCFAllocatorDefault, poolAttributes as NSDictionary?, pixelBufferAttributes as NSDictionary?, &cvPixelBufferPool)
        guard let pixelBufferPool = cvPixelBufferPool else {
            assertionFailure("Allocation failure: Could not allocate pixel buffer pool.")
            return (nil, nil, nil)
        }
        
        preallocateBuffers(pool: pixelBufferPool, allocationThreshold: outputRetainedBufferCountHint)
        
        // Get the output format description
        var pixelBuffer: CVPixelBuffer?
        var outputFormatDescription: CMFormatDescription?
        let auxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: outputRetainedBufferCountHint] as NSDictionary
        CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, pixelBufferPool, auxAttributes, &pixelBuffer)
        if let pixelBuffer = pixelBuffer {
            CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault,
                                                         imageBuffer: pixelBuffer,
                                                         formatDescriptionOut: &outputFormatDescription)
        }
        pixelBuffer = nil
        
        return (pixelBufferPool, cgColorSpace, outputFormatDescription)
}

private func preallocateBuffers(pool: CVPixelBufferPool, allocationThreshold: Int) {
    var pixelBuffers = [CVPixelBuffer]()
    var error: CVReturn = kCVReturnSuccess
    let auxAttributes = [kCVPixelBufferPoolAllocationThresholdKey as String: allocationThreshold] as NSDictionary
    var pixelBuffer: CVPixelBuffer?
    while error == kCVReturnSuccess {
        error = CVPixelBufferPoolCreatePixelBufferWithAuxAttributes(kCFAllocatorDefault, pool, auxAttributes, &pixelBuffer)
        if let pixelBuffer = pixelBuffer {
            pixelBuffers.append(pixelBuffer)
        }
        pixelBuffer = nil
    }
    pixelBuffers.removeAll()
}
