#
#  MASWindow.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 10.11.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
module MASWindowHelpers  
  INBUTTON_TOP_OFFSET = 3.0
  
  def INMidHeight a_rect
    a_rect.size.height * 0.5
  end
	
end

class MASWindow < NSWindow
  include MASWindowHelpers
  attr_accessor :titlebar_height, :movable_contentView, :movable_button
  def initWithContentRect rect, styleMask:style, backing:buffering_type, defer:flag
    super
    self.initialize_window_setup
    self
  end
  
  def initWithContentRect rect, styleMask:style, backing:buffering_type, defer:flag, screen:screen
    super(rect, style, buffering_type, flag, screen)
    self.initialize_window_setup
    self
  end
  
  def dealloc
    NSNotificationCenter.defaultCenter.removeObserver self
  end

  def title; ""; end
  
  def setTitle title
    @window_menu_title = title
    NSApp.changeWindowsItem(self, title:@window_menu_title, filename:false) unless self.isExcludedFromWindowsMenu
  end
  
  def setRepresentedURL url; nil ;end
  
  def makeKeyAndOrderFront sender
    super(sender)
    NSApp.addWindowsItem(self, title:@window_menu_title, filename:false) unless self.isExcludedFromWindowsMenu
  end
  
  def becomeKeyWindow
    super
    @titlebar_view.needsDisplay = true
  end
  
  def resignKeyWindow
    super
    @titlebar_view.needsDisplay = true
  end
  
  def orderFront sender
    super sender
    NSApp.addWindowsItem(self, title:@window_menu_title, filename:false) unless self.isExcludedFromWindowsMenu
  end
  
  def orderOut sender
    super sender
    NSApp.removeWindowsItem self
  end
  
  # Accessors
  def titlebar_view=(new_titlebar_view)
    unless @titlebar_view and @titlebar_view == new_titlebar_view 
      @titlebar_view.removeFromSuperview if @titlebar_view.respond_to?(:removeFromSuperview)
      @titlebar_view = new_titlebar_view
      # configure the view properties and add it as subview of the theme frame
      content_view = self.contentView
      theme_frame = content_view.superview
      first_subview = theme_frame.subviews[0]
      @titlebar_view.setAutoresizingMask(NSViewMinYMargin | NSViewWidthSizable)
      self.recalculate_frame_for_titlebar_view
      theme_frame.addSubview @titlebar_view, positioned: NSWindowBelow, relativeTo:first_subview
      self.layout_trafficlights_and_content
      self.display_window_and_titlebar 
    end
  end
  
  def titlebar_view
    @titlebar_view
  end
  
  def titlebar_height=(new_titlebar_height)
    new_titlebar_height = [new_titlebar_height, self.minimun_titlebar_height].max
    unless @titlebar_height == new_titlebar_height
      @titlebar_height = new_titlebar_height
			# Cache the title bar height in order to restore the initialized titleBarHeight
			@cached_titlebar_height = new_titlebar_height 
      self.recalculate_frame_for_titlebar_view
      self.recalculate_frame_for_titlebar_view
      self.layout_trafficlights_and_content
      self.display_window_and_titlebar
    end
  end
  
  def titlebar_height
    @titlebar_height
  end
  
  def center_fullscreen_button=(flag)
    unless @center_fullscreen_button == flag
      @center_fullscreen_button = flag
      self.layout_trafficlights_and_content
    end
  end
  
  def center_trafficlights_button=(flag)
    unless @center_trafficlights_button == flag
      @center_trafficlights_button = flag
      self.layout_trafficlights_and_content
    end
  end
	
	def hide_titlebar_view_in_fullscreen=(flag)
		@hide_titleBar_inFullScreen = flag
	end

  
  protected
  def initialize_window_setup
    # calculate titlebar height
		#@hide_titleBar_inFullScreen = true
    @center_trafficlights_button = true
    @titlebar_height = self.minimun_titlebar_height
    self.setMovableByWindowBackground true
    self.initiaize_notifications
    self.create_titlebar_view
    self.layout_trafficlights_and_content
    self.setup_trafficlights_trackingarea
  end
  
  def initiaize_notifications
    nc = NSNotificationCenter.defaultCenter
    nc.addObserver self, selector:'layout_trafficlights_and_content', name:NSWindowDidResizeNotification, object:self
    nc.addObserver self, selector:'layout_trafficlights_and_content', name:NSWindowDidMoveNotification, object:self
    nc.addObserver self, selector:'display_window_and_titlebar', name:NSWindowDidResignKeyNotification, object:self
    nc.addObserver self, selector:'display_window_and_titlebar', name:NSWindowDidBecomeKeyNotification, object:self
    nc.addObserver self, selector:'setup_trafficlights_trackingarea', name:NSWindowDidBecomeKeyNotification, object:self
    nc.addObserver self, selector:'display_window_and_titlebar', name:NSApplicationDidBecomeActiveNotification, object:nil
    nc.addObserver self, selector:'display_window_and_titlebar', name:NSApplicationDidResignActiveNotification, object:nil
    nc.addObserver self, selector:'setup_trafficlights_trackingarea', name:NSWindowDidExitFullScreenNotification, object:nil
		
		nc.addObserver self, selector:'windowWillEnterFullScreen:', name:NSWindowWillEnterFullScreenNotification, object:nil
		nc.addObserver self, selector:'windowWillExitFullScreen:', name:NSWindowWillExitFullScreenNotification, object:nil
  end
  
  def layout_trafficlights_and_content
    content_view = self.contentView
    close = self.standardWindowButton NSWindowCloseButton
    minimize = self.standardWindowButton NSWindowMiniaturizeButton
    zoom = self.standardWindowButton NSWindowZoomButton
    
    # set the frame of the window buttons
    close_frame = close.frame
    minimize_frame = minimize.frame
    zoom_frame = zoom.frame
    titlebar_frame = @titlebar_view.frame
    button_origin = 0.0
    if @center_trafficlights_button
      button_origin = (NSMidY(titlebar_frame) - INMidHeight(close_frame)).round
		else
      button_origin = NSMaxY(titlebar_frame) - NSHeight(close_frame) - INBUTTON_TOP_OFFSET
    end
    close_frame.origin.y = button_origin
    minimize_frame.origin.y = button_origin
    zoom_frame.origin.y = button_origin
    
    close.frame = close_frame
    minimize.frame = minimize_frame
    zoom.frame = zoom_frame
    
    fullscreen = self.standardWindowButton NSWindowFullScreenButton
    if fullscreen
      fullscreen_frame = fullscreen.frame
      if @center_fullscreen_button
        fullscreen_frame.origin.y = (NSMidY(titlebar_frame) - INMidHeight(fullscreen_frame))
			else
        fullscreen_frame.origin.y = NSMaxY(titlebar_frame) - NSHeight(fullscreen_frame) - INBUTTON_TOP_OFFSET
      end
			# add Add some padding to the full screen button
			fullscreen_frame.origin.x = self.frame.size.width - fullscreen_frame.size.width - 10
      fullscreen.frame = fullscreen_frame
    end
    
    window_frame = self.frame
    new_frame = content_view.frame
    title_height = NSHeight(window_frame) - NSHeight(new_frame)
    extra_height = @titlebar_height - title_height
    new_frame.size.height -= extra_height
    content_view.frame = new_frame
		content_view.needsDisplay = true
  end
  
  def create_titlebar_view
    self.titlebar_view = INTitlebarView.alloc.initWithFrame NSZeroRect
  end
  
  def recalculate_frame_for_titlebar_view
    content_view = self.contentView
    theme_frame = content_view.superview
    theme_frame_rect = theme_frame.frame
		@titlebar_height ||= 22.0
		title_frame = NSMakeRect(0.0, NSMaxY(theme_frame_rect) - @titlebar_height, 
														 NSWidth(theme_frame_rect), @titlebar_height)
		@titlebar_view.frame = title_frame   
  end
  
  def minimun_titlebar_height
    min_title_height = 0.0
    if min_title_height
      frame_rect = self.frame
      content_rect = self.contentRectForFrameRect frame_rect
      min_title_height = NSHeight(frame_rect) - NSHeight(content_rect)
    end
  end
  
  def display_window_and_titlebar
    @titlebar_view.needsDisplay = true
  end
  
  def setup_trafficlights_trackingarea
	  self.contentView.superview.viewWillStartLiveResize
	  self.contentView.superview.viewDidEndLiveResize
	end
	
	def hide_titlebar_view=(hidden)
		self.titlebar_view.hidden = hidden
	end

	def windowWillEnterFullScreen notification
		if @hide_titleBar_inFullScreen
			# Recalculate the views when exiting from fullscreen
			@titlebar_height = 0.0
			self.recalculate_frame_for_titlebar_view
			self.layout_trafficlights_and_content
			self.display_window_and_titlebar
			
			self.hide_titlebar_view = true
		end
	end	

	def windowWillExitFullScreen notification
		if @hide_titleBar_inFullScreen

			# Recalculate the views when exiting from fullscreen
			@titlebar_height = @cached_titlebar_height
			self.recalculate_frame_for_titlebar_view
			self.layout_trafficlights_and_content
			self.display_window_and_titlebar
			
			self.hide_titlebar_view = false
		end
	end	
end