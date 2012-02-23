#
#  erweiterungen.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 19.02.12.
#  Copyright 2012 Sean Coorp. INC. All rights reserved.
#

module Kernel
  private
  def NSAssert condition, notiz=nil
    (warn notiz; abort) unless condition
  end
  def assert(condition, message="Assertion on %s failed")
    raise Exception, (message % caller) , caller unless condition
  end
  
  def NSLocalizedString(key, value, table=nil)
    #value = key if value.nil?
    #NSBundle.mainBundle.localizedStringForKey(key, value:value, table:table)
    key
  end
end

module MateusErweiterung
  class ::SBElementArray
    def [](value)
      self.objectWithName(value)
    end
  end

  class ::NSGraphicsContext
    def self.transactionUsingBlock &block
      self.saveGraphicsState
      block[self.currentContext]
      self.restoreGraphicsState
    end
  end

  class ::NSAffineTransform
    def self.withDegreesRotated degreesRotated, draw:drawBlock
      NSGraphicsContext.transactionUsingBlock -> currentContext do
        t = NSAffineTransform.new
        t.rotateByDegrees degreesRotated
        t.concat
        t = nil
        drawBlock[]
      end
    end
  end
  ### OBSERVE WITH BLOCK
  class ::Pointer 
    def ==(other)
      return self.cast!("*")[0] == other.cast!("*")[0] if other.is_a? Pointer
      nil
    end
  end
  #blocks with Delegate DSL
  class ::Proc
    def delegate delegate, method
      if self.arity == 1
        self[delegate]
      else   
        implementation delegate, method  
      end
    end
    private
    def implementation delegate, method
      mod = Module.new
      mod.send :define_method, method.to_sym, self
      delegate.extend(mod)
    end
    alias_method :setDelegate, :delegate
  end
		
  class ::NSTimer
    def self.scheduledTimerWithTimeInterval inTimeInterval, repeats:inRepeats, withBlock:inBlock
      self.scheduledTimerWithTimeInterval inTimeInterval, target: self, selector: :'executeBlockFromTimer:',userInfo: inBlock, repeats: inRepeats
    end
    def self.timerWithTimeInterval inTimeInterval, repeats: inRepeats, withBlock:inBlock
      self.timerWithTimeInterval inTimeInterval, target: self, selector: :'executeBlockFromTimer:', userInfo: inBlock, repeats: inRepeats
    end
    def self.executeBlockFromTimer aTimer
      blck = aTimer.userInfo
      time = aTimer.timeInterval
      blck[time] if blck
    end
  end
  class ::NSString
    def language
      CFStringTokenizerCopyBestStringLanguage(self, CFRangeMake(0, self.size))
    end
    def escapeJSON
      self.gsub("\ ", "+").stringByReplacingPercentEscapesUsingEncoding NSASCIIStringEncoding
    end
  end

  class ::NSEnumerator
    def enumerateObjectsUsingBlock block
      return if (!block)
      object = nil
      stop =  Pointer.new(:boolean); stop.assign(false)
      block[object, stop] while (!stop[0] && (object = self.nextObject))
    end
  end

  class ::Array
    #return self.objectEnumerator unless block_given?
    def iterateFrom beginIDX, upTo: endIDX, usingBlock:block
      return self.objectEnumerator unless block.is_a? Proc
      return if beginIDX > endIDX || !block
      beginIDX.upto(endIDX) { |idx|  block[self[idx]] }
    end

    def parallel_map(&block)
      return self.to_enum unless block_given?
      result = []
      group = Dispatch::Group.new
      result_queue = Dispatch::Queue.new('access-queue.#{result.object_id}')
      self.enumerateObjectsWithOptions NSEnumerationConcurrent, usingBlock:-> obj, idx, stop do 
        Dispatch::Queue.concurrent.async(group){result_queue.async(group) { result[idx] = block[obj] }}
      end
      # Wait for all the blocks to finish.
      group.wait
      result
    end
  end

  class ::Hash
    def parallel_map(&block)
      return self.to_enum unless block_given?
      result = {}
      group = Dispatch::Group.new
      result_queue = Dispatch::Queue.new('access-queue.#{result.object_id}')
      self.enumerateKeysAndObjectsWithOptions NSEnumerationConcurrent, usingBlock: -> key, obj, stop do
        Dispatch::Queue.concurrent.async(group){result_queue.async(group) { result[key] = block[obj] }}
      end
      group.wait
      result
    end
  end

  class ::NSIndexSet
    def each 
      return self.objectEnumerator unless block_given?
      self.enumerateIndexesUsingBlock -> idx, stop { yield(idx) }
    end
    def match
      return self.objectEnumerator unless block_given?
      self.indexPassingTest -> idx, stop do 
        return true if (yield(obj)) 
        return false 
      end
    end
    def select
      return self.objectEnumerator unless block_given?
      list = self.indexesPassingTest -> idx, stop { return yield(idx) }
      return nil if (!list.count)
      list
    end
    def reject
      return self.objectEnumerator unless block_given?
      list = self.indexesPassingTest -> idx, stop { return !yield(idx) }
      return nil if (!list.count)
      list
    end
  end

  class ::NSSet
    def each
      return self.objectEnumerator unless block_given?
      self.allObjects.each{ |obj| yield obj }
      self
    end
    def match
      return self.objectEnumerator unless block_given?
      self.objectsPassingTest -> obj, stop do 
        return true if (yield obj) 
        return false 
      end
    end
    # refactory
    def select 
      return self.objectEnumerator unless block_given?
      list = self.objectsPassingTest -> obj , stop {yield obj}
      return list #unless list.count
    end
    def map
      return self.objectEnumerator unless block_given?
      result = NSMutableSet.setWithCapacity self.count
      self.enumerateObjectsUsingBlock -> obj, stop do
        value = yield(obj)
        value = NSNull.null unless value
        result.addObject value
      end
      result
    end
    # NSMutableSet only
    def map!
      return self.objectEnumerator unless block_given?
      result = []
      self.enumerateObjectsUsingBlock -> obj, stop do
        value = yield(obj)
        value = NSNull.null if (!value)
        result.addObject value
      end
      self.removeAllObjects
      self.addObjectsFromArray result
    end
    def reduce initial
      return self.objectEnumerator unless block_given?
      result = initial
      self.enumerateObjectsUsingBlock -> obj, stop { result = yield(result, obj) }
      result
    end
    def reduce initial, withBlock:block
      #return self.objectEnumerator unless block_given?
      result = initial
      self.enumerateObjectsUsingBlock -> obj, stop { result = block.call(result, obj) }
      result
    end
  end

  class ::NSIndexSet
    def each
      i = firstIndex
      while i != NSNotFound
        yield i
        i = indexGreaterThanIndex(i)
      end
    end
    include Enumerable
  end

  class ::NSObject
    def performAfterDelay delay, block:blck
      self.performSelector :'runBlock:', withObject:blck, afterDelay:delay 
    end
    def performOnMainThreadWait wait, block:blck
      self.performSelectorOnMainThread :'runBlock:', withObject:blck, waitUntilDone:wait
    end
    def runBlock blck
      blck.call
    end
    def isLessThan value
      self < value
    end
    def doesContain value
      self.include? value
    end
    def isCaseInsensitiveLike aString
      self.downcase == aString.downcase
    end
    def isEqualTo value
      self == value
    end
    def isGreaterThan value
      self > value
    end
    def isGreaterThanOrEqualTo value
      self >= value
    end
    def isLessThan value
      self < value
    end
    def isLessThanOrEqualTo value
      self <= value
    end
    def isLike value
      self == value
    end
    def isNotEqualTo value
      self != value
    end
  end

  class ErrorDelegate
    attr_reader :pointer
    alias_method :to_pointer, :pointer
    def initialize
      @pointer = Pointer.new(:object)
    end
    def respond_to?(sym)
      @pointer[0].respond_to?(sym)
    end
    def method_missing method_name, *args
      @pointer[0].send(method_name, *args) if @pointer[0].respondsToSelector method_name    
    end
  end

  # NSTextView Safari Like
  class MTextField < NSTextField
    def initWithCoder aCoder
      textField = super(aCoder)
      if textField
        textField.setDrawsBackground false
        # doesn't work well for mini size - text needs to be adjusted up
        if textField.cell.controlSize == NSMiniControlSize
          textField.setFont NSFont.systemFontOfSize(9.4)
        elsif textField.cell.controlSize == NSSmallControlSize
          textField.setFont NSFont.systemFontOfSize(9.4)
        else
          textField.setFont NSFont.systemFontOfSize(11.88)
        end
      end
      textField
    end
    def acceptsFirstResponder
      false
    end
    def drawRect dirtyRect
      # bottom white highlight
      hightlight_frame = NSMakeRect(0.0, 10.0, self.bounds.size.width, self.bounds.size.height-10.0)
      NSColor.colorWithCalibratedWhite(1.0, alpha:0.394).set
      NSBezierPath.bezierPathWithRoundedRect(hightlight_frame, xRadius:3.6,yRadius:3.6).fill
      # black outline
      black_outline_frame = NSMakeRect(0.0, 0.0, self.bounds.size.width, self.bounds.size.height-1.0)
				
      if NSApp.isActive
        start_color = NSColor.colorWithCalibratedWhite 0.24, alpha:1.0
        end_color = NSColor.colorWithCalibratedWhite 0.374, alpha:1.0
        gradient = NSGradient.alloc.initWithStartingColor start_color, endingColor:end_color
      else
        start_color = NSColor.colorWithCalibratedWhite 0.55, alpha:1.0
        end_color = NSColor.colorWithCalibratedWhite 0.558, alpha:1.0
        gradient = NSGradient.alloc.initWithStartingColor start_color, endingColor:end_color
      end

      gradient.drawInBezierPath NSBezierPath.bezierPathWithRoundedRect(black_outline_frame, xRadius:3.6, yRadius:3.6),angle:90.0
      # top inner shadow
      shadow_frame = NSMakeRect(1, 1, self.bounds.size.width - 2.0, 10.0)
      NSColor.colorWithCalibratedWhite(0.88, alpha:1.0).set
      NSBezierPath.bezierPathWithRoundedRect(shadow_frame, xRadius:2.9, yRadius:3.9).fill
				
      # main white area
      white_frame = NSMakeRect(1, 2, self.bounds.size.width-2.0, self.bounds.size.height-4.0)
      NSColor.whiteColor.set
      NSBezierPath.bezierPathWithRoundedRect(white_frame,xRadius:2.6,yRadius:2.6).fill
      # draw the keyboard focus ring if we're the first responder and the application is active
      if (self.window.firstResponder == self.currentEditor && NSApp.isActive)
        NSGraphicsContext.saveGraphicsState
        NSSetFocusRingStyle(NSFocusRingOnly)
        NSBezierPath.bezierPathWithRoundedRect(black_outline_frame, xRadius:3.6, yRadius:3.6).fill 
        NSGraphicsContext.restoreGraphicsState
      else
        # I don't like that the point to draw at is hard-coded, but it works for now
        self.attributedStringValue.drawInRect NSMakeRect(4.0, 3.0, self.bounds.size.width-8.0,self.bounds.size.width-6.0)
      end
    end
  end
  class ::NSDate #DistanceOfTimeInWords  & Blocks
    SECONDS_PER_MINUTE = 60.0
    SECONDS_PER_HOUR   = 3600.0
    SECONDS_PER_DAY    = 86400.0
    SECONDS_PER_MONTH  = 2592000.0
    SECONDS_PER_YEAR   = 31536000.0
    SINGULAR = 1
    
    Ago      = NSLocalizedString("ago", "Denotes past dates")
    FromNow  = NSLocalizedString("from now", "Denotes future dates")
    LessThan = NSLocalizedString("less than", "Indicates a less-than number")
    About    = NSLocalizedString("about", "Indicates an approximate number")
    Over     = NSLocalizedString("over", "Indicates an exceeding number")
    Almost   = NSLocalizedString("almost", "Indicates an approaching number")
    Second   = NSLocalizedString("second", "One second in time")
    Seconds  = NSLocalizedString("seconds", "More than one second in time")
    Minute   = NSLocalizedString("minute", "One minute in time")
    Minutes  = NSLocalizedString("minutes", "More than one minute in time")
    Hour     = NSLocalizedString("hour", "One hour in time")
    Hours    = NSLocalizedString("hours", "More than one hour in time")
    Day      = NSLocalizedString("day", "One day in time")
    Days     = NSLocalizedString("days", "More than one day in time")
    Month    = NSLocalizedString("month", "One month in time")
    Months   = NSLocalizedString("months", "More than one month in time")
    Year     = NSLocalizedString("year", "One year in time")
    Years    = NSLocalizedString("years", "More than one year in time")

    def formatWithString format
      formatter = NSDateFormater.alloc.init
      formatter.dateFormat = format
      formatter.stringFromDate(self)
    end
    def formatWithStyle style
      formatter = NSDateFormatter.alloc.init
      formatter.setDateStyle style
      formatter.stringFromDate(self)
    end
    def distanceOfTimeInWords
      self.distanceOfTimeInWords NSDate.date
    end
    def distanceOfTimeInWords date    
      since = self.timeIntervalSinceDate date
      direction = since <= 0.0 ? Ago : FromNow
      since = since.abs
		
      seconds   = since
      minutes   = (since / SECONDS_PER_MINUTE).round
      hours     = (since / SECONDS_PER_HOUR).round
      days      = (since / SECONDS_PER_DAY).round
      months    = (since / SECONDS_PER_MONTH).round
      years     = (since / SECONDS_PER_YEAR).floor
      offset    = (years / 4.0 * 1440.0).floor.round
      remainder = (minutes - offset) % 525600
      modifier = " "
      case minutes
      when  0..1 then measure = Seconds
        case (seconds)
        when 0..4
          number = 5
          modifier = LessThan
        when 5..9
          number = 10
          modifier = LessThan
        when 10..19
          number = 20
          modifier = LessThan
        when 20..39
          number = 30
          modifier = About
        when 40..59
          number = 1
          measure = Minute
          modifier = LessThan
        else
          number = 1
          measure = Minute
          modifier = About
        end
      when 2..44
        number = minutes
        measure = Minutes
      when 45..89
        number = 1
        measure = Hour
        modifier = About
      when 90..1439
        number = hours
        measure = Hours
        modifier = About
      when 1440..2529
        number = 1
        measure = Day
      when 2530..43199
        number = days
        measure = Days
      when 43200..86399
        number = 1
        measure = Month
        modifier = About
      when 86400..525599
        number = months
        measure = Months
      else
        number = years
        measure = number == 1 ? Year : Years
        if (remainder < 131400) 
          modifier = About
        elsif (remainder < 394200)
          modifier = Over
        else
          number+=1
          measure = Years
          modifier = Almost
        end
      end
      modifier = modifier + " " if (modifier.length > 0)
      "#{modifier}#{number} #{measure} #{direction}"
    end
    # Blocks
    def enumerateByDayToDate endDate, step:step, usingBlock:block
      return nil unless block.is_a? Proc
      secondsPerDay = 86400.0
      self.enumerateByTimeInterval secondsPerDay * step, endDate:endDate, usingBlock:block
    end
    def enumerateByTimeInterval interval, endDate:endDate, usingBlock:block
      return if ((interval == 0.0 || !block) || (interval > 0.0 && self.compare(endDate) == NSOrderedDescending) || (interval < 0.0 && self.compare(endDate) == NSOrderedAscending))
		
      currentDate = self
      begin
        block[currentDate]
        currentDate = currentDate.dateByAddingTimeInterval interval
      end while ((interval > 0.0 && currentDate.compare(endDate) != NSOrderedDescending) || (interval < 0.0 && currentDate.compare(endDate) != NSOrderedAscending))
    end
  end
end

