class Item
      def initialize(space,tipo,window)
            @tiled = Tileset.new('assets/item.json')
            @espada = @tiled.frame(0)

            #Variavel que server para definir para qual lado a espada vai ser desenhada
            @paraQualLado = 0

            #Usado para inserir a angulação da espada durante o movimento do braço do personagem
            @angulo = 0

            #Definindo o space para a classe
            @space = space

            #Definindo qual o tipo de item
            @tipo = tipo

            #Constrir o corpo do item no space
            definirCorpo()

            #Evita colisões com o jogador
            @space.add_collision_func(:jogador, @tipo, &nil)

            # #Usado para depuração de shapes do chipmunk
            @window = window
      end

      def draw(x,y)
            @body.p.x = x
            @body.p.y = y

            @espada.draw_rot(@body.p.x-5,@body.p.y,2,@body.a,0.2,0.8)

            # # Esse trecho de codigo é usado para depuração das shapes no jogador
            # @window.draw_quad(@body.p.x + @shape.vert(3).x, @body.p.y + @shape.vert(3).y,       @color,@body.p.x + @shape.vert(2).x, @body.p.y + @shape.vert(2).y, @color,
            # @body.p.x + @shape.vert(0).x, @body.p.y + @shape.vert(0).y, @color,
            # @body.p.x + @shape.vert(1).x, @body.p.y + @shape.vert(1).y, @color,3)
      end

      #Este Metodo define a posição da espada na mão do personagem. Pode ser para a Esquerda ou Direita
      def posicaoEspada(direcao,angulo)
            @paraQualLado = direcao
            @body.a = -angulo + @paraQualLado

            #Vamos remontar as formas a partir do lado para o qual o corpo esta direcionado
            if direcao < 0
                  @shape.set_verts!(@forma2,CP::Vec2.new(0, 0))
                  @space.add_shape(@shape)
            else
                  @shape.set_verts!(@forma,CP::Vec2.new(0, 0))
                  @space.add_shape(@shape)
            end
      end

      def definirCorpo()
            @body = CP::Body.new_static()
            @body.a = 0.0
            @body.p = CP::Vec2.new(0, 0)

            #Infelizemente as forma não acompanham o angulo do corpo. Por isso coloco 2 formas.
            #Uma para o lado esquerdo e outra para o direito
            #lado esquerdo
            @forma2 = [CP::Vec2.new(0.0, -30.0), CP::Vec2.new(0.0, -20.0),
                      CP::Vec2.new(30.0, 0.0), CP::Vec2.new(35.0, -25.0)]
            #Lado esquerdo
            @forma = [CP::Vec2.new(30.0, -20.0), CP::Vec2.new(30.0, -35.0),
                        CP::Vec2.new(0.0, -10.0), CP::Vec2.new(0.0, 5.0)]

            @shape = CP::Shape::Poly.new(@body, @forma, CP::Vec2.new(0,0))
            @shape.collision_type = @tipo

            @space.add_shape(@shape)

            # #Usado para depuração das shapes no jogo
            # @color = Gosu::Color.new(255,0,255,0)
            # # the more elastic the greener
            # @color.saturation *= ELASTICITY
            # @color.value *= ELASTICITY
      end
end
