require 'gosu'
require 'json'
require 'chipmunk'
require_relative 'jogador.rb'
require_relative 'tileset.rb'
require_relative 'particula.rb'
require_relative 'world.rb'
require_relative 'physicalWorld.rb'

##################Propriedades do Cenario(World)###################
WIDTH = 800
HEIGHT = 600
MAP_WORLD = JSON.parse(File.read('assets/map.json'))
TILE_WIDTH = MAP_WORLD['tilewidth']
TILE_HEIGTH = MAP_WORLD['tileheight']
TOTAL_WIDTH_TILE = MAP_WORLD['width'] * MAP_WORLD['tilewidth']
SPEED_MAP = 2
###################################################################


##################Propriedaes da Fisica(PhysicalWorld)#############
GRAVITY = 25.0
DAMPING = 0.8
FRICTION = 0.7
ELASTICITY = 0.8
###################################################################

#Finalmente nossa classe principal
class GameWindow < Gosu::Window
      def initialize
            super WIDTH, HEIGHT

            #Recuperando propriedades fisicas do game
            @physical = PhysicalWorld.new

            #Instanciando o World
            @world = World.new(self,@physical.space)

            #Instanciando o Jogador
            @jogador = Jogador.new(@physical.space,self,@world)
      end

      def button_down(id)
            close if id == Gosu::KbEscape
      end

      def update
            6.times do
                  @jogador.left() if button_down?(Gosu::KbLeft)
                  @jogador.right() if button_down?(Gosu::KbRight)
                  @jogador.jump() if button_down?(Gosu::KbSpace)

                  #Importante para da andamento nos elementos da fisica no space
                  @physical.space.step(@physical.dt)
            end
            moverJogadorRelacaoMapa()

            #Muito Importante!! Sem isso as particulas definidas como estaticas não se mexem no mapa.
            #Isso evita que elas se movam junto com o personagem
            @physical.space.rehash_static()

            self.caption = "#{Gosu.fps} FPS."
      end

      #Usado para fazer o mapa e o jogador se moverem de forma relativa
      def moverJogadorRelacaoMapa

            #Verifica se esta indo para esquerda. Sempre em relação ao personagem
            if @jogador.limites_mapa_jogador - @jogador.body.p.x > WIDTH-300
                  #condição importante. Evita que volte ao chegar na ponta do mapa
                  if @world.limites_mapa <= WIDTH
                        @jogador.body.p.x += SPEED_MAP
                  end
                  @world.map_left(SPEED_MAP)

            #Verifica se esta indo para direita. Sempre em relação ao personagem
            elsif @jogador.limites_mapa_jogador - @jogador.body.p.x <= 300
                  #condição importante. Evita que volte ao chegar na ponta do mapa
                  if @world.limites_mapa > 0
                        @jogador.body.p.x -= SPEED_MAP
                  end
                  @world.map_right(-SPEED_MAP)
            end
      end

      def draw
            @world.draw
            @jogador.draw
      end

end

GameWindow.new.show
