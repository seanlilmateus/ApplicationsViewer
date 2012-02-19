#
#  MASWindowController.rb
#  QRMacRuby
#
#  Created by Mateus Armando on 10.11.11.
#  Copyright 2011 Sean Coorp. INC. All rights reserved.
#
class MASWindowController < NSWindowController
  def initWithWindowNibName nib_window
		super("SampleWindow")
		self.window.title_bar_height = 46.0
		self.showWindow nil
		self
  end
	
	def windowDidLoad 
		super
	end
end
