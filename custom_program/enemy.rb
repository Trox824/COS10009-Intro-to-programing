class Enemy
    attr_accessor :x, :y, :radius, :image, :direction
    def initialize(window)
        @radius = 20
        @randomnumber = rand(0..1)
    
        if @randomnumber == 0 
            @direction = "right"
            @x = -20
        elsif @randomnumber == 1
            @direction = "left"
            @x = 1000
        end
        
        @y = rand(2*@radius..window.height - 4 * @radius) 
        @image = Gosu::Image.new('image/enemy.png')
    end
end
