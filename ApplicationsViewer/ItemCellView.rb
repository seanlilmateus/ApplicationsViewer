#
#  ItemCellView.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 13.11.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#

class ItemCellView < NSTableCellView
  attr_accessor :detailTextField, :large_size_request, :imageView, :textField
	
  def setBackgroundStyle backgroundStyle
    textColor = (backgroundStyle == NSBackgroundStyleDark) ? NSColor.windowBackgroundColor : NSColor.controlShadowColor
    @detailTextField.textColor = textColor
    super
  end
  
  def layoutViewsForLargeSize large_size, animated:animated
    large_size_request = large_size
    detail_alpha = large_size ? 8.0 : 0.0
    icon_size = large_size ? 32.0 : 16.0
    icon_frame = NSMakeRect(2.0, 2.0, icon_size, icon_size)
		
    name_left = icon_frame.origin.x + icon_frame.size.width + 10.0
    name_bottom = icon_frame.origin.y + icon_frame.size.height - (large_size ? 14.0 : 18.0)
		
    name_width = self.bounds.size.width - name_left - 2.0
    name_height = 16.0
    name_frame = NSMakeRect(name_left, name_bottom, name_width, name_height)
    if animated
      @detailTextField.animator.alphaValue = detail_alpha
      @imageView.animator.frame = icon_frame
      @textField.animator.frame = name_frame
    else
      @detailTextField.alphaValue = detail_alpha
      @imageView.frame = icon_frame
      @textField.frame = name_frame
    end 
  end
end

