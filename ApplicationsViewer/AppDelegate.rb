#
#  AppDelegate.rb
#  ApplicationsViewer
#
#  Created by Mateus Armando on 19.02.12.
#  Copyright 2012 Sean Coorp. INC. All rights reserved.
#

class AppDelegate
	
  attr_accessor :window, :tool_view
  attr_accessor :popover, :tableView
  attr_accessor :applications, :big_icon_view, :app_name
  attr_accessor :app_version, :item_kind
  attr_reader :selected_index
  def applicationDidFinishLaunching(a_notification)
    # Insert code here to initialize your application
    @dock = NSApplication.sharedApplication.dockTile
    self.toggleBadgeLabel(nil)
		
    NSTimer.scheduledTimerWithTimeInterval 5.0, repeats:true, withBlock:-> timer { bounceDockIcon(timer) }
        
    registerNSWindowDidResizeWithBlocks
    if Object.const_defined?(:NSWindowCollectionBehaviorFullScreenPrimary)
      NSNotificationCenter.defaultCenter.addObserver(self, selector: 'will_enter_fullscreen:', name: NSWindowWillEnterFullScreenNotification, object: window)
      NSNotificationCenter.defaultCenter.addObserver(self,  selector: 'will_exit_fullscreen:', name: NSWindowWillExitFullScreenNotification, object: window)
    end
  end
    
  def awakeFromNib
    @window.titlebar_height = 40.0
		@window.center_fullscreen_button = true
		@window.hide_titlebar_view_in_fullscreen = true
    @window.titlebar_view.addSubview @tool_view
  end
    
  def valueForUndefinedKey key
    NSLog("ALERT")
    items.valueForKey key
  end
    
  def items
    return @items if @items 
    is_not_hidden = proc  { |file| Item.new(file) unless file.hasPrefix(".") }
    manager = NSFileManager.defaultManager
    contents = manager.contentsOfDirectoryAtPath "/Applications", error:nil
    @items = contents.map(&is_not_hidden).compact!
  end
    
  def registerNSWindowDidResizeWithBlocks
    win_observer = NSNotificationCenter.defaultCenter.addObserverForName NSWindowDidResizeNotification, object:@window, queue:NSOperationQueue.mainQueue,usingBlock:-> aNotification {
      win = aNotification.object
      puts "win dance"
    }
  end
    
    
  def bounceDockIcon aTimer
    NSApp.requestUserAttention NSCriticalRequest
  end
    
    
  def popoverDidClose(aNotification)
    @actualBotton[NSOffState]
    @actualBotton = nil
  end
    
  def toggleBadgeLabel from
    if (!@dock.badgeLabel || @dock.badgeLabel == "")
      @dock.badgeLabel = "1"
      NSApp.requestUserAttention NSCriticalRequest
    else
      @dock.badgeLabel = "2"
    end
  end
    
  def will_enter_fullscreen(notification)
  end
    
  def will_exit_fullscreen(notification)
  end
    
  def setSelected_index(index)
    selected_app = self.items[index.first]
    @big_icon_view.image = selected_app.itemIcon
    @app_name.stringValue = selected_app.itemDisplayName
    @item_kind.stringValue = selected_app.itemKind
    @app_version.stringValue = selected_app.version
    @selected_index = index
  end
    
  # actions
  def show_popover(sender)
    @actualBotton = proc { |new_state| sender.state = new_state }
    @popover.animates = true
    @popover.delegate = self
    @popover.showRelativeToRect sender.bounds, ofView:sender, preferredEdge:NSMaxYEdge
  end
    
  def show_window(sender)
    @window.makeKeyAndOrderFront(nil)
  end
    
  def items_size_clicked(sender)
    @isLargeSizeRequested = (sender.state == NSOffState)
        
    @tableView.enumerateAvailableRowViewsUsingBlock ->  rowView, row {
      cell_view = @tableView.viewAtColumn 0, row:row, makeIfNecessary:false
      cell_view.layoutViewsForLargeSize @isLargeSizeRequested, animated:true
    }
    changed_range = NSMakeRange(0, @tableView.numberOfRows)
    changed_indexes = NSIndexSet.indexSetWithIndexesInRange changed_range
    tableView.noteHeightOfRowsWithIndexesChanged changed_indexes
  end
end
