#
#  MASWindow.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 10.11.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
class MASWindow < NSWindow
 attr_accessor :windowMenuTitle, :myView, :centerFullScreenButton
  ## INITIALIZATION ##
  def initWithContentRect contentRect, styleMask:aStyle, backing:bufferingType, defer:flag
				super(contentRect,aStyle,bufferingType,flag)
				self.doInitialWindowSetup 
				self
  end
  
		def initWithContentRect contentRect, styleMask:aStyle, backing:bufferingType, defer:flag, screen:screen
				super(contentRect,aStyle,bufferingType,flag, screen) 
				self.doInitialWindowSetup
				self
  end
  
  ## NSWINDOW OVERRIDES ##
  def title;"";end
  def setTitle aTitle
    self.windowMenuTitle = aTitle
    NSApp.changeWindowsItem(self, title:self.windowMenuTitle, filename:false) unless self.isExcludedFromWindowsMenu
  end
		
		def dealloc
				NSNotificationCenter.defaultCenter.removeObserver self
		end
		
  # do nothing, don't want to show document icon in menu bar
  def setRepresentedURL aURL 
		end
  
		def makeKeyAndOrderFront sender
				super sender
				NSApp.addWindowsItem(self, title:self.windowMenuTitle, filename:false) unless self.isExcludedFromWindowsMenu
    @titleBarView.setNeedsDisplay true
		end
  
		def orderFront sender
    super sender
				NSApp.addWindowsItem self, title:self.windowMenuTitle, filename:false	 unless(self.isExcludedFromWindowsMenu)
		end
  
		def becomeKeyWindow
				super
    @titleBarView.setNeedsDisplay true
		end
		
		def resignKeyWindow
				super
				@titleBarView.setNeedsDisplay true
		end
		
		def orderOut sender
				super sender
    NSApp.removeWindowsItem self
		end
  
		## ACCESSORS ##
		def layoutTrafficLightsAndContent
    contentView = self.contentView
    close = self.standardWindowButton NSWindowCloseButton
    minimize = self.standardWindowButton NSWindowMiniaturizeButton
    zoom = self.standardWindowButton NSWindowZoomButton
    
    # Set the frame of the window buttons
    closeFrame = close.frame
    minimizeFrame = minimize.frame
    zoomFrame = zoom.frame
	buttonOrigin = (NSMidY(@titleBarView.frame) - (closeFrame.size.height / 2.0)).floor
	# buttonOrigin = self.frame.size.height - 20.0
	closeFrame.origin.y = buttonOrigin
    minimizeFrame.origin.y = buttonOrigin
    zoomFrame.origin.y = buttonOrigin
    close.frame = closeFrame
    minimize.frame = minimizeFrame
    zoom.frame = zoomFrame
	if Object.const_defined?(:NSWindowCollectionBehaviorFullScreenPrimary) && self.centerFullScreenButton
		if (fullScreen = self.standardWindowButton NSWindowFullScreenButton)
			fullScreenFrame = fullScreen.frame
			fullScreenFrame.origin.y = buttonOrigin
			fullScreen.frame = fullScreenFrame
		end
	end
    # Reposition the content view
    windowFrame = self.frame
    newFrame = contentView.frame
    titleHeight = windowFrame.size.height - newFrame.size.height
    extraHeight = @titleBarHeight - titleHeight
    newFrame.size.height -= extraHeight
    contentView.setFrame(newFrame)
  end
		
  def title_bar_view=(newTitleBarView)
				unless (@titleBarView or @titleBarView == newTitleBarView)
      @titleBarView.removeFromSuperview if @titleBarView.respond_to? :removeFromSuperview 
      @titleBarView = newTitleBarView
						
      # Configure the view properties and add it as a subview of the theme frame
      contentView = self.contentView
      themeFrame = contentView.superview
						firstSubview = themeFrame.subviews[0]
      @titleBarView.setAutoresizingMask(NSViewMinYMargin | NSViewWidthSizable)
      self.recalculateFrameForTitleBarView
      themeFrame.addSubview @titleBarView, positioned:NSWindowBelow, relativeTo:firstSubview
      self.layoutTrafficLightsAndContent
      self.displayWindowAndTitlebar
    end
  end
		
  def titleBarView
    @titleBarView
  end
  
  def title_bar_height=(new_height)
				minTitleHeight = self.minimumTitlebarHeight
    new_height = minTitleHeight if (new_height < minTitleHeight)
    if (@titleBarHeight != new_height)
      @titleBarHeight = new_height
						self.recalculateFrameForTitleBarView
						self.layoutTrafficLightsAndContent
						self.displayWindowAndTitlebar
				end
  end
		
  def titleBarHeight
    @titleBarHeight
  end
  
  ## PRIVATE ##
  def doInitialWindowSetup
				#set background image
				# theImage = NSImage.imageNamed "canvas"
				# theColor = NSColor.colorWithPatternImage theImage
				# self.setBackgroundColor theColor

    # Calculate titlebar height
    @titleBarHeight = self.minimumTitlebarHeight
    self.setMovableByWindowBackground true
    nc = NSNotificationCenter.defaultCenter
    nc.addObserver self, selector:(:layoutTrafficLightsAndContent), name:NSWindowDidResizeNotification, object:self
    nc.addObserver self, selector:(:layoutTrafficLightsAndContent), name:NSWindowDidMoveNotification, object:self
    nc.addObserver self, selector:(:displayWindowAndTitlebar), name:NSWindowDidResignKeyNotification, object:self
    nc.addObserver self, selector:(:displayWindowAndTitlebar), name:NSWindowDidBecomeKeyNotification, object:self
    nc.addObserver self, selector:(:setupTrafficLightsTrackingArea), name:NSWindowDidBecomeKeyNotification, object:self
    
    nc.addObserver self, selector:(:displayWindowAndTitlebar),name:NSApplicationDidBecomeActiveNotification,object:nil
    nc.addObserver self, selector:(:displayWindowAndTitlebar),name:NSApplicationDidResignActiveNotification,object:nil
				
    self.createTitlebarView
    self.layoutTrafficLightsAndContent
    self.setupTrafficLightsTrackingArea
  end
		
  def createTitlebarView
    # Create the title bar view
	self.title_bar_view = INTitlebarView.alloc.initWithFrame(NSZeroRect)
  end
  
  # Solution for tracking area issue thanks to https://gist.github.com/972958>
  def setupTrafficLightsTrackingArea
    self.contentView.superview.viewWillStartLiveResize
    self.contentView.superview.viewDidEndLiveResize
  end
		
  def recalculateFrameForTitleBarView
    contentView = self.contentView
    themeFrame = contentView.superview
    themeFrameRect = themeFrame.frame
    titleFrame = NSMakeRect(0.0, NSMaxY(themeFrameRect) - @titleBarHeight, themeFrameRect.size.width, @titleBarHeight)
    @titleBarView.setFrame titleFrame
  end
		
		def minimumTitlebarHeight
    minTitleHeight = 0.0
    unless minTitleHeight
      frameRect = self.frame
      contentRect = self.contentRectForFrameRect frameRect
      minTitleHeight = (frameRect.size.height - contentRect.size.height)
    end
    minTitleHeight
  end
		
  def displayWindowAndTitlebar
    @titleBarView.setNeedsDisplay true # Redraw the window and titlebar
  end

end