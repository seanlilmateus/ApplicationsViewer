#
#  NSBezierPath_erweiterung.rb
#  GreatUI
#
#  Created by Mateus Kimbango Armando on 20.05.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
class NSBezierPath
    def bezierPathWithCGPath pathRef
        path = NSBezierPath.bezierPath
        CGPathApply(pathRef, path, CGPathCallback)
        return path
    end
    def cgPath
        thePath = CGPathCreateMutable()
        return nil unless (thePath)
        elementCount =  self.elementCount
        # The maximum number of points is 3 for a NSCurveToBezierPathElement.
        # (controlPoint1, controlPoint2, and endPoint)
        controlPoints = Array.new(3, NSPoint.new)
        elementCount.each_index do |idx|
            case self.elementAtIndex idx, associatedPoints:controlPoints
                when NSMoveToBezierPathElement
                CGPathMoveToPoint(thePath, CGAffineTransformIdentity, controlPoints[0].x, controlPoints[0].y)
                
                when NSLineToBezierPathElement
                CGPathAddLineToPoint(thePath, CGAffineTransformIdentity, controlPoints[0].x, controlPoints[0].y)
                
                when NSCurveToBezierPathElement
                CGPathAddCurveToPoint(thePath, CGAffineTransformIdentity, controlPoints[0].x, controlPoints[0].y,
                                      controlPoints[1].x, controlPoints[1].y, controlPoints[2].x, controlPoints[2].y)
                
                when NSClosePathBezierPathElement
                CGPathCloseSubpath(thePath)
                else
                NSLog("Unknown element at [NSBezierPath (GTMBezierPathCGPathAdditions) cgPath]")
            end
        end
        return thePath
    end
    
    def pathWithStrokeWidth strokeWidth
        path = self.copy
        context = NSGraphicsContext.currentContext.graphicsPort
        pathRef = path.cgPath
        CGContextSaveGState(context)
        CGContextBeginPath(context)
        CGContextAddPath(context, pathRef)
        CGContextSetLineWidth(context, strokeWidth)
        CGContextReplacePathWithStrokedPath(context)
        strokedPathRef = CGContextCopyPath(context)
        CGContextBeginPath(context)
        strokedPath = NSBezierPath.bezierPathWithCGPath strokedPathRef
        
        CGContextRestoreGState(context)
        
        CFRelease(pathRef)
        CFRelease(strokedPathRef)
        
        return strokedPath
    end
    
    def fillWithInnerShadow shadow
        NSGraphicsContext.saveGraphicsState
        offset = shadow.shadowOffset
        originalOffset = offset
        radius = shadow.shadowBlurRadius
        bounds = NSInsetRect(self.bounds, -(offset.width + radius).abs, -(offset.height + radius).abs)
        offset.height += bounds.size.height
        shadow.shadowOffset = offset
        
        transform = NSAffineTransform.transform
        if (NSGraphicsContext.currentContext.isFlipped)
            transform.translateXBy 0, yBy:bounds.size.height
            else
            transform translateXBy 0, yBy:-bounds.size.height
        end
        
        drawingPath = NSBezierPath.bezierPathWithRect bounds
        drawingPath.setWindingRule NSEvenOddWindingRule
        drawingPath.appendBezierPath self
        drawingPath.transformUsingAffineTransform transform
        
        self.addClip
        shadow.set
        NSColor.blackColor.set
        drawingPath.fill
        
        shadow.shadowOffset = originalOffset
        
        NSGraphicsContext.restoreGraphicsState
    end
    
    def drawBlurWithColor color, radius: radius
        bounds = NSInsetRect(self.bounds, -radius, -radius)
        shadow = NSShadow.alloc.init
        shadow.shadowOffset = NSMakeSize(0, bounds.size.height)
        shadow.shadowBlurRadius = radius
        shadow.shadowColor = color
        path = self.copy
        
        transform = NSAffineTransform.transform
        if (NSGraphicsContext.currentContext.isFlipped)
            transform.translateXBy 0, yBy:bounds.size.height
            else
            transform.translateXBy 0, yBy:-bounds.size.height
        end
        
        path.transformUsingAffineTransform transform
        
        NSGraphicsContext.saveGraphicsState
        
        shadow.set
        NSColor.blackColor.set
        NSRectClip(bounds)
        path.fill
        NSGraphicsContext.restoreGraphicsState
    end
    
    def strokeInside
        self.strokeInsideWithinRect NSZeroRect
    end
    
    def strokeInsideWithinRect clipRect
        thisContext = NSGraphicsContext.currentContext
        
        lineWidth = self.lineWidth
        
        # Save the current graphics context.
        thisContext.saveGraphicsState
        
        self.setLineWidth (lineWidth * 2.0)
        self.setClip
        
        if (clipRect.size.width > 0.0 && clipRect.size.height > 0.0)
            NSBezierPath.clipRect clipRect
        end
        
        self.stroke
        thisContext.restoreGraphicsState
        self.setLineWidth lineWidth
    end
end

class NSShadow
    def initWithColor color, offset: offset, blurRadius:blur
        shadow = self.init
        if (shadow != nil)
            shadow.shadowColor = color
            shadow.shadowOffset = offset
            shadow.shadowBlurRadius = blur
        end
        return self
    end
end

