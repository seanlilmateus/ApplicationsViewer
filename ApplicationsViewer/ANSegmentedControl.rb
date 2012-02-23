#
#  ANSegmentedControl.rb
#  QRMacRuby
#
#
class ANSegmentedControl < NSSegmentedControl
  attr_accessor :aWindow, :currentView

  def acceptsFirstResponder
    true
  end
		
  def cellClass
    self.class
  end
		
  def initWithCoder aDecoder
    return super(aDecoder) if aDecoder.is_a? NSKeyedUnarchiver
    unarchiver = aDecoder
    old_class = self.superclass.cellClass
    new_class = self.class.cellClass
				
    unarchiver.setClass new_class, forClassName: NSStringFromClass(old_class)
    cell = super(aDecoder)
				
    unarchiver.setClass old_class, forClassName: NSStringFromClass(old_class)
    cell
  end
		
  def awakeFromNib
    transition = CATransition.animation
    transition.type = KCATransitionPush
    transition.subtype = KCATransitionFromLeft
				
    anim = {subviews: transition}
    # @contentView.animations = anim
				
    @location = NSPoint.new
    self.boundsSize = NSMakeSize(self.bounds.size.width, 25)
    self.frameSize = NSMakeSize(self.frame.size.width, 25)
				
    @location.x = self.frame.size.width / self.segmentCount * self.selectedSegment
				
    self.cell.trackingMode = NSSegmentSwitchTrackingSelectOne
  end
		
  def drawRect dirtyRect
    rect = self.bounds
    rect.size.height -= 1
    draws_background rect
    drawKnob rect
  end
		
  def drawSegment segment, inFrame:frame, withView:controlView
    if (self.window.isKeyWindow)
      imageFraction = 0.5
    else
      imageFraction = 0.2
    end
    NSGraphicsContext.currentContext.imageInterpolation =  NSImageInterpolationHigh
    rect = NSMakeRect(frame.origin.x, frame.origin.y + 1, self.imageForSegment(segment).size.width, self.imageForSegment(segment).size.height + 1)
				
    self.imageForSegment(segment).drawInRect rect,
				                            fromRect: NSZeroRect,
				                           operation: NSCompositeSourceOver,
				                            fraction: imageFraction,
				                      respectFlipped: true,
				                               hints: nil
  end
		
  def mouseDown event
    loop = true
    clickLocation = self.convertPoint event.locationInWindow, fromView:nil
				
    knobWidth = self.frame.size.width / self.segmentCount
    knobRect = NSMakeRect(@location.x, 0, knobWidth, self.frame.size.height)
    if NSPointInRect(clickLocation, self.bounds)
      localLastDragLocation= clickLocation
      while (loop)
        localEvent = self.window.nextEventMatchingMask NSLeftMouseUpMask |NSLeftMouseDraggedMask
        case localEvent.type
        when NSLeftMouseDragged
          if (NSPointInRect(clickLocation, knobRect))
            newDragLocation = self.convertPoint localEvent.locationInWindow,fromView:nil
            offsetLocationByX (newDragLocation.x - localLastDragLocation.x)
            localLastDragLocation = newDragLocation
            self.autoscroll localEvent
          end
        when NSLeftMouseUp
          loop = false
          if ((clickLocation == localLastDragLocation))
            newSegment = (clickLocation.x / knobWidth).floor
            animateTo (newSegment * knobWidth)
          else
            newSegment = (@location.x / knobWidth).round.to_i
            animateTo (newSegment * knobWidth)
          end
          setSelectedSegment newSegment
          self.window.invalidateCursorRectsForView self
        else
          break
        end
      end
    end
    return
  end
				
  def setSelectedSegment newSegment
    super
    setSelectedSegment newSegment, animate:true
  end
		
  def setSelectedSegment newSegment, animate:animate
    return if (newSegment == self.selectedSegment)
    maxX = self.frame.size.width - (self.frame.size.width / self.segmentCount)
    x = newSegment > self.segmentCount ? maxX : newSegment * (self.frame.size.width / self.segmentCount)
    if animate
      animateTo x
    else
      self.needsDisplay = true                
    end
    setSelectedSegment(newSegment)
  end
		
		
  def draws_background rect
    radius = 3.5
    path = NSBezierPath.bezierPathWithRoundedRect rect, xRadius:radius, yRadius:radius
				
				
    if (self.window.isKeyWindow)
      startColor = NSColor.colorWithCalibratedWhite 0.75, alpha:1.0
      endColor = NSColor.colorWithCalibratedWhite 0.6, alpha:1.0
						
      gradient = NSGradient.alloc.initWithStartingColor startColor, endingColor:endColor
      frameColor = NSColor.colorWithCalibratedWhite 0.37, alpha:1.0
    else
      startColor = NSColor.colorWithCalibratedWhite 0.8, alpha:1.0
      endColor = NSColor.colorWithCalibratedWhite 0.77, alpha:1.0
						
      gradient = NSGradient.alloc.initWithStartingColor startColor, endingColor:endColor
      frameColor = NSColor.colorWithCalibratedWhite 0.68, alpha:1.0
    end
    NSGraphicsContext.transactionUsingBlock do |contest|
      dropShadow = NSShadow.alloc.init
      dropShadow.setShadowOffset NSMakeSize(0, -1.0)
      dropShadow.setShadowBlurRadius 1.0
      dropShadow.setShadowColor NSColor.colorWithCalibratedWhite 0.863, alpha:0.75
      dropShadow.set
      path.fill
    end
    
				
    gradient.drawInBezierPath path, angle:-90
    frameColor.setStroke
    path.strokeInside
    segmentWidth = rect.size.width / self.segmentCount
    segmentHeight = rect.size.height
    segmentRect = NSMakeRect(0, 0, segmentWidth, segmentHeight)
				
    self.segmentCount.times do |idx|
      self.drawSegment idx,inFrame:segmentRect, withView:self
      segmentRect.origin.x += segmentWidth
    end
  end
		
  def drawKnob rect
    radius = 3.0
    if (self.window.isKeyWindow)
      startColor = NSColor.colorWithCalibratedWhite 0.68, alpha:1.0
      endColor = NSColor.colorWithCalibratedWhite 0.91, alpha:1.0
						
      gradient = NSGradient.alloc.initWithStartingColor startColor, endingColor:endColor
      imageFraction = 1.0
      frameColor = NSColor.colorWithCalibratedWhite 0.37, alpha:1.0
    else
      startColor = NSColor.colorWithCalibratedWhite 0.76, alpha:1.0
      endColor = NSColor.colorWithCalibratedWhite 0.90, alpha:1.0
						
      gradient = NSGradient.alloc.initWithStartingColor startColor, endingColor:endColor
      imageFraction = 0.25
      frameColor = NSColor.colorWithCalibratedWhite 0.68, alpha:1.0       
    end
    width = rect.size.width / self.segmentCount
    height = rect.size.height
    path = NSBezierPath.bezierPathWithRoundedRect([@location.x, rect.origin.y, width, height], xRadius:radius, yRadius:radius)
				
    gradient.drawInBezierPath path, angle:-90
    frameColor.setStroke
    path.strokeInside
				
    newSegment = (@location.x / width).round.to_i
    pt = @location
    knobRect = [pt.x,pt.y + 1, self.imageForSegment(newSegment).size.width, self.imageForSegment(newSegment).size.height + 1]
				
    self.imageForSegment(newSegment).drawInRect knobRect,   
                                      fromRect: NSZeroRect,
				                             operation: NSCompositeSourceOver,
                                      fraction: imageFraction,
                                respectFlipped: true,
                                         hints: nil
  end
  def animateTo x
    maxX = self.frame.size.width - (self.frame.size.width / self.segmentCount)
    anim = ANKnobAnimation.alloc.initWithStart @location.x, to:x
    anim.delegate = self
    if (@location.x == 0 || @location.x == maxX)
      anim.setDuration 0.20
      anim.setAnimationCurve NSAnimationEaseInOut
    else
      anim.setDuration 0.35 * ((@location.x - x).abs / maxX)
      anim.setAnimationCurve NSAnimationLinear
    end
    anim.setAnimationBlockingMode NSAnimationBlocking
    anim.startAnimation
  end
		
  def setPosition x
    @location.x = x
    self.display
  end
		
  def offsetLocationByX x
    @location.x = @location.x + x
    maxX = self.frame.size.width - (self.frame.size.width / self.segmentCount)
    @location.x = 0 if (@location.x < 0)
    @location.x = maxX if (@location.x > maxX)
    self.setNeedsDisplay true
  end
end


