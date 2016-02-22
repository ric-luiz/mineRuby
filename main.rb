require 'gosu'
require 'json'
require 'chipmunk'

##################Propriedades do Cenario(World)###################
WIDTH = 800
HEIGHT = 600
MAP_WORLD = JSON.parse(File.read('map2.json'))
TILE_WIDTH = MAP_WORLD['tilewidth']
TILE_HEIGTH = MAP_WORLD['tileheight']
###################################################################


##################Propriedaes da Fisica(PhysicalWorld)#############
GRAVITY = 25.0
DAMPING = 0.5
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
      def initialize(space)
            #Recuperando os pedaços do corpo do personagem
            @tiled = Tileset.new('cara.json')

            #Montando as  imagens das partes do corpo do personagem
            @cabeca = @tiled.frame(2)
            # @tronco = @tiled.frame(1)
            #
            # #Detalhe: 2 braços
            # @bracoLeft = @tiled.frame(0)
            # @bracoRight = @bracoLeft
            #
            # #Detalhe: 2 pernas
            # @pernaLeft = @tiled.frame(3)
            # @pernaRight = @pernaLeft

            @space = space

            definirCorpo()
      end

      def draw
            #Define a posição dos elementos do corpo do personagem
            # definirPosicao()

            @cabeca.draw_rot(@corpo.body.p.x,@corpo.body.p.y,
                             1,@corpo.body.a.radians_to_gosu)

            # @tronco.draw_rot(@posicaoTroncoX,@posicaoTroncoY,
            #                  1,@corpo.body.a.radians_to_gosu)
            #
            # @bracoLeft.draw_rot(@posicaoBracoX,@posicaoBracoY,
            #                     1,@corpo.body.a.radians_to_gosu)
            #
            # @bracoRight.draw_rot(@posicaoBracoX,@posicaoBracoY,
            #                     1,@corpo.body.a.radians_to_gosu)
            #
            # @pernaLeft.draw_rot(@posicaoPernaX,@posicaoPernaY,
            #                     1,@corpo.body.a.radians_to_gosu)
      end

      def definirCorpo()
            body = CP::Body.new(10.0,300.0)

            shape_array = [CP::Vec2.new(-12.5, -35), CP::Vec2.new(-12.5, 35),
                           CP::Vec2.new(12.5, 35), CP::Vec2.new(12.5, -35)]
            shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))
            shape.collision_type = :jogador

            # shape.u = FRICTION
            # shape.e = ELASTICITY

            @space.add_body(body)
            @space.add_shape(shape)

            shape.body.p = CP::Vec2.new(200.0, 100.0) # position
            shape.body.v = CP::Vec2.new(0.0, 0.0) # velocity
            shape.body.a = (3*Math::PI/2.0)

            @corpo = shape
      end

      def definirPosicao

            @posicaoCabecaX = @corpo.body.p.x
            @posicaoCabecaY = @corpo.body.p.y - @tronco.height

            @posicaoTroncoX = @corpo.body.p.x
            @posicaoTroncoY = @corpo.body.p.y

            @posicaoBracoX = @corpo.body.p.x + @cabeca.width/2 - @tronco.width/2 - 4
            @posicaoBracoY = @corpo.body.p.y

            @posicaoPernaX = @corpo.body.p.x
            @posicaoPernaY = @corpo.body.p.y + @tronco.height
      end
end

class Particula
      attr_reader :shape
      def initialize(posicao,imagem)

            @imagem = imagem
            @posicao = posicao
      end

      def draw
            @imagem.draw(@posicao.x,@posicao.y,1)
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
            @img = Gosu::Image.load_tiles(window, 'nove2.png', TILE_WIDTH, TILE_HEIGTH, true)

            #Recebendo o space
            @space = space

            #posiciona os elementos no world
            @posicoes = []
            posicionar()

      end

      def draw
            v=0
            l=0
            for layers in @camadas
                  for i in layers['data']
                        if i > 0 and i != 22
                              x = @posicoes[v][0]['posicao'][0].to_i
                              y = @posicoes[v][0]['posicao'][1].to_i
                              @img[i-1].draw(x, y, l)
                        elsif i == 22
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
                        if i == 22
                              x = @c * TILE_WIDTH
                              y = @r * TILE_HEIGTH
                              posicao = inserirSpace(x,y)
                              particula = Particula.new(posicao,@img[i-1])
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
            body = CP::Body.new_static
            body.p = CP::Vec2.new(x, y)

            shape_array = [CP::Vec2.new(-25.0, -25.0), CP::Vec2.new(-25.0, 25.0),
                           CP::Vec2.new(25.0, 25.0), CP::Vec2.new(25.0, -25.0)]
            shape = CP::Shape::Poly.new(body, shape_array, CP::Vec2.new(0,0))
            shape.collision_type = :particula

            shape.u = FRICTION
            shape.e = ELASTICITY

            @space.add_shape(shape)

            return body.p
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
            @jogador = Jogador.new(@physical.space)
      end

      def button_down(id)
            close if id == Gosu::KbEscape
      end

      def update
            6.times do
                  #Importante para da andamento nos elementos da fisica no space
                  @physical.space.step(@physical.dt)
            end
      end

      def draw
            @world.draw
            @jogador.draw
      end

end

GameWindow.new.show
