#Establish the z-coordinate layer orders for items
module ZOrder
    Background = 0
    Burger = 1
    Player = 2
    UI = 3
end

#Set up the Game Window
class GameWindow < Gosu::Window
    def initialize
        super(640, 480, false) #Set game window size
        self.caption = 'Eat Man'
        @background_image = Gosu::Image.new(self, 'img/background.png', true)
        @player = Player.new(self)
        @burgers = [Burger3.new(self)]
        @font = Gosu::Font.new(self, Gosu::default_font_name, 20)
        @sfx = [Gosu::Sample.new(self, "sound/collect.wav")]
        @music = [Gosu::Song.new(self, "sound/radio_star.ogg"), Gosu::Song.new(self, "sound/champions.ogg"), Gosu::Song.new(self, "sound/zelda.ogg"), Gosu::Song.new(self, "sound/blank_space.ogg")]
        @music[0].play(false)
        @score = 0
        @gap = 0
        @target = 3
        @alternate1 = false
        @alternate2 = false
    end
    
    def update
        #Take in keyboard control inputs
        if button_down? Gosu::KbLeft
            @player.icon = Gosu::Image.new(self, 'img/player_left.png', false)
            @player.move_left
        end
        if button_down? Gosu::KbRight
            @player.icon = Gosu::Image.new(self, 'img/player_right.png', false)
            @player.move_right
        end
        if button_down? Gosu::KbUp
            @player.icon = Gosu::Image.new(self, 'img/player_up.png', false)
            @player.move_up
        end
        if button_down? Gosu::KbDown
            @player.icon = Gosu::Image.new(self, 'img/player_down.png', false)
            @player.move_down
        end
        #Update burgers and establish collision/collision effects
        @burgers.each do |burger|
            burger.update
            if Gosu::distance(burger.x, burger.y, @player.x, @player.y) < 25
                burger.reset
                @sfx[0].play(0.5)
                @score += 1
            end
        end
        #Add new burgers as score increases
        if @score == @target
            #Burger types spawn in an alternating order
            if @alternate1 && @alternate2
                @burgers.push(Burger1.new(self))
                @alternate2 = false
            elsif @alternate1
                @burgers.push(Burger2.new(self))
                @alternate1, @alternate2 = false, true
            elsif @alternate2
                @burgers.push(Burger3.new(self))
                @alternate1 = false
            else
                @burgers.push(Burger4.new(self))
                @alternate1, @alternate2 = true, true
            end
            #Increase the gap between target scores each time previous target is reached
            @gap += 3
            @target += @gap
        end
        #Detect which song is playing
        if @music[0].playing?
            @song = "Video Killed the Radio Star - The Buggles"
        elsif @music[1].playing?
            @song = "We Are The Champions - Queen"
        elsif @music[2].playing?
            @song = "Legend of Zelda - Nintendo"
        elsif @music[3].playing?
            @song = "Blank Space - Taylor Swift"
        end
    end

    def draw
        @background_image.draw_as_quad(0, 0, 0xffffffff, self.width, 0, 0xffffffff, self.width, self.height, 0xffffffff, 0, self.height, 0xffffffff, ZOrder::Background) #Draw the background as a quadrangle to fit the screen
        @font.draw("Score: #{@score}", 10, 10, ZOrder::UI, 1.0, 1.0, 0xff000080) #Display/update score
        @font.draw("Now Playing: #{@song}", self.width / 4, self.height - 20, ZOrder::UI, 1.0, 1.0, 0xff000080) #Display/update song title
        @player.draw
        @burgers.each{|burger| burger.draw}
    end

    def button_down(id) #Single use keyboard controls
        case id
        when Gosu::KbQ
            close
        when Gosu::Kb1
            @music[0].play(false)
        when Gosu::Kb2
            @music[1].play(false)
        when Gosu::Kb3
            @music[2].play(false)
        when Gosu::Kb4
            @music[3].play(false)
        when Gosu::KbS
            5.times{@burgers.push(Burger1.new(self))}
            5.times{@burgers.push(Burger2.new(self))}
            5.times{@burgers.push(Burger3.new(self))}
            5.times{@burgers.push(Burger4.new(self))}
        end
    end

    def button_up(id)
    end
end

class Player
    attr_reader :x, :y
    attr_writer :icon
    def initialize(window)
        @window = window
        @icon = Gosu::Image.new(@window, 'img/player_right.png', false)
        @player_width = @window.height / 15 #Set the player width to 1/15th the window height
        @player_height = @window.height / 15 #Set the player height to 1/15th the window height
        @x = @window.width / 2
        @y = @window.height / 2
        $score = 0
    end

    def draw
        @icon.draw(@x, @y, ZOrder::Player)
    end

#Give player move methods
    def move_left
        @x -= 6
        if @x < 0
            @x = 0
        end
    end

    def move_right
        @x += 6
        if @x > @window.width - 25
            @x = @window.width - 25
        end
    end

    def move_up
        @y -= 6
        if @y == 0
            @y = 0
        end
    end

    def move_down
        @y += 6
        if @y == @window.height
            @y = @window.height
        end
    end
end

#Vertical (top => bottom) burger
class Burger1
    attr_reader :x, :y
    def initialize(window)
        @window = window
        @icon = Gosu::Image.new(@window, "img/burger.png", false)
        @x = rand(@window.width)
        @y = 0
    end

    def update
        @y += 4
        #If the burger reaches the end of the window, reset to beginning
        if @y > @window.height
            reset
        end
    end

    def draw
        @icon.draw(@x, @y, ZOrder::Burger)
    end

    def reset
        @x = rand(@window.width)
        @y = 0
    end
end

#Vertical (bottom => top) burger
class Burger2
    attr_reader :x, :y
    def initialize(window)
        @window = window
        @icon = Gosu::Image.new(@window, "img/burger.png", false)
        @x = rand(@window.width)
        @y = @window.height
    end

    def update
        @y -= 4
        #If the burger reaches the end of the window, reset to beginning
        if @y < 0
            reset
        end
    end

    def draw
        @icon.draw(@x, @y, ZOrder::Burger)
    end

    def reset
        @x = rand(@window.height)
        @y = @window.height
    end
end

#Horizontal (left => right) burger
class Burger3
    attr_reader :x, :y
    def initialize(window)
        @window = window
        @icon = Gosu::Image.new(@window, "img/burger.png", false)
        @x = 0
        @y = rand(@window.height)
    end

    def update
        @x += 4
        #If the burger reaches the end of the window, reset to beginning
        if @x > @window.width
            reset
        end
    end

    def draw
        @icon.draw(@x, @y, ZOrder::Burger)
    end

    def reset
        @x = 0
        @y = rand(@window.height)
    end
end

#Horizontal (right => left) burger
class Burger4
    attr_reader :x, :y
    def initialize(window)
        @window = window
        @icon = Gosu::Image.new(@window, "img/burger.png", false)
        @x = @window.width
        @y = rand(@window.height)
    end

    def update
        @x -= 4
        #If the burger reaches the end of the window, reset to beginning
        if @x < 0
            reset
        end
    end

    def draw
        @icon.draw(@x, @y, ZOrder::Burger)
    end

    def reset
        @x = @window.width
        @y = rand(@window.height)
    end
end

