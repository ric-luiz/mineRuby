#A classe world é responsavel por manipular os elementos do background do jogo
class World
      attr_reader :limites_mapa,:movendoMapaLeft,:movendoMapaRigth
      def initialize(window,space)
            #Definindo incrementador de linhas e colunas
            @r=0
            @c=0

            #Posições do mapa
            @map_x = 0
            @map_y = 0
            @limites_mapa = TOTAL_WIDTH_TILE - 800

            #Recuperando o Array com as camadas
            @camadas = MAP_WORLD['layers']

            #Cortando a imagem Em pequenos pedaços
            @img = Gosu::Image.load_tiles(window, 'assets/nove.png', TILE_WIDTH, TILE_HEIGTH, true)

            #Recebendo o space
            @space = space
            @window = window

            #posiciona os elementos no world.Aqui vamos definir previamente a posição de
            #todos os elementos que serão renderizados no background
            @posicoes = []
            posicionar()
      end

      #Faz o mapa ir para direita
      def map_right(x)
            if @limites_mapa >= 0 - x
                  @limites_mapa += x
                  @map_x += x
                  #Verifica se o mapa esta se movendo. É usada para as particulas
                  @movendoMapaRigth = true
            end
      end

      #Faz o mapa ir para esquerda
      def map_left(x)
            if @limites_mapa <= TOTAL_WIDTH_TILE - 800 - x
                  @limites_mapa += x
                  @map_x += x
                  #Verifica se o mapa esta se movendo. É usada para as particulas
                  @movendoMapaLeft = true
            end
      end

      def draw
            # l=Sobrescrita, ou z no gosu. Serve para que as camadas tenham a Sobrescrita correta
            # v=ValorPosição, Já que temos todas as posições dos elementos do mapa vamos recuperar
            v=0
            l=0
            for layers in @camadas
                  for i in layers['data']
                        if i > 0 and !PARTICULAS_ARRAY.include?(i)
                              x = @posicoes[v][0]['posicao'][0].to_i
                              y = @posicoes[v][0]['posicao'][1].to_i
                              @img[i-1].draw(x+@map_x, y+@map_y, l)
                        elsif PARTICULAS_ARRAY.include?(i)
                              #caso seja uma particula (objeto com fisica) desenhos ele
                              if @movendoMapaRigth
                                    @posicoes[v].body.p.x -= SPEED_MAP
                              elsif @movendoMapaLeft
                                    @posicoes[v].body.p.x += SPEED_MAP
                              end
                              @posicoes[v].draw
                        end
                        v+=1
                  end

                  l+=1
            end
            #setamos para false para que as particulas não continuem se mexendo caso a
            #movimentação nao estaja sendo efetuada
            @movendoMapaRigth = false
            @movendoMapaLeft = false
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
                        if PARTICULAS_ARRAY.include?(i)
                              x = @c * TILE_WIDTH
                              y = @r * TILE_HEIGTH
                              #Vamos ver se a particula é larva ou nao
                              tipo = :particula
                              if i == 64
                                tipo = :larva
                              end
                              inserirSpace(x,y,tipo)
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
      def inserirSpace(x,y,tipo)
            #As particulas são elementos solidos do mapa
            @body = CP::Body.new_static()

            @body.p = CP::Vec2.new(x, y)
            @forma = [CP::Vec2.new(0.0, 0.0), CP::Vec2.new(0.0, 50.0),
                     CP::Vec2.new(50.0, 50.0), CP::Vec2.new(50.0, 0.0)]
            shape = CP::Shape::Poly.new(@body, @forma, CP::Vec2.new(0,0))
            shape.collision_type = tipo
            shape.u = FRICTION
            shape.e = ELASTICITY
            shape.object = self

            @space.add_shape(shape)
      end
end
