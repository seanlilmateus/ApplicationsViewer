#
#  erweiterungen.rb
#  QRMacRuby
#
#


class  NSGraphicsContext
  def self.transactionUsingBlock &block
    self.saveGraphicsState
    block[self.currentContext]
    self.restoreGraphicsState
  end
end

class NSAffineTransform
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

class NSTimer
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

class NSIndexSet
  def each 
    return self.objectEnumerator unless block_given?
    self.enumerateIndexesUsingBlock -> idx, stop { yield(idx) }
  end
  include Enumerable
end

 