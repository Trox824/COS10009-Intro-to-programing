require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'boss'
require_relative 'ability'
require_relative 'score'
require_relative 'teleport'
#Player

#read score from a text file
def read_scores(file)
    file = File.new(file,"r")
    count = file.gets().to_i()
    scores = Array.new()
    while count >= 0
        player_name = file.gets().to_s()
        player_score = file.gets().to_i()
        score = Score.new(player_name, player_score)
        scores << score
        count -= 1
    end
    file.close()     
    return scores 
end
#write score from the text file
def write_score(file, score, name)
    file.puts(name)
    file.puts(score)
end
#change the angle of player to 90 degree 
def turn_right_player(player)
    player.angle = 90
    player.direction = "right"
end
#change the angle of player to 270 degree
def turn_left_player(player)
    player.angle = 270
    player.direction = "left" 
end
#change the angle of player to 360 degree
def turn_up_player(player)
    player.angle = 360
end
#change the angle of player to 180 degree
def turn_down_player(player)
    player.angle = 180
end

#increase the velocity of player continuously
def accelerate(player)
    player.velocity_x += Gosu.offset_x(player.angle, 1)
    player.velocity_y += Gosu.offset_y(player.angle, 1)
end
#after finishing increase the velocity of player, x, y cordinate of player will constantly reduce
def move_player(player)
    player.x += player.velocity_x 
    player.y += player.velocity_y 
    player.velocity_x *= 0.9
    player.velocity_y *= 0.9
    
    #prevent player go out of the border of the game
    if player.x > player.window.width - player.radius 
        player.x = player.window.width - player.radius
    end

    if player.x < player.radius 
        player.velocity_x = 0 
        player.x = player.radius
    end

    if player.y > player.window.height - player.radius - 40
        player.velocity_y = 0
        player.y = player.window.height - player.radius - 40
    end

    if player.y < player.radius + 45
        player.velocity_y = 0
        player.y = player.radius + 45
    end     
end

#draw player image
def draw_player(player)
    if player.status == "screaming"
        player.image.draw_rot(player.x, player.y - 50, 1, 0)
    else
        player.image.draw_rot(player.x, player.y, 1, 0)
    end
end

#Ability
def move_ability(ability)
    ability.y += 1.5
end
def draw_ability(ability)
    ability.image.draw(ability.x-ability.radius, ability.y-ability.radius, 1)
end

#Boss
def move_boss(boss)
    boss.y += 1

end
def draw_boss(boss)
    boss.image.draw(boss.x-boss.radius, boss.y-boss.radius, 1)
end

#Bullet
def move_bullet(bullet)
    if bullet.direction == "right"
        bullet.x += 10
    else
        bullet.x -= 10
    end
end
#draw bullet base on the direction
def draw_bullet_right(bullet, player)
    if bullet.direction == "right"
        bullet.image = Gosu::Image.new('image/bulletright.png')
        bullet.image.draw(bullet.x - bullet.radius + 100, bullet.y - bullet.radius - 60, 1)
    else
        bullet.image = Gosu::Image.new('image/bulletleft.png')
        bullet.image.draw(bullet.x - bullet.radius - 100, bullet.y - bullet.radius - 60, 1)
    end
end
#check if the bullet out of the screen
def check_onscreen(bullet)
    right = bullet.window.width + bullet.radius 
    left = -bullet.radius 
    top = -bullet.radius 
    bottom = bullet.window.height + bullet.radius 
    bullet.x > left and bullet.x < right and bullet.y > top and bullet.y < bottom 
end

#Enemy 
def move_enemy(enemy)
    if enemy.direction == "right"
        enemy.x += 2.5
    elsif enemy.direction == "left"
        enemy.x -= 2.5    
    end
end

#draw enemy
def draw_enemy(enemy)
    enemy.image.draw(enemy.x-enemy.radius, enemy.y-enemy.radius, 1)
end

#Explosion
def draw_explosion(explosion)
    if explosion.image_index < explosion.images.count 
        explosion.images[explosion.image_index].draw(explosion.x - explosion.radius, explosion.y - explosion.radius, 2)
        explosion.image_index += 1
    else
        explosion.finished = true
    end
end
#draw teleport animation
def draw_teleport(teleport)

    if teleport.image_index < teleport.images.count 
        teleport.images[teleport.image_index].draw(teleport.x - teleport.radius, teleport.y - teleport.radius, 2)
        teleport.image_index += 1
    else
        teleport.finished = true
    end
end

#main game 
class Dragonba11s < Gosu::Window 
    WIDTH = 976
    HEIGHT = 549
    def initialize 
        super(WIDTH,HEIGHT) 
        self.caption = 'Dragon Ba11s'
        @start_image = Gosu::Image.new('image/background.jpg')
        @scene = :start
        @start_option_1 = "New Game (Press 1)"
        @start_option_2 = "Quit (Press 2)"
        @start_option_font = Gosu::Font.new(28)
        @scorearray = Array.new
        @highestscorearray = Array.new
        @inputName = ""
        @scores = read_scores("score.txt")
        for i in 0..@scores.length - 1
           @highestscorearray[i] = @scores[i].player_score 
        end
        @highestscorearray = @highestscorearray.sort 
        @highestscore = @highestscorearray[@highestscorearray.length - 1]

        @gamedifficulty = 0
        @ENEMY_FREQUENCY = 0.02
        @BOSS_FREQUENCY = 0.001
        @ABILITY_FREQUENCY = 0.003
    end
    #scene for each case 
    def draw 
        case @scene
        when :start
            draw_start
        when :game
            draw_game
        when :semi_end
            draw_semi_end
        when :end 
            draw_end
        end
    end

    def draw_start
        @start_image.draw(0,0,0)
        Gosu.draw_rect(330, 300, 300, 300, Gosu::Color::BLACK, 1, mode=:default)
        @start_option_font.draw(@start_option_1,350,360,1,1,1,Gosu::Color::WHITE)
        @start_option_font.draw(@start_option_2,350,400,1,1,1,Gosu::Color::WHITE)
        @start_option_font.draw("Difficulty: <= #{@gamedifficulty} =>",350,440,1,1,1,Gosu::Color::WHITE)

    end

    def draw_game
        @in_game_font.draw("Score: #{@score}",870,20,1,1,1,Gosu::Color::FUCHSIA)
        @in_game_font.draw("Skill point: #{@bonuspoint}",870,40,1,1,1,Gosu::Color::FUCHSIA)

        if @cursed == true
            @in_game_font.draw("YOU ARE BEING CURSED",350,50,1,1,1,Gosu::Color::FUCHSIA)
        end

        @ingame_background.draw(0,0,0)

        draw_player(@player)

#draw health, mana, stamina 
        player_health_percentage = @health / @MAX_HEART.to_f
        player_mana_percentage = @mana / @MAX_MANA.to_f
        player_stamina_percentage = @stamina / @MAX_STAMINA.to_f

        Gosu.draw_rect(37, 23, 10 * @MAX_HEART + 4, 24, Gosu::Color::BLACK, 15, mode=:default)
        Gosu.draw_rect(37, 53, 10 * @MAX_MANA + 4, 24, Gosu::Color::BLACK, 15, mode=:default)
        Gosu.draw_rect(37, 83, 10 * @MAX_STAMINA + 4, 24, Gosu::Color::BLACK, 15, mode=:default)

        Gosu.draw_rect(39, 25,10 * @MAX_HEART * player_health_percentage, 20, Gosu::Color::RED, 15, mode=:default)
        Gosu.draw_rect(39, 55, 10 * @MAX_MANA * player_mana_percentage, 20, Gosu::Color::BLUE, 15, mode=:default)
        Gosu.draw_rect(39, 85, 10 * @MAX_STAMINA * player_stamina_percentage, 20, Gosu::Color::GREEN, 15, mode=:default)

        if @teleported == true 
            draw_teleport(@teleport)
        end
#draw other objects
        @enemies.each do |enemy|
            draw_enemy(enemy)
        end

        @bullets.each do |bullet|
            draw_bullet_right(bullet, @player)
        end

        @explosions.each do |explosion|
            draw_explosion(explosion)
        end

        @bosses.each do |boss|
            draw_boss(boss)
        end

        @abilities.each do |ability|
            draw_ability(ability)
        end
    

    end

    def draw_end
        @message_font.draw( @inputName + ", " +@message,250,100,1,1,1,Gosu::Color::FUCHSIA)
        @message_font.draw(@message2,250,150,1,1,1,Gosu::Color::FUCHSIA)
        @message_font.draw(@bottom_message,250,200,1,1,1,Gosu::Color::FUCHSIA)
        @message_font.draw("Leader Board",250,250,1,1,1,Gosu::Color::FUCHSIA)
        for i in 0..3 do
            @message_font.draw(" #{i+1}. name: #{@scorearray[i].player_name.to_s} score: #{@scorearray[i].player_score}", 250, 280 + 60*i,1,1,1,Gosu::Color::FUCHSIA)    
        end
    end

    def draw_semi_end
        @message_font.draw("Enter player name: " + @inputName,250,200,99,1,1,Gosu::Color::FUCHSIA)
        
    end

    def update 
        case @scene
        when :game
            update_game
        end
    end

    def button_down(id)
        case @scene
        when :start 
            button_down_start(id)
        when :game 
            button_down_game(id)
        when :end
            button_down_end(id)
        when :semi_end
            button_down_semi_end(id)
        end
    end

    def button_down_start(id)
        if id == Gosu::Kb1
            initialize_game
        elsif id == Gosu::Kb2
            close
            #change difficulty
        elsif id == Gosu::KbRight && @gamedifficulty < 7
            @gamedifficulty += 1
            @ENEMY_FREQUENCY = 0.02 + @gamedifficulty*0.003
            @BOSS_FREQUENCY = 0.001 + @gamedifficulty*0.0002
            @ABILITY_FREQUENCY = 0.003 - @gamedifficulty*0.0005
        elsif id == Gosu::KbLeft && @gamedifficulty > 0
            @gamedifficulty -= 1
        end
    end

    def initialize_game
        @player = Player.new(self) 
        @enemies = [] 
        @bullets = [] 
        @explosions = []
        @bosses = []
        @abilities = []
        @scene = :game
        @score = 0 
        @healh = 10
        @mana = 10
        @stamina = 10
        @in_game_font = Gosu::Font.new(20)
        @player.direction = "right"
        @player.status = "stand"
        @bosses_destroyed = 0 
        @bosses_appeared = 0 
        @enemies_appeared = 0 
        @enemies_destroyed = 0 
        @beamingdelay = 0
        @kickingdelay = 0
        @explosion_sound = Gosu::Sample.new('sounds/explosion.wav')
        @shooting_sound = Gosu::Sample.new('sounds/laser_shooting_sfx.wav')
        @boss_sound = Gosu::Sample.new('sounds/boss_dying.wav')
        @ingame_background = Gosu::Image.new('image/background.jpg')
        @health = 10
        @bonuspoint = 0 
        @cursed = false
        
        @teleported = false 

        @inputName = ""
        
        @MAX_HEART = 10
        @MAX_STAMINA = 10
        @MAX_MANA = 10
    end
    def update_game    
        if @beamingdelay < 10
            @beamingdelay += 1
        end
        
        #stamina control
        
        if @cursed == true
            @health -= 0.01
        end
#changing direction button
        if button_down?(Gosu::KbLeft) 
            turn_left_player(@player) 
        end

        if button_down?(Gosu::KbRight) 
            turn_right_player(@player) 
        end

        if button_down?(Gosu::KbUp)
            turn_up_player(@player) 
        end
        
        if button_down?(Gosu::KbDown)
            turn_down_player(@player) 
        end
#condition for flying 
        if ( @player.velocity_x > 0.9 or @player.velocity_x < -0.9 ) and @player.status == "stand" and @stamina > 2 
            @player.status = "flying"
        end
    #condition for standing 
        if ( @player.velocity_x < 0.9 and @player.velocity_x > -0.9 ) and ( @beamingdelay == 10) 
            @player.status = "stand"
            if @stamina < @MAX_STAMINA - 0.1 and @player.velocity_x < 0.2 and @player.velocity_x > -0.2
                @stamina += 0.1
            end
        end    
        #buttondown for beaming 
        if button_down?(Gosu::KbW) and @player.status == "stand"
            @player.status = "screaming"
            if @mana < @MAX_MANA
                @mana += 0.025
            end
        end
        if @mana < @MAX_MANA
            @mana += 0.001
        end
        #moving button
        if ( button_down?(Gosu::KbLeft) or button_down?(Gosu::KbRight) or button_down?(Gosu::KbUp) or button_down?(Gosu::KbDown)) and @stamina > -1 and @player.status != "screaming"
            if @stamina > 0.3
                accelerate(@player)
            end
            if  @stamina < 0.2
                @stamina = 0
            else
                @stamina -= 0.05  
            end   
        end
        
       #image for each status 
        move_player(@player)
        if @player.direction == "right" and @player.status == "stand"
            @player.image = Gosu::Image.new('image/brolystand.png')
        elsif @player.direction == "left" and @player.status == "stand"
            @player.image = Gosu::Image.new('image/brolystandleft.png')
        elsif @player.direction == "right" and @player.status == "flying"
            @player.image = Gosu::Image.new('image/brolymoving.png')
        elsif @player.direction == "left" and @player.status == "flying"
            @player.image = Gosu::Image.new('image/brolyflightleft.png')
        elsif @player.direction == "right" and @player.status == "beaming"
            @player.image = Gosu::Image.new('image/brolybeamingright.png')
        elsif @player.direction == "left" and @player.status == "beaming"
            @player.image = Gosu::Image.new('image/brolybeamingleft.png')
        elsif @player.direction == "right" and @player.status == "kicking"
            @player.image = Gosu::Image.new('image/brolykickright.png')
        elsif @player.direction == "left" and @player.status == "kicking"
            @player.image = Gosu::Image.new('image/brolykickleft.png')
        elsif @player.direction == "right" and @player.status == "screaming"
            @player.image = Gosu::Image.new('image/brolyscreaming.png')
        elsif @player.direction == "left" and @player.status == "screaming"
            @player.image = Gosu::Image.new('image/brolyscreamingleft.png')
        end


        if rand < @ENEMY_FREQUENCY #create enemy
            @enemysample = Enemy.new(self)
            @randomdirection = rand(0..1)
            case @randomdirection
            when 0
                @enemysample.direction = "right"
            when 1
                @enemysample.direction = "left"
            end
        
            @enemies.push @enemysample
            @enemies_appeared += 1 
        end
       
        if rand < @BOSS_FREQUENCY #create boss 
            @bosses.push Boss.new(self)
            @bosses_appeared += 1
        end

        if rand < @ABILITY_FREQUENCY #create ability 
            @abilities.push Ability.new(self)
        end

        @enemies.each do |enemy| #move enemy 
            move_enemy(enemy)
        end

        @bosses.each do |boss| # move boss 
            move_boss(boss)
        end

        @bullets.each do |bullet| #move bullet 
            move_bullet(bullet)
        end

        @abilities.each do |ability| #move ability 
            move_ability(ability)
        end

        @enemies.dup.each do |enemy|  #create collision between enemy and bullet 
            @bullets.dup.each do |bullet|
                if bullet.direction == "right"
                    distance_enemy_bullet = Gosu.distance(enemy.x, enemy.y, bullet.x - bullet.radius + 100, bullet.y - bullet.radius - 60)
                else
                    distance_enemy_bullet = Gosu.distance(enemy.x, enemy.y, bullet.x - bullet.radius - 100, bullet.y - bullet.radius - 60)
                end
                if distance_enemy_bullet < enemy.radius + bullet.radius 
                    @enemies.delete enemy 
                    @bullets.delete bullet
                    @explosions.push Explosion.new(self, enemy.x, enemy.y)
                    @enemies_destroyed += 1
                    @score += 5
                    @explosion_sound.play
                    if @mana <= @MAX_MANA - 0.2
                        @mana += 0.2
                    end
                end
            end
        end

        @abilities.dup.each do |ability| #create collision between player an ability 
            distance_player_ability = Gosu::distance(ability.x, ability.y, @player.x, @player.y)
            if distance_player_ability < @player.radius + ability.radius
                @abilities.delete ability 
                @abilitynumber = rand(1..3)
                case @abilitynumber 
                when 1
                    if @health + 2 > @MAX_HEART
                        @health = @MAX_HEART
                    else
                        @health += 2
                    end
                when 2 
                    if @mana + 2 > @MAX_MANA 
                        @mana = @MAX_MANA 
                    else
                        @mana += 2
                    end
                end         
            end
        end

        @bosses.dup.each do |boss|  #create collision between boss and bullet 
            @bullets.dup.each do |bullet|
                if bullet.direction == "right"
                    distance_boss_bullet = Gosu.distance(boss.x, boss.y, bullet.x - bullet.radius + 100, bullet.y - bullet.radius - 60)
                else
                    distance_boss_bullet = Gosu.distance(boss.x, boss.y, bullet.x - bullet.radius - 100, bullet.y - bullet.radius - 60)
                end
                if distance_boss_bullet < boss.radius + bullet.radius
                    boss.hp -= 2 
                    if bullet.direction == "right"
                        @explosions.push Explosion.new(self, bullet.x - bullet.radius + 150, bullet.y - bullet.radius - 60)
                    else
                        @explosions.push Explosion.new(self, bullet.x - bullet.radius - 150, bullet.y - bullet.radius - 60)
                    end
                    @bullets.delete bullet
                    @explosion_sound.play
                    if boss.hp == 0 
                        @bosses.delete boss
                        @cursed = false
                        @bonuspoint += 1  
                    end
                end
            end
        end
        if @health <= 0
            initialize_end(:out_of_health)
        end
        @bosses.each do |boss| 
            distance2 = Gosu::distance(boss.x, boss.y, @player.x, @player.y)
            if distance2 < @player.radius + boss.radius
                @cursed = true
            end
        end

        @explosions.dup.each do |explosion| #delete ecplosion when finished
            @explosions.delete explosion if explosion.finished
        end

        @enemies.dup.each do |enemy| #delete enemy 
            if enemy.y > HEIGHT + enemy.radius
                @enemies.delete enemy 
                if @mana + 2 > @MAX_MANA
                    @mana = @MAX_MANA 
                else
                    @mana += 0.2
                end
            end
        end
 
        @bullets.dup.each do |bullet| #delete bullet 
            @bullets.delete bullet unless check_onscreen(bullet)
        end
        

        @enemies.each do |enemy| #lose when health = 0 (create collision between enemy and player)
            distance1 = Gosu::distance(enemy.x, enemy.y, @player.x, @player.y)
            if distance1 < @player.radius + enemy.radius 
                @enemies.delete enemy 
                @explosions.push Explosion.new(self, enemy.x, enemy.y)
                @explosion_sound.play
                unless ( @player.status == "kicking" and @player.direction != enemy.direction )
                    @health -= 1
                end
                if @mana + 0.2 > @MAX_MANA
                    @mana = @MAX_MANA
                else
                    @mana += 0.2
                end 
            end
        end

        
 #lose when player reachs the top border 
    end
    
    def button_down_game(id)
        if id == Gosu::KbSpace and @player.status == "stand" and @mana > 1
            @beamingdelay = 0
            @player.status = "beaming"
            @bulletsample = Bullet.new(self, @player.x, @player.y, @player.angle)
            @bulletsample.direction = @player.direction
            @bullets.push @bulletsample
            @shooting_sound.play(0.3) 
            @mana -= 1
        end

        if id == Gosu::KbE and @mana > 2
            @teleported = true
            @teleport = Teleport.new(@player.direction, @player.x, @player.y)
            @mana -= 2
            if @player.direction == "right"
                @player.x += 350
            else
                @player.x -= 350
            end
        end

        if id == Gosu::KbQ and @player.status == "stand" and @stamina > 2
            @player.status = "kicking"
            @beamingdelay = 0
            @stamina -= 1
        end

        if @bonuspoint > 0
            if id == Gosu::Kb1
                @MAX_HEART += 1
                @health += 1
                @bonuspoint -= 1
            elsif id == Gosu::Kb2
                @MAX_MANA += 1
                @mana += 1
                @bonuspoint -= 1
            elsif id == Gosu::Kb3
                @MAX_STAMINA += 1
                @stamina += 1
                @bonuspoint -= 1
            end
        end
    end
    
    def initialize_end(fate) #ending screen 
        case fate
        when :count_reached
            @message = "You SURVIVED."
            @message2 = "Score: #{@score}"
        when :out_of_health
            @message = "You were killed by an enemy"
            @message2 = "Score: #{@score}"
        end
        @bottom_message = "Press P to play again, or Q to quit "
        @scene = :semi_end
        @message_font = Gosu::Font.new(28)
    end
    def initialize_semi_end
        @file = File.new("score.txt","r")
            @count_number_player = @file.gets().to_i()
        @file.close
        #write a new file again
        @newfile = File.new("score.txt","w")
            @newfile.puts(@count_number_player + 1)
            for i in 0..@count_number_player - 1 do
                @newfile.puts(@scores[i].player_name)
                @newfile.puts(@scores[i].player_score)
            end
            @newfile.puts(@inputName)
            @newfile.puts(@score)
        @newfile.close
        #bubble sort for score
        for i in 0..@count_number_player 
            for j in 0..@count_number_player - 1 - i
                
                if @scorearray[ j ].player_score.to_i < @scorearray[ j+1 ].player_score.to_i
                
                    @temp = @scorearray[ j ].player_score
                    @scorearray[ j ].player_score = @scorearray[ j+1 ].player_score
                    @scorearray[ j+1 ].player_score  = @temp

                    @temp = @scorearray[ j ].player_name
                    @scorearray[ j ].player_name = @scorearray[ j+1 ].player_name
                    @scorearray[ j+1 ].player_name  = @temp
                end
            end
        end
    end
    def button_down_end(id) #run the game again or quit to the main menu 
        if id == Gosu::KbP
            initialize_game
        elsif id == Gosu::KbQ
            initialize
        end    
    end

    def button_down_semi_end(id)
            if id >= 4 && id <= 29 && @inputName.length < 10 && id != Gosu::KbSpace
              nextChar = id + 61
              @inputName += nextChar.chr
            elsif id >= 30 && id <= 39 && @inputName.length < 10 && id != Gosu::KbSpace
              if id != 39
                @inputName += (id - 29).to_s
              else
                @inputName += "0"
              end
            elsif id == 42
              @inputName = @inputName.chop
            end
            if id == Gosu::KbRight and @inputName != ""
                @scores = read_scores("score.txt")
                @scorearray = @scores
                initialize_semi_end
                @scene = :end
            end
    end
end
window = Dragonba11s.new
window.show