require 'gosu'
require 'json'
require 'chipmunk'
require_relative 'jogador.rb'
require_relative 'zumbi.rb'
require_relative 'esqueleto.rb'
require_relative 'tileset.rb'
require_relative 'particula.rb'
require_relative 'world.rb'
require_relative 'physicalWorld.rb'
require_relative 'item.rb'

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
            puts self.methods
            #Recuperando propriedades fisicas do game
            @physical = PhysicalWorld.new

            #Instanciando o World
            @world = World.new(self,@physical.space)

            #Instanciando o Jogador
            @jogador = Jogador.new(@physical.space,self,@world)

            #Instanciando o Zumbi
            @zumbi = Zumbi.new(@physical.space,self)
            @esqueleto = Esqueleto.new(@physical.space)

            @jogando = false
            @font = Gosu::Font.new(45)
            @fontmine = Gosu::Font.new(125)
            @fontpainel = Gosu::Font.new(40)

      end

      def button_down(id)
            close if id == Gosu::KbEscape
            @jogando=true if id == Gosu::KbSpace
      end

      def button_up(id)
             @zumbi.podePerdeVida = true if id == Gosu::KbS
      end

      def update
            if @jogando
                  6.times do
                        if button_down?(Gosu::KbLeft)
                              @jogador.left()
                        elsif button_down?(Gosu::KbRight)
                              @jogador.right()
                        else
                              @jogador.stand()
                        end
                        @jogador.jump() if button_down?(Gosu::KbSpace)
                        @jogador.atacar() if button_down?(Gosu::KbS)

                        @zumbi.perseguir(@jogador.body.p.x,@jogador.body.p.y)

                        @esqueleto.perseguir(@jogador.body.p.x,@jogador.body.p.y)
                        #Importante para da andamento nos elementos da fisica no space
                        @physical.space.step(@physical.dt)

                      #  @esqueleto.perseguir(@jogador.body.p.x,@jogador.body.p.y)
                  end

                  moverJogadorRelacaoMapa()
                  manterObejtosRelacaoMapa()

                  #Muito Importante!! Sem isso as particulas definidas como estaticas não se mexem no mapa.
                  #Isso evita que elas fiquem paradas e se movam junto com o personagem
                  @physical.space.rehash_static()

                  self.caption = "#{Gosu.fps} FPS."
            end
      end

      #Usado para fazer o mapa e o jogador se moverem de forma relativa
      #!!!Devido aos movimentos do jogador e mapa serem diferentes. Quando o mapa estiver
      #   se movendo, devemos decrementar a velocidade para evitar que o personagem ande
      #   junto com o mapa.
      def moverJogadorRelacaoMapa
            #Verifica se esta indo para esquerda. Sempre em relação ao personagem
            if WIDTH - @jogador.body.p.x > WIDTH-300
                  #condição importante. Evita que o personagem volte ao chegar na ponta do mapa
                  if @world.limites_mapa < WIDTH
                        @jogador.body.p.x += SPEED_MAP
                  end
                  @world.map_left(SPEED_MAP)

            #Verifica se esta indo para direita. Sempre em relação ao personagem
            elsif WIDTH - @jogador.body.p.x <= 300
                  #condição importante. Evita que o personagem volte ao chegar na ponta do mapa
                  if @world.limites_mapa > 0
                        @jogador.body.p.x -= SPEED_MAP
                  end
                  @world.map_right(-SPEED_MAP)
            end
      end

      #Esse metodo é bem parecido com o do Mover mapa em relação ao jogador. Mas esse serve para os objetos
      #que não são controlaveis no mapa (como os inimigos). Ele evita que, ao mapa se mover, os objetos andem.
      #junto com o mapa.
      def manterObejtosRelacaoMapa
            #Para verificar para qual lado o mapa esta indo, usamos os atributos de direção da classe World
            if @world.movendoMapaLeft
                  @zumbi.body.p.x += SPEED_MAP
                  @esqueleto.body.p.x += SPEED_MAP
            elsif @world.movendoMapaRigth
                  @zumbi.body.p.x -= SPEED_MAP
                  @esqueleto.body.p.x -= SPEED_MAP
            end
      end

      def draw
          if @jogando
              @world.draw
              @jogador.draw
              @zumbi.draw
              @esqueleto.draw
              @fontpainel.draw("Vida: ", 10, 10, 2)
          elsif @vida_personagem == 0
            @fontmine.draw("Game Over", 180, 150, 2)
            @jogando = false
          else
              @telainicial = Gosu::Image.new('assets/telainicial.png')
              @telainicial.draw(0,0,1)
              @font.draw("Aperte espa\u{E7}o para iniciar", 50, 50, 2)
              @fontmine.draw("Mine", 180,150, 2)
              @fontmine.draw("Ruby", 180,230, 2)
          end
      end

end

GameWindow.new.show
