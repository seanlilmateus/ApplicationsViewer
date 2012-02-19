#
#  LBSegmentedButton.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 11.11.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
module RoundedRectPartType
  def self.middlePart;0;end
	def self.topPart; 1; end
	def self.bottomPart;2;end
end

class LBSegmentedButton < NSView
		attr_accessor :target, :previouslySelectedSegment
		DEFAULT_cellHeight = 35
		DEFAULT_borderColor = NSColor.colorWithCalibratedRed 200.0/255.0, green:200.0/255.0, blue:200.0/255.0, alpha:1.0
		DEFAULT_radius = 5
		
		SHADOWCOLOR    = NSColor.colorWithCalibratedRed 251.0/255.0,green:251.0/255.0,blue:251.0/255.0, alpha:1.0
		LIGHTTEXTCOLOR = NSColor.colorWithCalibratedRed 186.0/255.0,green:168.0/255.0,blue:168.0/255.0, alpha:1.0
		DARKTEXTCOLOR  = NSColor.colorWithCalibratedRed 88.0/255.0 ,green:88.0/255.0 ,blue:88.0/255.0, alpha:1.0
		HIGHLIGHTCOLOR = NSColor.colorWithCalibratedRed 247.0/255.0,green:247.0/255.0,blue:247.0/255.0, alpha:1.0
		GRADIENTCOLOR1 = NSColor.colorWithCalibratedRed 230.0/255.0,green:230.0/255.0,blue:230.0/255.0, alpha:1.0
		GRADIENTCOLOR2 = NSColor.colorWithCalibratedRed 247.0/255.0,green:247.0/255.0,blue:247.0/255.0, alpha:1.0
		
		def setSelectedSegment value
			unless value == @selectedSegment
				@selectedSegment = value 
						self.setNeedsDisplay true
				end
		end
    
		def numberOfCells
            @titles ? @titles.count : 0
		end
		
		def initWithFrame frameRect, titles:values, target:value
      self.initWithFrame frameRect
      @titles = values
      # @target = value
      # set default drawing info
      @borderColor = DEFAULT_borderColor
      @cellHeight = DEFAULT_cellHeight
      @radius = DEFAULT_radius
      self
		end
		
		def initWithFrame frameRect
		  super frameRect
		  @titles = ["YOURSELF","CHECK","MATEUS","MORE","ARMANDO","KIMBANGO"]
		  @target = nil
		  @selectedSegment = -1
		  @previouslySelectedSegment = -1
		  # set default drawing info
		  @borderColor = DEFAULT_borderColor
		  @cellHeight = DEFAULT_cellHeight
		  @radius = DEFAULT_radius
		  
		  if (NSHeight(frameRect) != self.numberOfCells * (@cellHeight + 2)+1)
		    NSLog("The height doesn't match to the cellHeight. The proper height would be #{self.numberOfCells * (@cellHeight + 2)}")
		  end
		  new_frame = NSMakeRect(0,0, NSWidth(self.bounds), (@titles.size * @cellHeight)+12)
		  self.frame = new_frame
		  self
		end
		
		def awakeFromNib 
            self.drawTitles
		end
		
		def drawTitles
		  @titles.each_with_index do |title, idx|
		    label = NSTextField.alloc.initWithFrame NSMakeRect(0, 0, NSWidth(self.bounds), 17)
		    centerDistance = (@cellHeight - 17)/2
		    borders = (idx+1)*2
		    label.setBordered false
		    label.setDrawsBackground false
		    label.setSelectable false
		    label.setEditable false
		    label.setAlignment NSCenterTextAlignment
		    label.setTextColor DARKTEXTCOLOR
		    
		    label.setStringValue title
		    label.setFrameOrigin NSMakePoint(0, borders + centerDistance + idx * @cellHeight)
		    self.addSubview label
		  end
		end
    
    def drawCell type, rect:rect, index:idx
      context = NSGraphicsContext.currentContext.graphicsPort
    
      maxX = NSMaxX(rect)
      minX = NSMinX(rect)
      minY = NSMinY(rect)
    
      if (type == RoundedRectPartType.bottomPart)
        # Bottom shadow
        bottomShadow = CGPathCreateMutable()
      
        CGPathMoveToPoint(bottomShadow, nil, minX, minY+@radius)
      
        # 90degrees curve (left bottom)
        CGPathAddQuadCurveToPoint(bottomShadow, nil, minX, minY, minX+@radius , minY)
        CGPathAddLineToPoint(bottomShadow, nil, maxX - @radius, minY)
      
        # 90degrees curve (right bottom)
        CGPathAddQuadCurveToPoint(bottomShadow, nil, maxX, minY, maxX, @radius)
      
        SHADOWCOLOR.setStroke
        CGContextAddPath(context, bottomShadow)
        CGContextDrawPath(context, KCGPathStroke)
						
        # Box
        minY+=1
        box = CGPathCreateMutable();
						
        CGPathMoveToPoint(box, nil, minX, @cellHeight+3)
        CGPathAddLineToPoint(box, nil, minX, minY+@radius)
      
        # 90degrees curve (left bottom)
        CGPathAddQuadCurveToPoint(box, nil, minX, minY, minX+@radius , minY)
        CGPathAddLineToPoint(box, nil, maxX-@radius, minY)
      
        # 90degrees curve (right bottom)
        CGPathAddQuadCurveToPoint(box, nil, maxX, minY, maxX, minY+@radius) 
        CGPathAddLineToPoint(box, nil, maxX, @cellHeight+3)
        
        CGContextAddPath(context, box)
      
        @borderColor.setStroke
						
        if (@selectedSegment == idx)
					HIGHLIGHTCOLOR.setFill
					CGContextDrawPath(context, KCGPathFillStroke)
				else 
					CGContextDrawPath(context, KCGPathStroke)
        end
      
        CGPathRelease(box)
        CGPathRelease(bottomShadow);
      
			elsif (type == RoundedRectPartType.middlePart)
        # Box
        box = CGPathCreateMutable()
      
        CGPathMoveToPoint(box, nil, minX, minY+ 3 + @cellHeight)
        CGPathAddLineToPoint(box, nil, minX, minY+1)
        CGPathAddLineToPoint(box, nil, maxX, minY+1)
        CGPathAddLineToPoint(box, nil, maxX, minY+@cellHeight+3)
      
        CGContextAddPath(context, box)
      
        @borderColor.setStroke
      
				if (@selectedSegment == idx)
					HIGHLIGHTCOLOR.setFill
					CGContextDrawPath(context, KCGPathFillStroke)
				else
					CGContextDrawPath(context, KCGPathStroke)
        end
      
        # Seperator shadow
        shadow = CGPathCreateMutable()
      
        CGPathMoveToPoint(shadow, nil, minX+1, minY)
        CGPathAddLineToPoint(shadow, nil, maxX-1, minY)
      
        (@selectedSegment+1==idx) ? 	HIGHLIGHTCOLOR.setStroke : SHADOWCOLOR.setStroke
        CGContextAddPath(context, shadow)
        CGContextDrawPath(context, KCGPathStroke)
      
        CGPathRelease(box)
        CGPathRelease(shadow)
			else
        # Box
        box = CGPathCreateMutable()
      
        CGPathMoveToPoint(box, nil, minX, minY + 1)
        CGPathAddLineToPoint(box, nil, maxX, minY + 1)
						
        CGPathAddLineToPoint(box, nil, maxX, minY + @cellHeight - @radius + 2)
        CGPathAddQuadCurveToPoint(box, nil, maxX, minY+@cellHeight+2, maxX-@radius, minY + @cellHeight+2)
						
        CGPathAddLineToPoint(box, nil, minX+@radius, minY+@cellHeight+2)
        CGPathAddQuadCurveToPoint(box, nil, minX, minY + @cellHeight+2, minX, minY+@cellHeight-@radius+2)
						
        CGPathAddLineToPoint(box, nil, minX, minY+1)
        CGPathCloseSubpath(box)
      
        CGContextAddPath(context, box)
      
        @borderColor.setStroke
        if (@selectedSegment == idx)
					HIGHLIGHTCOLOR.setFill
					CGContextDrawPath(context, KCGPathFillStroke)
				else
				  CGContextDrawPath(context, KCGPathStroke)
        end
      
        # Seperator shadow
        shadow = CGPathCreateMutable()
      
        CGPathMoveToPoint(shadow, nil, minX + 1, minY)
        CGPathAddLineToPoint(shadow, nil, maxX - 1, minY)
      
        (@selectedSegment + 1 == idx) ? HIGHLIGHTCOLOR.setStroke : SHADOWCOLOR.setStroke 
      
        CGContextAddPath(context, shadow)
        CGContextDrawPath(context, KCGPathStroke)
      
        CGPathRelease(box)
        CGPathRelease(shadow)
      end
    end
		
		def drawBackground
				clipPath = NSBezierPath.bezierPathWithRoundedRect self.bounds, xRadius:@radius, yRadius:@radius
				gradient = NSGradient.alloc.initWithStartingColor GRADIENTCOLOR1, endingColor:GRADIENTCOLOR2
				gradient.drawInBezierPath clipPath, angle:90.0
		end
		
		def drawRect dirtyRect
				self.drawBackground
				(self.numberOfCells).times do |idx|
						# If it is the bottom
						if (idx == 0)
								self.drawCell RoundedRectPartType.bottomPart, 
																 rect:NSInsetRect(NSMakeRect(0, 0, NSWidth(self.bounds), @cellHeight+2), 0.5, 0.5), 
																index:idx
						elsif (idx == self.numberOfCells)
								self.drawCell RoundedRectPartType.topPart, 
																 rect:NSInsetRect(NSMakeRect(0, (@cellHeight+2) * idx, NSWidth(self.bounds), @cellHeight+2), 0.5, 0.5), 
																index:idx
						else 
								self.drawCell RoundedRectPartType.middlePart, 
																 rect:NSInsetRect(NSMakeRect(0, (@cellHeight+2) * idx, NSWidth(self.bounds), @cellHeight+2), 0.5, 0.5),
																index:idx
						end
				end
		end
		
		#pragma mark -
		#pragma mark Mouse Interaction
		def mouseDragged theEvent
				locationInWindow = theEvent.locationInWindow
				location = self.convertPoint locationInWindow, fromView:self.window.contentView
    @selectedSegment = (CGRectContainsPoint(self.bounds, NSPointToCGPoint(location))) ? @previouslySelectedSegment : -1
		end
		
		def mouseDown theEvent 
				super theEvent
				locationInWindow = theEvent.locationInWindow
				location = self.convertPoint(locationInWindow, fromView: self.window.contentView)
				
				self.numberOfCells.times do |idx|
						if (CGRectContainsPoint(CGRectMake(0, idx * (@cellHeight+3), NSWidth(self.bounds), @cellHeight+3), NSPointToCGPoint(location)))
								#setSelectedSegment idx
								@selectedSegment = idx
								@previouslySelectedSegment = idx
								self.setNeedsDisplay true
						end
				end
		end
		
		def mouseUp theEvent
    super theEvent
    locationInWindow = theEvent.locationInWindow
    location = self.convertPoint locationInWindow, fromView:self.window.contentView
    
    if (CGRectContainsPoint(self.bounds, NSPointToCGPoint(location)))
						sel = "buttonClicked:"
						selector = NSSelectorFromString(sel)
						if (self.respondsToSelector selector)
								self.performSelector selector, withObject:@selectedSegment
						end
    end
    setSelectedSegment -1
    @previouslySelectedSegment = -1
  end

		def buttonClicked object
				warn "buttonClicked #{object}"
		end
end
