#
#  ANKnobAnimation.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 11.11.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
class ANKnobAnimation < NSAnimation
  attr_accessor :start, :range, :delegate
		
  def initWithStart from, to:to
    animation = self.class.new
    animation.start = from
    animation.range = to - from
    animation
  end
		
  def setCurrentProgress progress
    x = @start + progress * @range
    @delegate.send 'setPosition', x if @delegate.respond_to? 'setPosition' 
    super(progress)
  end
		
  def setDelegate new_delegate
    @delegate = new_delegate 
  end
end

