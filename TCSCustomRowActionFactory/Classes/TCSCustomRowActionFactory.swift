//
//  TCSCustomRowActionFactory.swift
//  TCSCustomRowActionFactory
//
//  Created by Alexander Trushin on 19.12.17.
//  Copyright © 2017 Tinkoff.ru. All rights reserved.
//

import Foundation
import UIKit

public typealias TCSCustomRowActionFactoryTapHandler = (IndexPath) -> Void

public protocol TCSCustomRowActionFactoryDelegate: class {
    
    func rowActionFactory(_ rowActionFactory: TCSCustomRowActionFactory, didTapActionAt indexPath: IndexPath)
}

public class TCSCustomRowActionFactory {
    
    // MARK: Private Data Structures
    
    private enum Constants {
        static let placeholderSymbol = "\u{200A}"
        static let minimalActionWidth: CGFloat = 30
        static let actionWidthForIos11: CGFloat = 74
        static let distortionFactor: CGFloat = 1.1
        
        static let defaultInsetFactor: CGFloat = 0.05
        static let defaultTextTopOffsetFactor: CGFloat = 0.1
    }
    
    
    // MARK: Public Properties
    
    public var tapHandler: TCSCustomRowActionFactoryTapHandler?
    
    
    // MARK: Private Properties
    
    private weak var delegate: TCSCustomRowActionFactoryDelegate?
    
    private static let placeholderSymbolWidth: CGFloat = {
        let flt_max = CGFloat.greatestFiniteMagnitude
        let maxSize = CGSize(width: flt_max, height: flt_max)
        let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: UIFont.systemFontSize)]
        let boundingRect = Constants.placeholderSymbol.boundingRect(with: maxSize,
                                                                    options: .usesLineFragmentOrigin,
                                                                    attributes: attributes,
                                                                    context: nil)
        return boundingRect.width
    }()
    
    private var backgroundColor: UIColor = .white
    private var convertedTitle: String?
    private var convertedImage: UIImage?
    
    
    
    
    // MARK: Lifecycle
    
    public init(with delegate: TCSCustomRowActionFactoryDelegate) {
        self.delegate = delegate
    }
    
    public init(with tapHandler: @escaping TCSCustomRowActionFactoryTapHandler) {
        self.tapHandler = tapHandler
    }
    
    
    // MARK: Public
    
    // TODO: make render title and backgroundColor if needed
    
    public func setupForCell(withImage image: UIImage, size: CGSize, backgroundColor: UIColor = .white) {
        setupForCell(withImage: image, size: size, backgroundColor: backgroundColor, contentInsets: .zero, isScaleProportionally: true)
    }
    
    public func setupForCell(withImage image: UIImage, size: CGSize, backgroundColor: UIColor = .white, contentInsets: UIEdgeInsets = .zero) {
        setupForCell(withImage: image, size: size, backgroundColor: backgroundColor, contentInsets: contentInsets, isScaleProportionally: true)
    }
    
    public func setupForCell(withImage image: UIImage, size: CGSize, backgroundColor: UIColor = .white, contentInsets: UIEdgeInsets = .zero, isScaleProportionally: Bool = true) {
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        backgroundColor.set()
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let trimmedSize = CGSize(width: size.width - contentInsets.left - contentInsets.right,
                                 height: size.height - contentInsets.top - contentInsets.bottom)
        
        let drawingRect: CGRect
        
        if isScaleProportionally || contentInsets == .zero {
            let drawingSize = proportionallyScaledSize(from: image.size, for: trimmedSize)
            
            drawingRect = CGRect(x: (trimmedSize.width - drawingSize.width) / 2 + contentInsets.left,
                                 y: (trimmedSize.height - drawingSize.height) / 2 + contentInsets.top,
                                 width: drawingSize.width,
                                 height: drawingSize.height)
        } else {
            let origin = CGPoint(x: contentInsets.left,
                                 y: contentInsets.top)
            drawingRect = CGRect(origin: origin, size: trimmedSize)
        }
        
        image.draw(in: drawingRect)
        
        guard let fullActionImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return
        }
        
        self.backgroundColor = backgroundColor
        self.convertedTitle = emptyTitle(for: size)
        self.convertedImage = fullActionImage
    }
    
    // use view looks like template image
    // используйте view, которая соответствует template image(с альфа каналом): цвет фона - прозрачный, остальные элементы одного цвета (для одинакового отображения ios 11 и ниже)
    public func setupForCell(with view: UIView) {
        guard let img = image(from: view) else { return }
        
        self.convertedTitle = emptyTitle(for: img.size)
        self.convertedImage = img
    }
    
    public func setupForCell(withTitle title: String, image: UIImage, size: CGSize, backgroundColor: UIColor, titleAttributes: [NSAttributedStringKey : Any]? = nil, contentInsets: UIEdgeInsets? = nil) {
        defer {
            UIGraphicsEndImageContext()
        }
        
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        
        backgroundColor.set()
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let insets: UIEdgeInsets
        if let contentInsets = contentInsets {
            insets = contentInsets
        } else {
            insets = UIEdgeInsets(top: size.width * Constants.defaultInsetFactor,
                                  left: size.height * Constants.defaultInsetFactor,
                                  bottom: size.width * Constants.defaultInsetFactor,
                                  right: size.height * Constants.defaultInsetFactor)
        }
        
        let trimmedSize = CGSize(width: size.width - insets.left - insets.right,
                                 height: size.height - insets.top - insets.bottom)
        
        let textSize = title.size(withAttributes: titleAttributes)
        let textTopOffset = trimmedSize.height * Constants.defaultTextTopOffsetFactor
        let remainingSize = CGSize(width: trimmedSize.width,
                                   height: trimmedSize.height - textSize.height - textTopOffset)
        let imageSize = proportionallyScaledSize(from: image.size, for: remainingSize)
        let allContentHeight = imageSize.height + textTopOffset + textSize.height
        
        let imageDrawingPoint = CGPoint(x: (size.width - imageSize.width) / 2,
                                        y: (size.height - allContentHeight) / 2)
        let textDrawingPoint = CGPoint(x: (size.width - textSize.width) / 2,
                                       y: imageDrawingPoint.y + imageSize.height + textTopOffset)
        image.draw(in: CGRect(x: imageDrawingPoint.x,
                              y: imageDrawingPoint.y,
                              width: imageSize.width, height: imageSize.height))
        title.draw(at: textDrawingPoint, withAttributes: titleAttributes)
        
        guard let fullActionImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return
        }
        
        self.backgroundColor = backgroundColor
        self.convertedTitle = emptyTitle(for: size)
        self.convertedImage = fullActionImage
    }
    
    
    // MARK: Factory methods
    
    public func rowAction() -> UITableViewRowAction? {
        guard let convertedImage = convertedImage else { return nil }
        
        let action = UITableViewRowAction(style: .default, title: convertedTitle) { (action, indexPath) in
            self.delegate?.rowActionFactory(self, didTapActionAt: indexPath)
            self.tapHandler?(indexPath)
        }
        action.backgroundColor = UIColor(patternImage: convertedImage)
    
        return action
    }
    
    @available(iOS 11.0, *)
    public func contextualAction(for indexPath: IndexPath) -> UIContextualAction? {
        let contextualAction = UIContextualAction(style: .normal, title: nil) { _,_,_  in
            self.delegate?.rowActionFactory(self, didTapActionAt: indexPath)
            self.tapHandler?(indexPath)
        }
        
        contextualAction.image = resizedImageForIos11(image: convertedImage)
        contextualAction.backgroundColor = backgroundColor
        
        return contextualAction
    }
    
    
    // MARK: Helpers
    
    private func image(from view: UIView) -> UIImage? {
        if view.bounds.size.width < Constants.minimalActionWidth {
            assertionFailure("row action view width should be 30 or more");
            view.frame.size.width = Constants.minimalActionWidth
            view.layoutIfNeeded()
        }
        
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            assertionFailure("Something wrong with CoreGraphics image context");
            return nil
        }
        
        context.setFillColor(UIColor.clear.cgColor)
        context.fill(CGRect(origin: .zero, size: view.bounds.size))
        
        view.layer.render(in: context)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return img
    }
    
    private func emptyTitle(for size: CGSize) -> String {
        var usefulWidth = size.width - Constants.minimalActionWidth
        usefulWidth = usefulWidth < 0 ? 0 : usefulWidth
        let countOfSymbols = Int(floor(usefulWidth * Constants.distortionFactor / TCSCustomRowActionFactory.placeholderSymbolWidth))
        
        return String(repeating: Constants.placeholderSymbol, count: countOfSymbols)
    }
    
    private func emptyTitle(for size: CGSize, title: String) -> String {
        let titleWidth = textWidth(for: title)
        let remainingWidth = size.width - titleWidth
        let emptySpaces = emptyTitle(for: CGSize(width: remainingWidth, height: size.height))
        
        return title + emptySpaces
    }
    
    private func textWidth(for text: String) -> CGFloat {
        let flt_max = CGFloat.greatestFiniteMagnitude
        let maxSize = CGSize(width: flt_max, height: flt_max)
        let attributes = [NSAttributedStringKey.font : UIFont.systemFont(ofSize: UIFont.buttonFontSize)]
        let boundingRect = text.boundingRect(with: maxSize,
                                             options: .usesLineFragmentOrigin,
                                             attributes: attributes,
                                             context: nil)
        return boundingRect.width
    }
    
    private func proportionallyScaledSize(from imageSize: CGSize, for size: CGSize) -> CGSize {
        let imageAspect = imageSize.width / imageSize.height
        
        let scaledWidth: CGFloat
        let scaledHeight: CGFloat
        if size.width / imageAspect <= size.height {
            scaledWidth = min(size.width, imageSize.width)
            scaledHeight = min(size.width / imageAspect, imageSize.height)
        } else {
            scaledWidth = min(size.height * imageAspect, imageSize.width)
            scaledHeight = min(size.height, imageSize.height)
        }
        
        return CGSize(width: scaledWidth, height: scaledHeight)
    }
    
    private func resizedImageForIos11(image: UIImage?) -> UIImage? {
        guard let image = image else {
            return nil
        }
        
        defer {
            UIGraphicsEndImageContext()
        }
        
        let newSize = CGSize(width: Constants.actionWidthForIos11, height: image.size.height)
        
        let drawingSize = proportionallyScaledSize(from: image.size, for: newSize)
        let drawingRect = CGRect(x: (newSize.width - drawingSize.width) / 2,
                             y: (newSize.height - drawingSize.height) / 2,
                             width: drawingSize.width,
                             height: drawingSize.height)
        
        // TODO: check isOpaque
        UIGraphicsBeginImageContextWithOptions(newSize, false, UIScreen.main.scale)
        image.draw(in: drawingRect)
        
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else {
            assertionFailure("Something wrong with get image from current image context");
            return nil
        }
        
        return newImage
    }
}
