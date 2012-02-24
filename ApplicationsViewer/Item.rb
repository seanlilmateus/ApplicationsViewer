#
#  Item.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 13.11.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
class Item

  def initialize path_name
    @item_path = "/Applications".stringByAppendingPathComponent path_name
  end
    
  def item_display_name
    @item_display_name ||= NSFileManager.defaultManager.displayNameAtPath @item_path
  end
  
  def item_kind
    @item_kind ||= @item_path.hasSuffix("app") ? "Application" : "Folder"
  end
  
  def item_icon
    @item_icon ||= NSWorkspace.sharedWorkspace.iconForFile @item_path
  end
    
  def version
    if is_app? 
      app_bundle = NSBundle.bundleWithPath(@item_path)
    	"Version %{CFBundleShortVersionString}" % app_bundle.infoDictionary
  	else ""
    end
  end
	
  protected
  def is_app?
    self.item_kind == "Application"
  end
end


