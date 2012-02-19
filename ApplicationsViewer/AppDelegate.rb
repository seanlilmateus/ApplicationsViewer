#
#  AppDelegate.rb
#  ApplicationsViewer
#
#  Created by Mateus Armando on 19.02.12.
#  Copyright 2012 Sean Coorp. INC. All rights reserved.
#

class AppDelegate
	
	attr_accessor :window, :window_controllers, :my_view
	attr_accessor :popover, :tableView, :selected_index
	attr_accessor :applications, :big_icon_view, :app_name
	attr_accessor :app_version, :item_kind

	def applicationDidFinishLaunching(a_notification)
		# Insert code here to initialize your application
		@window_controllers =  []
		@dock = NSApplication.sharedApplication.dockTile
		self.toggleBadgeLabel(nil)
		
		NSTimer.scheduledTimerWithTimeInterval 5.0, repeats:true, withBlock:-> timer do 
			bounceDockIcon(timer)
		end
		
		registerNSWindowDidResizeWithBlocks
		if Object.const_defined?(:NSWindowCollectionBehaviorFullScreenPrimary)
	  	NSNotificationCenter.defaultCenter.addObserver( self, 
											selector: 'will_enter_fullscreen:',
												name: NSWindowWillEnterFullScreenNotification,
											  object: window)
	  
	  	NSNotificationCenter.defaultCenter.addObserver( self, 
											selector: 'will_exit_fullscreen:',
												name: NSWindowWillExitFullScreenNotification,
											  object: window)
	  end
	 	
	end
	
	def awakeFromNib
		@window.title_bar_height = 46.0
		@window.titleBarView.addSubview @my_view
	end
	
	def valueForUndefinedKey key
		NSLog("ALERT")
		items.valueForKey key
	end
		
	def items
		return @items if @items 
		isNotHidden = -> file { Item.new(file) unless file.hasPrefix(".") }
		manager = NSFileManager.defaultManager
		contents = manager.contentsOfDirectoryAtPath "/Applications", error:nil
		@items = contents.map(&isNotHidden).compact!
	end
		
	def registerNSWindowDidResizeWithBlocks
		winObserver = NSNotificationCenter.defaultCenter.addObserverForName NSWindowDidResizeNotification, 
		object:@window, queue:NSOperationQueue.mainQueue,usingBlock:-> aNotification do
						win = aNotification.object
						puts "win dance"
    end
  end
		
  def windowDidResize aNotification
  end
		
  def aRect
    titleSize = NSMakeSize(120.0,20.0)
    position_x  = (@window.titleBarView.frame.size.width/2)-(titleSize.width/2)
    position_y  = (@window.titleBarView.frame.size.height/2)-(titleSize.height/2)
    size_width  = titleSize.width
    size_height = titleSize.height
		[position_x, position_y, size_width, size_height]																						
  end
		
  def setTitle 
    titleView = NSTextField.alloc.initWithFrame aRect
    titleView.setBackgroundColor NSColor.clearColor
    titleView.setBezeled NSNoBorder # remove the bezeled border
    titleView.setEditable false
    attrStr = NSMutableAttributedString.alloc.initWithString "Window Title"
    mutParaStyle = NSMutableParagraphStyle.alloc.init
    mutParaStyle.setAlignment NSCenterTextAlignment
    
    dict = {NSParagraphStyleAttributeName => mutParaStyle}
    attrStr.addAttributes  dict, range:NSMakeRange(0, attrStr.length)
    
    #titleView.setStringValue "Window Title"
    
    titleView.setAttributedStringValue attrStr
    
    titleView.setTextColor NSColor.grayColor
    
    @window.titleBarView.addSubview titleView
  end
		
  def createWindowController sender
    controller = MASWindowController.alloc.initWithWindowNibName(nil)
    #controller.showWindow nil
    @window_controllers << controller
    self.toggleBadgeLabel nil
    NSTimer.scheduledTimerWithTimeInterval 5.0, target:self, selector:'bounceDockIcon:', userInfo:nil, repeats:false
  end
		
  def bounceDockIcon aTimer
    NSApp.requestUserAttention NSCriticalRequest
  end
		
  def showPopover sender
    tableClicked
    @actualBotton = -> state {sender.setState state }
    @popover.animates = true
    @popover.delegate = self
    @popover.showRelativeToRect sender.bounds, ofView:sender, preferredEdge:NSMaxYEdge
  end
		
  def popoverDidClose aNotification
    @actualBotton[NSOffState]
    @actualBotton = nil
  end
		
  def toggleBadgeLabel from_sender
    if (!@dock.badgeLabel || @dock.badgeLabel == "")
      @dock.setBadgeLabel("#{@window_controllers.count}")
      NSApp.requestUserAttention NSCriticalRequest
    else
      @dock.setBadgeLabel ""
    end
  end
		
  def tableClicked;end
    
  
	def itemsSizeClicked sender
		@isLargeSizeRequested = (sender.state == NSOnState)
		@tableView.enumerateAvailableRowViewsUsingBlock ->  rowView, row do
			cell_view = @tableView.viewAtColumn 0, row:row, makeIfNecessary:false
			cell_view.layoutViewsForLargeSize @isLargeSizeRequested, animated:true
		end
		changed_range = NSMakeRange(0, @tableView.numberOfRows)
		changed_indexes = NSIndexSet.indexSetWithIndexesInRange changed_range
		@tableView.noteHeightOfRowsWithIndexesChanged changed_indexes

	end
	
	def will_enter_fullscreen(notification)
  end
  
	def will_exit_fullscreen(notification)
  end
    
  def setSelected_index index
    selected_app = self.items[index.first]
    @big_icon_view.image = selected_app.itemIcon
    @app_name.stringValue = selected_app.itemDisplayName
		@item_kind.stringValue = selected_app.itemKind
		@app_version.stringValue = selected_app.version
    @selected_index = index
  end
	
end

