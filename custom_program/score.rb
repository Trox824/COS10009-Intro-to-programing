class Score
    attr_accessor :player_name, :player_score
    def initialize (player_name, player_score)
        @player_name = player_name
        @player_score = player_score
    end
end