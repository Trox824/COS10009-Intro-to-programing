class Bullet
    attr_accessor :x, :y, :radius, :direction, :image, :window
    def initialize(window, x, y, angle)
        @x = x 
        @y = y
        @direction = "right" 
        @image = Gosu::Image.new('image/bulletright.png')
        @radius = 30
        @window = window
    end
end