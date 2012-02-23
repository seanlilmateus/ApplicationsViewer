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

# Corner clipping radius **/
CORNER_CLIP_RADIUS = 4.0

class INTitlebarView < NSView
    
    COLOR_MAIN_START = NSColor.colorWithDeviceWhite 0.66, alpha:1.0
    COLOR_MAIN_END = NSColor.colorWithDeviceWhite 0.9, alpha:1.0
    COLOR_MAIN_BOTTOM = NSColor.colorWithDeviceWhite 0.408, alpha:1.0
    
    COLOR_NOTMAIN_START = NSColor.colorWithDeviceWhite 0.878, alpha:1.0
    COLOR_NOTMAIN_END = NSColor.colorWithDeviceWhite 0.976, alpha:1.0
    COLOR_NOTMAIN_BOTTOM = NSColor.colorWithDeviceWhite 0.655, alpha:1.0

	MDAppleMiniaturizeOnDoubleClickKey = "AppleMiniaturizeOnDoubleClick"
    
	def drawRect dirtyRect
		drawsAsMainWindow = (self.window.isMainWindow && NSApplication.sharedApplication.isActive)
		drawing_rect = self.bounds
		drawing_rect.size.height -= 1.0 # Decrease the height by 1.0px to show the highlight line at the top
		start_color = drawsAsMainWindow ? COLOR_MAIN_START : COLOR_NOTMAIN_START
		end_color   = drawsAsMainWindow ? COLOR_MAIN_END : COLOR_NOTMAIN_END
				
		NSGraphicsContext.transactionUsingBlock do |current_context|
			self.clippingPathWithRect(drawing_rect, cornerRadius:CORNER_CLIP_RADIUS).addClip
			gradient = NSGradient.alloc.initWithStartingColor start_color, endingColor:end_color
			gradient.drawInRect drawing_rect, angle:90
			noise_pattern = CIImage.new
			if drawsAsMainWindow
				random_generator = CIFilter.filterWithName "CIColorMonochrome"
				random_generator.setValue CIFilter.filterWithName("CIRandomGenerator").valueForKey("outputImage"), forKey:"inputImage"
				random_generator.setDefaults
				noise_pattern = random_generator.valueForKey "outputImage"
			end
			noise_pattern.drawAtPoint NSZeroPoint, fromRect:self.bounds, operation:NSCompositePlusLighter, fraction:0.04
			bottom_color = drawsAsMainWindow ? COLOR_MAIN_BOTTOM : COLOR_NOTMAIN_BOTTOM
			bottom_rect = NSMakeRect(0.0, NSMinY(drawing_rect), NSWidth(drawing_rect), 1.0)
			bottom_color.set
			NSRectFill(bottom_rect)
			bottom_rect.origin.y += 1.0
			NSColor.colorWithDeviceWhite(1.0, alpha:0.12).setFill
			NSBezierPath.bezierPathWithRect(bottom_rect).fill
		end
		# self.setAutoresizesSubviews true
	end
	
	def clippingPathWithRect aRect, cornerRadius:radius
		path = NSBezierPath.bezierPath
		rect = NSInsetRect(aRect, radius, radius)
		corner_point = NSMakePoint(NSMinX(aRect), NSMinY(aRect))
		# Create a rounded rectangle path, omitting the bottom left/right corners
		path.appendBezierPathWithPoints corner_point, count:1

		corner_point = NSMakePoint(NSMaxX(aRect), NSMinY(aRect))
		path.appendBezierPathWithPoints corner_point, count:1

		path.appendBezierPathWithArcWithCenter NSMakePoint(NSMaxX(rect), NSMaxY(rect)), 
										radius:radius,
									startAngle:0.0, 
									  endAngle: 90.0
		
		path.appendBezierPathWithArcWithCenter NSMakePoint(NSMinX(rect), NSMaxY(rect)), 
										radius:radius, 
									startAngle:90.0, 
									  endAngle:180.0
		path.closePath
        path
	end

	def mouseUp theEvent
		if (theEvent.clickCount == 2)
			user_defaults = NSUserDefaults.standardUserDefaults
			user_defaults.addSuiteNamed NSGlobalDomain
			should_miniaturize = user_defaults.objectForKey(MDAppleMiniaturizeOnDoubleClickKey)
			self.window.miniaturize(self) if (should_miniaturize)
		end
	end
end




