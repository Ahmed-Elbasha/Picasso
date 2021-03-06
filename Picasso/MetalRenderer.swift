//
//  MetalRenderer.swift
//  Canvas
//
//  Created by Limon on 9/1/16.
//  Copyright © 2016 Picasso. All rights reserved.
//

#if !(arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
import MetalKit

@available(iOS 9.0, *)
class MetalRenderer: NSObject, Renderable {

    let view: UIView

    let context: CIContext

    fileprivate let commandQueue: MTLCommandQueue

    fileprivate var image: CIImage?

    fileprivate let colorSpace: CGColorSpace

    init?(device: MTLDevice) {

        self.colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? CGColorSpaceCreateDeviceRGB()

        let options = [kCIContextWorkingColorSpace: colorSpace]

        self.context = CIContext(mtlDevice: device, options: options)

        self.commandQueue = device.makeCommandQueue()

        let metalView = MTKView(frame: CGRect.zero, device: device)
        metalView.device = device
        metalView.clearColor = MTLClearColorMake(0, 0, 0, 0)
        metalView.backgroundColor = UIColor.clear
        metalView.enableSetNeedsDisplay = true

        // Allow to access to `currentDrawable.texture` write mode.
        metalView.framebufferOnly = false

        self.view = metalView

        super.init()

        metalView.delegate = self
    }

    func renderImage(_ image: CIImage) {
        self.image = image
        view.setNeedsDisplay()
    }
}

@available(iOS 9.0, *)
extension MetalRenderer: MTKViewDelegate {

    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        view.setNeedsDisplay()
    }

    func draw(in view: MTKView) {

        guard let currentDrawable = view.currentDrawable, let unwrappedImage = image else { return }

        let commandBuffer = commandQueue.makeCommandBuffer()

        let outputTexture = currentDrawable.texture

        context.render(unwrappedImage, to: outputTexture, commandBuffer: commandBuffer, bounds: unwrappedImage.extent, colorSpace: colorSpace)
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
    }
}

#else

class MetalRenderer {}
    
#endif
