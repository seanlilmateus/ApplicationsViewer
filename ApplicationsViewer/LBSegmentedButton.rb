#
#  LBSegmentedButton.rb
#  QRMacRuby
#
#
module RoundedRectPartType
  MIDDLE_PART = 0
	TOP_PART    = 1
	BOTTOM_PART = 2
end

class LBSegmentedButton < NSView
  attr_accessor :target, :prev_selected_segment
  DEFAULT_CELL_HEIGHT = 35
  DEFAULT_RADIUS = 5

  DEFAULT_BORDER_COLOR = NSColor.colorWithCalibratedRed 200.0/255.0, green:200.0/255.0, blue:200.0/255.0, alpha:1.0
		
  SHADOWCOLOR    = NSColor.colorWithCalibratedRed 251.0/255.0,green:251.0/255.0,blue:251.0/255.0, alpha:1.0
  LIGHTTEXTCOLOR = NSColor.colorWithCalibratedRed 186.0/255.0,green:168.0/255.0,blue:168.0/255.0, alpha:1.0
  DARKTEXTCOLOR  = NSColor.colorWithCalibratedRed 88.0/255.0 ,green:88.0/255.0 ,blue:88.0/255.0, alpha:1.0
  HIGHLIGHTCOLOR = NSColor.colorWithCalibratedRed 247.0/255.0,green:247.0/255.0,blue:247.0/255.0, alpha:1.0
  GRADIENTCOLOR1 = NSColor.colorWithCalibratedRed 230.0/255.0,green:230.0/255.0,blue:230.0/255.0, alpha:1.0
  GRADIENTCOLOR2 = NSColor.colorWithCalibratedRed 247.0/255.0,green:247.0/255.0,blue:247.0/255.0, alpha:1.0
		
  def selected_segment=(value)
    unless value == @selected_segment
      @selected_segment = value 
      self.setNeedsDisplay true
    end
  end
    
  def number_of_cells
    @titles ? @titles.count : 0
  end
		
  def initWithFrame frameRect, titles:values, target:value
    self.initWithFrame frameRect
    @titles = values
    # @target = value
    # set default drawing info
    @border_color = DEFAULT_BORDER_COLOR
    @cell_height = DEFAULT_CELL_HEIGHT
    @radius = DEFAULT_RADIUS
    self
  end
		
  def initWithFrame frame_rect
    super
    @titles = ["CHECK","FIVE","FOUR","THREE","TWO","ONE"]
    @target = nil
    @selected_segment      = -1
    @prev_selected_segment = -1
      
    # set default drawing info
    @border_color = DEFAULT_BORDER_COLOR
    @cell_height = DEFAULT_CELL_HEIGHT
    @radius = DEFAULT_RADIUS
		  
    unless (NSHeight(frame_rect) == self.number_of_cells * (@cell_height + 2)+1)
       NSLog("The height doesn't match to the cell_height. The proper height would be #{self.number_of_cells * (@cell_height + 2) + 1 }")
    end
    self.frame = [0, 0, NSWidth(self.bounds), (@titles.size * @cell_height)+12]
    self
  end
		
  def awakeFromNib 
    self.draw_titles
  end
		
  def draw_titles
    @titles.each_with_index do |title, idx|
      label = NSTextField.alloc.initWithFrame NSMakeRect(0, 0, NSWidth(self.bounds), 15)
      center_distance = (@cell_height - 17)/2
      borders = (idx+1)*2
      label.bordered = false
      label.drawsBackground = false
      label.selectable = false
      label.editable = false
      label.alignment = NSCenterTextAlignment
      label.textColor = DARKTEXTCOLOR
		    
      label.stringValue = title
      label.frameOrigin = NSMakePoint(0, borders + center_distance + idx * @cell_height)
      self.addSubview label
    end
  end
    
  def draw_cell type, rect:rect, index:idx
    context = NSGraphicsContext.currentContext.graphicsPort
    
    maxX = NSMaxX(rect)
    minX = NSMinX(rect)
    minY = NSMinY(rect)
    
    if (type == RoundedRectPartType::BOTTOM_PART)
      # Bottom shadow
      bottom_shadow = CGPathCreateMutable()
      
      CGPathMoveToPoint(bottom_shadow, nil, minX, minY+@radius)
      
      # 90degrees curve (left bottom)
      CGPathAddQuadCurveToPoint(bottom_shadow, nil, minX, minY, minX+@radius , minY)
      CGPathAddLineToPoint(bottom_shadow, nil, maxX - @radius, minY)
      
      # 90degrees curve (right bottom)
      CGPathAddQuadCurveToPoint(bottom_shadow, nil, maxX, minY, maxX, @radius)
      
      SHADOWCOLOR.setStroke
      CGContextAddPath(context, bottom_shadow)
      CGContextDrawPath(context, KCGPathStroke)
						
      # Box
      minY+=1
      box = CGPathCreateMutable();
						
      CGPathMoveToPoint(box, nil, minX, @cell_height+3)
      CGPathAddLineToPoint(box, nil, minX, minY+@radius)
      
      # 90degrees curve (left bottom)
      CGPathAddQuadCurveToPoint(box, nil, minX, minY, minX+@radius , minY)
      CGPathAddLineToPoint(box, nil, maxX-@radius, minY)
      
      # 90degrees curve (right bottom)
      CGPathAddQuadCurveToPoint(box, nil, maxX, minY, maxX, minY+@radius) 
      CGPathAddLineToPoint(box, nil, maxX, @cell_height+3)
        
      CGContextAddPath(context, box)
      
      @border_color.setStroke
        
      if (@selected_segment == idx)
        HIGHLIGHTCOLOR.setFill
        CGContextDrawPath(context, KCGPathFillStroke)
      else 
        CGContextDrawPath(context, KCGPathStroke)
      end
      
      CGPathRelease(box)
      CGPathRelease(bottom_shadow);
      
    elsif (type == RoundedRectPartType::MIDDLE_PART)
      # Box
      box = CGPathCreateMutable()
      
      CGPathMoveToPoint(box, nil, minX, minY+ 3 + @cell_height)
      CGPathAddLineToPoint(box, nil, minX, minY + 1)
      CGPathAddLineToPoint(box, nil, maxX, minY + 1)
      CGPathAddLineToPoint(box, nil, maxX, minY + @cell_height+3)
      
      CGContextAddPath(context, box)
      
      @border_color.setStroke
      
      if (@selected_segment == idx)
        HIGHLIGHTCOLOR.setFill
        CGContextDrawPath(context, KCGPathFillStroke)
      else
        CGContextDrawPath(context, KCGPathStroke)
      end
      
      # Seperator shadow
      shadow = CGPathCreateMutable()
      
      CGPathMoveToPoint(shadow, nil, minX+1, minY)
      CGPathAddLineToPoint(shadow, nil, maxX-1, minY)
      
      (@selected_segment+1==idx) ? 	HIGHLIGHTCOLOR.setStroke : SHADOWCOLOR.setStroke
      CGContextAddPath(context, shadow)
      CGContextDrawPath(context, KCGPathStroke)
      
      CGPathRelease(box)
      CGPathRelease(shadow)
    else
      # Box
      box = CGPathCreateMutable()
      
      CGPathMoveToPoint(box, nil, minX, minY + 1)
      CGPathAddLineToPoint(box, nil, maxX, minY + 1)
						
      CGPathAddLineToPoint(box, nil, maxX, minY + @cell_height - @radius + 2)
      CGPathAddQuadCurveToPoint(box, nil, maxX, minY+@cell_height+2, maxX-@radius, minY + @cell_height+2)
						
      CGPathAddLineToPoint(box, nil, minX + @radius, minY+@cell_height+2)
      CGPathAddQuadCurveToPoint(box, nil, minX, minY + @cell_height+2, minX, minY+@cell_height-@radius+2)
						
      CGPathAddLineToPoint(box, nil, minX, minY+1)
      CGPathCloseSubpath(box)
      
      CGContextAddPath(context, box)
      
      @border_color.setStroke
      if (@selected_segment == idx)
        HIGHLIGHTCOLOR.setFill
        CGContextDrawPath(context, KCGPathFillStroke)
      else
        CGContextDrawPath(context, KCGPathStroke)
      end
      
      # Seperator shadow
      shadow = CGPathCreateMutable()
      
      CGPathMoveToPoint(shadow, nil, minX + 1, minY)
      CGPathAddLineToPoint(shadow, nil, maxX - 1, minY)
      
      (@selected_segment + 1 == idx) ? HIGHLIGHTCOLOR.setStroke : SHADOWCOLOR.setStroke 
      
      CGContextAddPath(context, shadow)
      CGContextDrawPath(context, KCGPathStroke)
      
      CGPathRelease(box)
      CGPathRelease(shadow)
    end
  end
		
  def draw_background
    clip_path = NSBezierPath.bezierPathWithRoundedRect self.bounds, xRadius:@radius, yRadius:@radius
    gradient = NSGradient.alloc.initWithStartingColor GRADIENTCOLOR1, endingColor:GRADIENTCOLOR2
    gradient.drawInBezierPath clip_path, angle:90.0
  end
		
  def drawRect dirtyRect
    self.draw_background
    self.number_of_cells.times do |idx|
      # If it is the bottom
      if idx.zero?
        draw_cell RoundedRectPartType::BOTTOM_PART, rect:NSInsetRect([0, 0, NSWidth(self.bounds), @cell_height+2], 0.5, 0.5), index:idx
      elsif (idx == self.number_of_cells)
        draw_cell RoundedRectPartType::TOP_PART, rect:NSInsetRect([0, (@cell_height+2) * idx, NSWidth(self.bounds), @cell_height+2], 0.5, 0.5), index:idx
      else 
        draw_cell RoundedRectPartType::MIDDLE_PART, rect:NSInsetRect([0, (@cell_height+2) * idx, NSWidth(self.bounds), @cell_height+2], 0.5, 0.5), index:idx
      end
    end
  end
		
  #pragma mark -
  #pragma mark Mouse Interaction
  def mouseDragged the_event
    location_in_window = the_event.locationInWindow
    location = self.convertPoint location_in_window, fromView:self.window.contentView
    @selected_segment = (CGRectContainsPoint(self.bounds, NSPointToCGPoint(location))) ? @prev_selected_segment : -1
  end
		
  def mouseDown the_event 
    super
    location_in_window = the_event.locationInWindow
    location = self.convertPoint(location_in_window, fromView: self.window.contentView)
    self.number_of_cells.times do |idx|
      if (CGRectContainsPoint(CGRectMake(0, idx * (@cell_height + 3), NSWidth(self.bounds), @cell_height), NSPointToCGPoint(location)))
        @selected_segment = idx
        @prev_selected_segment = idx
        self.needsDisplay = true
      end
    end
  end
		
  def mouseUp the_event
    super
    location_in_window = the_event.locationInWindow
    location = self.convertPoint location_in_window, fromView:self.window.contentView
    
    if (CGRectContainsPoint(self.bounds, NSPointToCGPoint(location)))
      selector = "button_clicked:"
      self.send(selector, @selected_segment) if (self.respond_to? selector)        
    end
    self.selected_segment  = -1
    @prev_selected_segment = -1
  end

  def button_clicked object
    warn "button nr. #{object} Clicked "
  end
end
