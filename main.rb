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
require_relative 'collisionHandlerInimigos.rb'
require_relative 'collisionHandlerJogador.rb'
require_relative 'collisionHandlerLarva.rb'

##################Propriedades do Cenario(World)###################
WIDTH = 800
HEIGHT = 600
MAP_WORLD = JSON.parse(File.read('assets/map.json'))
TILE_WIDTH = MAP_WORLD['tilewidth']
TILE_HEIGTH = MAP_WORLD['tileheight']
TOTAL_WIDTH_TILE = MAP_WORLD['width'] * MAP_WORLD['tilewidth']
TOTAL_HEIGHT_TILE = MAP_WORLD['height'] * MAP_WORLD['tileheight']
SPEED_MAP = 2
PARTICULAS_ARRAY = [1,3,6,8,10,11,13,14,15,20,22,25,29,32,33,34,41,44,47,48,50,51,52,53,60,64,66,69,70,71,72,75,79,85,88,89,90,92,94]
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

            #Retirar/manipular os inimigos do jogo
            @inimigos = []

            #Variaveis para a tela inicial do jogo
            @jogando = false
            @font = Gosu::Font.new(45)
            @fontmine = Gosu::Font.new(125)
            @fontpainel = Gosu::Font.new(40)
            @score = 0
            @telainicial = Gosu::Image.new('assets/telainicial.png')

            #Chamando todas as colisões entre os objetos do jogo
            colisao()

            #Classe para verificar o tempo que passou e para saber se pode colocar inimigo no mapa
            @tempo = 1
            @podeColocarInimigo = true

            #musicas do background
            @somBackground = Gosu::Sample.new("assets/sounds/minecraft.ogg")
            @somBackground.play(1,1,true)

            #imagens coraçao(vida)
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
            @jogando=true if id == Gosu::KbSpace and @jogador.vida >= 1

            #Reinicia o jogo caso tenha dado gameover
            if !@jogando and id == Gosu::KbSpace
                reiniciarJogo
            end
      end

      def button_up(id)
             @inimigos.each do |inimigos|
                inimigos.podePerdeVida = true if id == Gosu::KbS
             end
             @jogador.podeSom = true
              @jogador.espada.atacando = false
      end

      #Reiniciar todo o jogo
      def reiniciarJogo

          #Resetando score e atributos do jogador
          @score = 0
          @jogador.body.p.x = rand(TOTAL_WIDTH_TILE)
          @jogador.body.p.y = 0
          @jogador.vida = 6

          #Tirando os inimigos do jogo
          iterador = 0
          @inimigos.each do |inimigos|
            @physical.space.remove_body(inimigos.body)
            @physical.space.remove_shape(inimigos.shape)
            @inimigos.delete_at(iterador)
            @score = 0
            iterador += 1
          end

          #fazendo o jogo rodar novamente
          @jogando = true
      end

      def update
            if @jogando and @jogador.vida >= 1
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

                        #Importante para da andamento nos elementos da fisica no space
                        @physical.space.step(@physical.dt)
                  end

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
                         @score += 10
                     end
                     iterador += 1

                     #Emitir sons do zumbi
                     inimigos.sons()
                  end
                  ##############################################################

                  #Evita que os elementos do mapa se movam junto com o movimento do mapa
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
                    #escolhe aleatoriamente entre os zumbis e esqueletos
                    if rand(10) < 8
                      zumbi = Zumbi.new(@physical.space,self)
                      zumbi.body.p.x = (@world.limites_mapa - 2400) + rand(TOTAL_WIDTH_TILE)
                      @inimigos.push(zumbi)
                    else
                      esqueleto = Esqueleto.new(@physical.space,self)
                      esqueleto.body.p.x = (@world.limites_mapa - 2400) + rand(TOTAL_WIDTH_TILE)
                      @inimigos.push(esqueleto)
                    end
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
            if WIDTH - @jogador.body.p.x > WIDTH - 300
                  #condição importante. Evita que o personagem volte ao chegar na ponta do mapa
                  if @world.limites_mapa < TOTAL_WIDTH_TILE-800
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
            elsif @world.movendoMapaRigth
                  @inimigos.each do |inimigos|
                     inimigos.body.p.x -= SPEED_MAP
                  end
            end
      end

      def draw
          if @jogando and @jogador.vida >= 1 #se o jogo foi iniciado e o jogador ainda possui vidas
              @world.draw
              @jogador.draw
              @inimigos.each do |inimigos|
                 inimigos.draw
              end
              @fontpainel.draw("Vida: ", 10, 10, 2,1,1,Gosu::Color.argb(0xff_000000))
              @fontpainel.draw("Score: #{@score}", 10, 45, 2,1,1,Gosu::Color.argb(0xff_000000))
              @vidac6.draw(100, 20, 2) if @jogador.vida == 6
              @vidac5.draw(100, 20, 2) if @jogador.vida == 5
              @vidac4.draw(100, 20, 2) if @jogador.vida == 4
              @vidac3.draw(100, 20, 2) if @jogador.vida == 3
              @vidac2.draw(100, 20, 2) if @jogador.vida == 2
              @vidac1.draw(100, 20, 2) if @jogador.vida == 1
              @vidac0.draw(100, 20, 2) if @jogador.vida == 0

          elsif @jogador.vida <= 0
            @fontmine.draw("Game Over", 150, 150, 2)
            @fontpainel.draw("Score: #{@score}", 150, 300, 2)
            @fontpainel.draw("Aperte 'Espaço' para Jogar Novamente", 150, 400, 2)
            @jogando = false
          else
              @telainicial.draw(0,0,1)
              @font.draw("Aperte espa\u{E7}o para iniciar", 50, 50, 2,1,1,Gosu::Color.argb(0xff_000000))
              @fontmine.draw("Mine", 180,150, 2,1,1,Gosu::Color.argb(0xff_000000))
              @fontmine.draw("Ruby", 180,230, 2,1,1,Gosu::Color.argb(0xff_000000))
          end
      end

      def colisao
          #Colisões para o zumbi
          @collision = CollisionHandlerInimigos.new
          @physical.space.add_collision_handler(:espada, :zumbi,@collision)
          @physical.space.add_collision_handler(:espada, :esqueleto,@collision)

          #Detectando colisões. Esta sendo usada para os saltos do jogador
          @physical.space.add_collision_func(:jogador, :particula) do |jog, par|
             @jogador.particula = par
             @jogador.podePular = true
          end

          #se o jogador entrar em contato com um zumbi/esqueleto, perderá vida
          @collision2 = CollisionHandlerJogador.new
          @physical.space.add_collision_handler(:jogador, :zumbi,@collision2)
          @physical.space.add_collision_handler(:jogador, :esqueleto,@collision2)

          @collision3 = CollisionHandlerLarva.new
          @physical.space.add_collision_handler(:jogador, :larva,@collision3)

      end
end

GameWindow.new.show
