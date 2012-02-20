#
#  Item.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 13.11.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
class Item
  attr_accessor :itemPath, :itemDisplayName, :itemKind, :itemIcon
  def initialize pathName
    @itemPath = "/Applications".stringByAppendingPathComponent pathName
  end
  def itemDisplayName
    @itemDisplayName ||= NSFileManager.defaultManager.displayNameAtPath @itemPath
  end
  
  def itemKind
    @itemKind ||= @itemPath.hasSuffix("app") ? "Application" : "Folder"
  end
  
  def itemIcon
    @itemIcon ||= NSWorkspace.sharedWorkspace.iconForFile @itemPath
  end
    
  def version
    version = ""
    if is_app? 
        app_bundle = NSBundle.bundleWithPath(@itemPath)
    	app_info = app_bundle.infoDictionary
    	version = "Version %s" % app_info['CFBundleShortVersionString'] #CFBundleGetInfoString 
    end
    version
  end
	
  protected
  def is_app?
    self.itemKind == "Application"
  end
end


