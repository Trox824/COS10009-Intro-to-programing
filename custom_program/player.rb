
class Player 
    attr_accessor :x, :y, :angle, :image, :velocity_x, :velocity_y, :radius, :window, :direction, :status
    def initialize(window)
        @x = 100
        @y = 400
        @angle = 90 
        @image = Gosu::Image.new('image/brolystand.png')
        @velocity_x = 0 
        @velocity_y = 0 
        @radius = 60
        @window = window
        @direction = "right"
        @status = "stand"
    end
end
