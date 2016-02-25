require 'gosu'
require 'json'
require 'chipmunk'

##################Propriedades do Cenario(World)###################
WIDTH = 800
HEIGHT = 600
MAP_WORLD = JSON.parse(File.read('map.json'))
TILE_WIDTH = MAP_WORLD['tilewidth']
TILE_HEIGTH = MAP_WORLD['tileheight']
###################################################################


##################Propriedaes da Fisica(PhysicalWorld)#############
GRAVITY = 25.0
DAMPING = 0.8
FRICTION = 0.7
ELASTICITY = 0.8
###################################################################

#Seletor de frames para os personagens
class Tileset
      def initialize(json)
            @json = JSON.parse(File.read(json))
            @main_image = Gosu::Image.new(@json['meta']['image'])
      end

      def frame(posicao)
          f = @json['frames'][posicao]['frame']
          @main_image.subimage(
          f['x'], f['y'], f['w'], f['h'])
      end
end

class Jogador
      attr_reader :shape
      def initialize(space,win)
            #Recuperando os pedaços do corpo do personagem
            @tiled = Tileset.new('personagens.json')

            #Montando as  imagens das partes do corpo do personagem
            @cabeca = @tiled.frame(8)
            @r_cabeca = @tiled.frame(9)
            @tronco = @tiled.frame(7)

            #Angulo da movimetação dos braços
            @movimentacao = 0.0
            #Sobrescrita dos braços
            @sobre1 = 1
            @sobre2 = 2

            #Detalhe: 2 braços
            @bracoLeft = @tiled.frame(6)
            @bracoRight = @bracoLeft

            #Detalhe: 2 pernas
            @pernaLeft = @tiled.frame(10)
            @pernaRight = @pernaLeft

            #Definindo Varivaeis space, window e colisor
            @space = space
            @window = win

            #Vamos definir como será o corpo e a shape do personagem
            definirCorpo()

            #Detectando colisões. Esta sendo usada para os saltos
            @space.add_collision_func(:jogador, :particula) do |jog, par|
               @par = par
               @podePular = true
            end
      end

      def left
            @body.apply_impulse(CP::Vec2.new(-5.0, 0), CP::Vec2.new(0, 0))
            movimentacaoMembros()
            @QualLado = true
      end

      def right
            @body.apply_impulse(CP::Vec2.new(5.0, 0), CP::Vec2.new(0, 0))
            movimentacaoMembros()
            @QualLado = false
      end

      def jump
            if @podePular and @body.p.y+60 < @par.body.p.y
                  @body.apply_impulse(CP::Vec2.new(0.0, -700.0), CP::Vec2.new(0, 0))
            end
            @podePular = false
      end

      def draw

            #Fazer os membros balançarem para ambos os lados
            if @movimentacao >= 60 or @movimentacao <= -60
                  @movimentacao*=-1
                  #Mudando a sobreposição dos membros
                  s1 = @sobre1
                  s2 = @sobre2
                  @sobre1 = s2
                  @sobre2 = s1
            end

            #Define a posição dos elementos do corpo do personagem
            definirPosicao()

            #Esse trecho de codigo é usado para depuração das shapes no jogador
            # @window.draw_quad(@body.p.x + @shape_verts[3].x, @body.p.y + @shape_verts[3].y, @color,
            #              @body.p.x + @shape_verts[2].x, @body.p.y + @shape_verts[2].y, @color,
            #              @body.p.x + @shape_verts[0].x, @body.p.y + @shape_verts[0].y, @color,
            #              @body.p.x + @shape_verts[1].x, @body.p.y + @shape_verts[1].y, @color,
            #              z=3)

            if @QualLado
                  @cabeca.draw_rot(@posicaoCabecaX,@posicaoCabecaY,2,0,0.5,0.5)
            else
                  @r_cabeca.draw_rot(@posicaoCabecaX,@posicaoCabecaY,2,0,0.5,0.5)
            end

            @tronco.draw_rot(@posicaoTroncoX,@posicaoTroncoY,
                             2,0,
                             0,0)

            @bracoLeft.draw_rot(@posicaoBracoX,@posicaoBracoY,
                                @sobre1,@movimentacao,
                                0.5,0)

            @bracoRight.draw_rot(@posicaoBracoX,@posicaoBracoY,
                                 @sobre2,-@movimentacao,
                                 0.5,0)

            @pernaLeft.draw_rot(@posicaoPernaX,@posicaoPernaY,
                                @sobre1,@movimentacao,
                                0.5,0)
            @pernaRight.draw_rot(@posicaoPernaX,@posicaoPernaY,
                                 @sobre2,-@movimentacao,
                                 0.5,0)
      end

      #Fazendo os membro se mexerem
      def movimentacaoMembros
            @movimentacao += 1
      end

      def definirCorpo()
            @body = CP::Body.new(10.0,1.0/0)
            @body.v = CP::Vec2.new(10.0, 0.0)
            @body.v_limit = 500
            @body.p = CP::Vec2.new(500, 100)

            @shape_verts = [CP::Vec2.new(0.0, 0.0), CP::Vec2.new(0.0, 70),
                            CP::Vec2.new(25, 70), CP::Vec2.new(25, 0.0)]
            @shape = CP::Shape::Poly.new(@body, @shape_verts, CP::Vec2.new(0,0))
            @shape.collision_type = :jogador

            @shape.u = FRICTION
            @shape.e = ELASTICITY

            @space.add_body(@body)
            @space.add_shape(shape)

            #Usado para depuração das shapes no jogo
            # @color = Gosu::Color.new(255,0,255,0)
            # # the more elastic the greener
            # @color.saturation *= ELASTICITY
            # @color.value *= ELASTICITY
      end

      def definirPosicao

            @posicaoCabecaX = @body.p.x + @cabeca.width/2
            @posicaoCabecaY = @body.p.y + @cabeca.height/2

            @posicaoTroncoX = @body.p.x + 2
            @posicaoTroncoY = @body.p.y + @cabeca.height

            @posicaoBracoX = @body.p.x + @cabeca.width/2
            @posicaoBracoY = @body.p.y + @cabeca.height

            @posicaoPernaX = @body.p.x + 12.5
            @posicaoPernaY = @body.p.y + @tronco.height + @cabeca.height
      end

end

class Particula
      attr_reader :shape
      def initialize(posicao,imagem,forma,win)
            @window = win
            @shape_verts = forma
            @imagem = imagem
            @body = posicao

            #Codigo que faz parte da impressão das formas nas shapes
            # @color = Gosu::Color.new(255,0,255,0)
            # the more elastic the greener
            # @color.saturation *= ELASTICITY
            # @color.value *= ELASTICITY
      end

      def draw
            @imagem.draw_rot(@body.p.x, @body.p.y, 1, 0, 0.0, 0.0)

            #Codigo para depuração das shapes. Esse codigo imprime o desenho das formas no cenario
            # @window.draw_quad(@body.p.x + @shape_verts[3].x, @body.p.y + @shape_verts[3].y, @color,
            #              @body.p.x + @shape_verts[2].x, @body.p.y + @shape_verts[2].y, @color,
            #              @body.p.x + @shape_verts[0].x, @body.p.y + @shape_verts[0].y, @color,
            #              @body.p.x + @shape_verts[1].x, @body.p.y + @shape_verts[1].y, @color,
            #              z=3)
      end
end

class World
      def initialize(window,space)

            #Definindo incrementador de linhas e colunas
            @r=0.0
            @c=0.0

            #Recuperando o Array com as camadas
            @camadas = MAP_WORLD['layers']

            #Cortando a imagem Em pequenos pedaços
            @img = Gosu::Image.load_tiles(window, 'nove.png', TILE_WIDTH, TILE_HEIGTH, true)

            #Recebendo o space
            @space = space
            @window = window
            #posiciona os elementos no world
            @posicoes = []
            posicionar()

      end

      def draw
            v=0
            l=0
            for layers in @camadas
                  for i in layers['data']
                        if i > 0 and (i != 22 and i != 50)
                              x = @posicoes[v][0]['posicao'][0].to_i
                              y = @posicoes[v][0]['posicao'][1].to_i
                              @img[i-1].draw(x, y, l)
                        elsif i == 22 or i == 50
                              #caso seja uma particula (objeto com fisica) desenhos ele
                              @posicoes[v].draw
                        end
                        v+=1
                  end

                  l+=1
            end
      end

      #Indica as posições dos objetos no desenho do cenario
      def posicionar()
            for layers in @camadas
                  for i in layers['data']

                        if @c % layers['width'] == 0 and @c != 0
                              @c=0
                              @r+=1
                              if @r % layers['height'] == 0 and @r != 0
                                    @r=0
                              end
                        end
                        #caso o elemento seja algo solido inserimos ele como uma
                        #particula (objeto com fisica) no mapa
                        if i == 22 or i == 50
                              x = @c * TILE_WIDTH
                              y = @r * TILE_HEIGTH
                              inserirSpace(x,y)
                              #Os parametros @forma e @windows, servem para depuração das shapes do shipmunk
                              particula = Particula.new(@body,@img[i-1],@forma,@window)
                              @posicoes << particula
                        else
                              @posicoes << [
                                    {"posicao"=>[@c * TILE_WIDTH,@r * TILE_HEIGTH]}
                              ]
                        end

                        @c+=1
                  end
            end
      end

      # Cria a forma e corpo e adiciona no space
      def inserirSpace(x,y)
            @body = CP::Body.new_static
            @body.p = CP::Vec2.new(x, y)
            @forma = [CP::Vec2.new(0.0, 0.0), CP::Vec2.new(0.0, 50.0),
                     CP::Vec2.new(50.0, 50.0), CP::Vec2.new(50.0, 0.0)]
            shape = CP::Shape::Poly.new(@body, @forma, CP::Vec2.new(0,0))
            shape.collision_type = :particula
            shape.u = FRICTION
            shape.e = ELASTICITY

            @space.add_shape(shape)
      end
end

class PhysicalWorld
      attr_accessor :space
      attr_accessor :dt
      def initialize
            @space = CP::Space.new
            @space.damping = DAMPING
            @space.gravity = CP::Vec2.new(0.0,GRAVITY)

            # Time increment over which to apply a physics "step" ("delta t")
            @dt = (1.0/60.0)
      end
end

class GameWindow < Gosu::Window
      def initialize
            super WIDTH, HEIGHT

            #Recuperando propriedades fisicas do game
            @physical = PhysicalWorld.new

            #Instanciando o World
            @world = World.new(self,@physical.space)

            #Instanciando o Jogador
            @jogador = Jogador.new(@physical.space,self)
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
            self.caption = "#{Gosu.fps} FPS."
      end

      def draw
            @world.draw
            @jogador.draw
      end

end

GameWindow.new.show
