#
#  inTitlebarView.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 10.11.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
#
#  File.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 10.11.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#

COLOR_MAIN_START = NSColor.colorWithDeviceWhite 0.66, alpha:1.0
COLOR_MAIN_END = NSColor.colorWithDeviceWhite 0.9, alpha:1.0
COLOR_MAIN_BOTTOM = NSColor.colorWithDeviceWhite 0.408, alpha:1.0

COLOR_NOTMAIN_START = NSColor.colorWithDeviceWhite 0.878, alpha:1.0
COLOR_NOTMAIN_END = NSColor.colorWithDeviceWhite 0.976, alpha:1.0
COLOR_NOTMAIN_BOTTOM = NSColor.colorWithDeviceWhite 0.655, alpha:1.0

# Corner clipping radius **/
CORNER_CLIP_RADIUS = 4.0

class INTitlebarView < NSView
	MDAppleMiniaturizeOnDoubleClickKey = "AppleMiniaturizeOnDoubleClick"
	def drawRect dirtyRect
		drawsAsMainWindow = (self.window.isMainWindow && NSApplication.sharedApplication.isActive)
		drawingRect = self.bounds
		drawingRect.size.height -= 1.0 # Decrease the height by 1.0px to show the highlight line at the top
		startColor = drawsAsMainWindow ? COLOR_MAIN_START : COLOR_NOTMAIN_START
		endColor   = drawsAsMainWindow ? COLOR_MAIN_END : COLOR_NOTMAIN_END
				
		NSGraphicsContext.transactionUsingBlock -> currentContext do
			self.clippingPathWithRect(drawingRect, cornerRadius:CORNER_CLIP_RADIUS).addClip
			gradient = NSGradient.alloc.initWithStartingColor startColor, endingColor:endColor
			gradient.drawInRect drawingRect, angle:90
			noisePattern = CIImage.new
			if drawsAsMainWindow
				randomGenerator = CIFilter.filterWithName "CIColorMonochrome"
				randomGenerator.setValue CIFilter.filterWithName("CIRandomGenerator").valueForKey("outputImage"), forKey:"inputImage"
				randomGenerator.setDefaults
				noisePattern = randomGenerator.valueForKey "outputImage"
			end
			noisePattern.drawAtPoint NSZeroPoint, fromRect:self.bounds, operation:NSCompositePlusLighter, fraction:0.04
			bottomColor = drawsAsMainWindow ? COLOR_MAIN_BOTTOM : COLOR_NOTMAIN_BOTTOM
			bottomRect = NSMakeRect(0.0, NSMinY(drawingRect), NSWidth(drawingRect), 1.0)
			bottomColor.set
			NSRectFill(bottomRect)
			bottomRect.origin.y += 1.0
			NSColor.colorWithDeviceWhite(1.0, alpha:0.12).setFill
			NSBezierPath.bezierPathWithRect(bottomRect).fill
		end
		# self.setAutoresizesSubviews true
	end
	
	def clippingPathWithRect aRect, cornerRadius:radius
		path = NSBezierPath.bezierPath
		rect = NSInsetRect(aRect, radius, radius)
		cornerPoint = NSMakePoint(NSMinX(aRect), NSMinY(aRect))
		# Create a rounded rectangle path, omitting the bottom left/right corners
		path.appendBezierPathWithPoints cornerPoint, count:1

		cornerPoint = NSMakePoint(NSMaxX(aRect), NSMinY(aRect))
		path.appendBezierPathWithPoints cornerPoint, count:1

		path.appendBezierPathWithArcWithCenter NSMakePoint(NSMaxX(rect), NSMaxY(rect)), 
										radius:radius,
									startAngle:0.0, 
									  endAngle: 90.0
		
		path.appendBezierPathWithArcWithCenter NSMakePoint(NSMinX(rect), NSMaxY(rect)), 
										radius:radius, 
									startAngle:90.0, 
									  endAngle:180.0
		path.closePath
		return path
	end

	def mouseUp theEvent
		if (theEvent.clickCount == 2)
			userDefaults = NSUserDefaults.standardUserDefaults
			userDefaults.addSuiteNamed NSGlobalDomain
			shouldMiniaturize = userDefaults.objectForKey(MDAppleMiniaturizeOnDoubleClickKey)
			self.window.miniaturize(self) if (shouldMiniaturize)
		end
	end
end




