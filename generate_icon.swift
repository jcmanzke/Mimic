import Cocoa
import CoreGraphics

func createIcon(sourcePath: String, outputDarkPath: String, outputTintedPath: String, outputUniversalPath: String) {
    let size = CGSize(width: 1024, height: 1024)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
    
    guard let context = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo) else {
        print("Failed to create context")
        return
    }

    guard let petImage = NSImage(contentsOfFile: sourcePath)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
        print("Failed to load pet image from: \(sourcePath)")
        return
    }

    // 1. Draw Universal / Light Appearance Icon
    let gradientColors = [
        NSColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0).cgColor, // Warm Yellow
        NSColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0).cgColor  // Coral Pink
    ] as CFArray

    let gradient = CGGradient(colorsSpace: colorSpace, colors: gradientColors, locations: [0.0, 1.0])!
    
    context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: size.height), end: CGPoint(x: size.width, y: 0), options: [])
    
    // Draw pet image in the center, slightly scaled down so it fits nicely
    let padding: CGFloat = 160
    let petRect = CGRect(x: padding, y: padding, width: size.width - 2*padding, height: size.height - 2*padding)
    context.draw(petImage, in: petRect)

    guard let universalImage = context.makeImage() else { return }

    saveImage(universalImage, to: outputUniversalPath)


    // 2. Draw Dark Appearance Icon (Darker Purple/Blue gradient)
    context.clear(CGRect(origin: .zero, size: size))
    let darkGradientColors = [
        NSColor(red: 0.2, green: 0.1, blue: 0.4, alpha: 1.0).cgColor, // Dark Purple
        NSColor(red: 0.0, green: 0.0, blue: 0.2, alpha: 1.0).cgColor  // Dark Blue
    ] as CFArray
    let darkGradient = CGGradient(colorsSpace: colorSpace, colors: darkGradientColors, locations: [0.0, 1.0])!
    context.drawLinearGradient(darkGradient, start: CGPoint(x: 0, y: size.height), end: CGPoint(x: size.width, y: 0), options: [])
    context.draw(petImage, in: petRect)

    guard let darkImage = context.makeImage() else { return }
    saveImage(darkImage, to: outputDarkPath)


    // 3. Draw Tinted Appearance Icon (Grayscale/Alpha mask or just grayscale gradient)
    // For iOS 18 tinted icons, typically the system expects a white mask with transparency or grayscale.
    // iOS docs: "Dark and tinted app icons must have single layers. Tinted app icons must be greyscale images."
    // We will draw it as grayscale.
    let grayColorSpace = CGColorSpaceCreateDeviceGray()
    guard let grayContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: grayColorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue) else { return }
    
    grayContext.setFillColor(NSColor.black.cgColor)
    grayContext.fill(CGRect(origin: .zero, size: size))

    // Draw the pet inverted to white
    // Tinted icons are typically white shapes on black/transparent background, so the system colors the white part with the tint color.
    // We will create a stencil of the pet image.
    grayContext.clip(to: petRect, mask: petImage)
    grayContext.setFillColor(NSColor.white.cgColor)
    grayContext.fill(petRect)

    guard let tintedImage = grayContext.makeImage() else { return }

    let destBitmapInfo = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.noneSkipLast.rawValue // Convert Gray to RGB without alpha since typical iOS icon expects no alpha
    guard let tintedContext = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: destBitmapInfo) else { return }
    tintedContext.draw(tintedImage, in: CGRect(origin: .zero, size: size))
    guard let finalTintedImage = tintedContext.makeImage() else { return }

    saveImage(finalTintedImage, to: outputTintedPath)
}

func saveImage(_ cgImage: CGImage, to path: String) {
    let rep = NSBitmapImageRep(cgImage: cgImage)
    if let data = rep.representation(using: .png, properties: [:]) {
        do {
            try data.write(to: URL(fileURLWithPath: path))
            print("Successfully saved to \(path)")
        } catch {
            print("Failed to save to \(path): \(error)")
        }
    }
}

// Ensure the caller provides the repo root as the first argument
let args = CommandLine.arguments
let currentDir = args.count > 1 ? args[1] : "./"

let petPath = currentDir + "/Mimic/Assets.xcassets/1_pet_happy.imageset/1_pet_happy.png"

let outUniversal = currentDir + "/Mimic/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
let outDark = currentDir + "/Mimic/Assets.xcassets/AppIcon.appiconset/AppIconDark.png"
let outTinted = currentDir + "/Mimic/Assets.xcassets/AppIcon.appiconset/AppIconTinted.png"

createIcon(sourcePath: petPath, outputDarkPath: outDark, outputTintedPath: outTinted, outputUniversalPath: outUniversal)
