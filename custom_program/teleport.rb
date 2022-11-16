class Teleport
    attr_accessor :x, :y, :radius, :images, :image_index, :finished 
    def initialize(direction, x, y)
        @x = x
        @y = y
        @radius = 65
        if direction == "left"
            @images = Gosu::Image.load_tiles('image/teleportleft.png', 130, 226) 
        else
            @images = Gosu::Image.load_tiles('image/teleportright.png', 130, 226)
        end
        @image_index = 0
        @finished = false
    end
end