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
require_relative 'collisionHandlerZumbi.rb'
require_relative 'collisionHandlerJogador.rb'

##################Propriedades do Cenario(World)###################
WIDTH = 800
HEIGHT = 600
MAP_WORLD = JSON.parse(File.read('assets/map.json'))
TILE_WIDTH = MAP_WORLD['tilewidth']
TILE_HEIGTH = MAP_WORLD['tileheight']
TOTAL_WIDTH_TILE = MAP_WORLD['width'] * MAP_WORLD['tilewidth']
TOTAL_HEIGHT_TILE = MAP_WORLD['height'] * MAP_WORLD['tileheight']
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

            #Instanciando o Zumbi
            # @zumbi = Zumbi.new(@physical.space,self)
            # @esqueleto = Esqueleto.new(@physical.space)

            #Retirar/manipular os inimigos do jogo
            @inimigos = []

            #Variaveis para a tela inicial do jogo
            @jogando = false
            @font = Gosu::Font.new(45)
            @fontmine = Gosu::Font.new(125)
            @fontpainel = Gosu::Font.new(40)

            #Chamando todas as colisões entre os objetos do jogo
            colisao()

            #Classe para verificar o tempo que passou e para saber se pode colocar inimigo no mapa
            @tempo = 1
            @podeColocarInimigo = true

            #musicas do background
            @somBackground = Gosu::Sample.new("assets/sounds/minecraft2.wav")
            @somBackground.play(1,1,true)

            #vida coracao
            @vidac6 = Gosu::Image.new("assets/heart/6.png")
            @vidac5 = Gosu::Image.new("assets/heart/5.png")
            @vidac4 = Gosu::Image.new("assets/heart/4.png")
            @vidac3 = Gosu::Image.new("assets/heart/3.png")
            @vidac2 = Gosu::Image.new("assets/heart/2.png")
            @vidac1 = Gosu::Image.new("assets/heart/1.png")
            @vidac0 = Gosu::Image.new("assets/heart/0.png")

      end

      def button_down(id)
            close if id == Gosu::KbEscape
            @jogando=true if id == Gosu::KbSpace
      end

      def button_up(id)
             @inimigos.each do |inimigos|
                inimigos.podePerdeVida = true if id == Gosu::KbS
             end
             @jogador.podeSom = true
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

                        #########bloco correspondente aos inimigos do jogo############
                        #o bloco abaixo é responsável por fazer todos os inimigos perseguirem o jogador e caso a vida do inimigo chegue a zero ele é retirado do jogo
                        iterador = 0
                        @inimigos.each do |inimigos|
                           inimigos.perseguir(@jogador.body.p.x,@jogador.body.p.y)

                           #Os inimigos são apagados caso a vida chegue a zero ou ele caia pelas bordas do mapa
                           if inimigos.vida <= 0 or inimigos.body.p.y > TOTAL_HEIGHT_TILE
                               @physical.space.remove_body(inimigos.body)
                               @physical.space.remove_shape(inimigos.shape)
                               @inimigos.delete_at(iterador)
                           end
                           iterador += 1
                        end
                        ##############################################################

                        # @esqueleto.perseguir(@jogador.body.p.x,@jogador.body.p.y)
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

                  #atualizando o tempo do jogo
                  @tempo = Gosu::milliseconds()/1000

                  #Adicionar Inimigos Automaticamente a cada 15 segundos
                  if @tempo%15 == 0 and @inimigos.size < 3 and @podeColocarInimigo then
                    zumbi = Zumbi.new(@physical.space,self)
                    zumbi.body.p.x = rand(TOTAL_WIDTH_TILE)
                    @inimigos.push(zumbi)
                    @podeColocarInimigo = false
                  end

                  #Esse bloco de codigo garante que seja possivel colocar somente 1 inimigo a cada 15 segundos
                  if @tempo%16 == 0
                      @podeColocarInimigo = true
                  end
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
                  @inimigos.each do |inimigos|
                     inimigos.body.p.x += SPEED_MAP
                  end
                  # @esqueleto.body.p.x += SPEED_MAP
            elsif @world.movendoMapaRigth
                  @inimigos.each do |inimigos|
                     inimigos.body.p.x -= SPEED_MAP
                  end
                  # @esqueleto.body.p.x -= SPEED_MAP
            end
      end

      def draw
          if @jogando and @jogador.vida >= 1
              @world.draw
              @jogador.draw
              @inimigos.each do |inimigos|
                 inimigos.draw
              end
              # @esqueleto.draw
              @fontpainel.draw("Vida: ", 10, 10, 2)
              @fontpainel.draw("Score: ", 10, 45, 2)
              @vidac6.draw(100, 20, 2) if @jogador.vida == 6
              @vidac5.draw(100, 20, 2) if @jogador.vida == 5
              @vidac4.draw(100, 20, 2) if @jogador.vida == 4
              @vidac3.draw(100, 20, 2) if @jogador.vida == 3
              @vidac2.draw(100, 20, 2) if @jogador.vida == 2
              @vidac1.draw(100, 20, 2) if @jogador.vida == 1
              @vidac0.draw(100, 20, 2) if @jogador.vida == 0

          elsif @jogador.vida <= 0
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

      def colisao
          #Colisões para o zumbi
          @collision = CollisionHandlerZumbi.new
          @physical.space.add_collision_handler(:espada, :zumbi,@collision)

          #Detectando colisões. Esta sendo usada para os saltos do jogador
          @physical.space.add_collision_func(:jogador, :particula) do |jog, par|
             @jogador.particula = par
             @jogador.podePular = true
          end
          @collision2 = CollisionHandlerJogador.new
          @physical.space.add_collision_handler(:jogador, :zumbi,@collision2)

      end
end

GameWindow.new.show
