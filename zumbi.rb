class Zumbi
      def initialize(space)
            #Recuperando os pedaços do corpo do personagem
            @tiled = Tileset.new('assets/personagens.json')

            #Montando as  imagens das partes do corpo do personagem
            @cabeca = @tiled.frame(18)
            @r_cabeca = @tiled.frame(19)
            @tronco = @tiled.frame(17)

            #Angulo da movimetação dos braços
            @movimentacao = 0.0

            #Detalhe: 2 braços
            @bracoLeft = @tiled.frame(16)
            @bracoRight = @bracoLeft

            #Detalhe: 2 pernas
            @pernaLeft = @tiled.frame(20)
            @pernaRight = @pernaLeft

            #Definindo Varivaeis space, window
            @space = space
            # @window = win

            #Vamos definir como será o corpo e a shape do personagem
            definirCorpo()
      end

      def draw

            #Define a posição dos elementos do corpo do personagem
            definirPosicao()

            @cabeca.draw_rot(@posicaoCabecaX,@posicaoCabecaY,2,0,0.5,0.5)

            ###########################Desenha o tronco###################################
            @tronco.draw_rot(@posicaoTroncoX,@posicaoTroncoY,2,0,0,0)                    #

            ###########################Desenha os braços##################################
            @bracoLeft.draw_rot(@posicaoBracoX,@posicaoBracoY,1,@movimentacao,0.5,0)     #
                                                                                         #
            @bracoRight.draw_rot(@posicaoBracoX,@posicaoBracoY,3,-@movimentacao,0.5,0)   #
            ##############################################################################

            ###########################Desenha as Pernas##################################
            @pernaLeft.draw_rot(@posicaoPernaX,@posicaoPernaY,1,@movimentacao,0.5,0)     #
                                                                                         #
            @pernaRight.draw_rot(@posicaoPernaX,@posicaoPernaY,1,-@movimentacao,0.5,0)   #
            ##############################################################################
      end

      def right
            @body.apply_impulse(CP::Vec2.new(4.0, 0), CP::Vec2.new(0, 0))
      end

      #Define em quais posições vão ficar os membros do personagem
      def definirPosicao

            #Define a posição da cabeça
            @posicaoCabecaX = @body.p.x + @cabeca.width/2
            @posicaoCabecaY = @body.p.y + @cabeca.height/2

            #Define a posição do Tronco
            @posicaoTroncoX = @body.p.x + 2
            @posicaoTroncoY = @body.p.y + @cabeca.height

            #Define a posição dos Braços
            @posicaoBracoX = @body.p.x + @cabeca.width/2
            @posicaoBracoY = @body.p.y + @cabeca.height

            #Define a posição das Pernas
            @posicaoPernaX = @body.p.x + 12.5
            @posicaoPernaY = @body.p.y + @tronco.height + @cabeca.height
      end

      #Insere uma forma em volta do corpo do personagem para detectar colisoes e etc.
      def definirCorpo
            @body = CP::Body.new(10.0,1.0/0)

            @body.p = CP::Vec2.new(500, 100)

            @shape_verts = [CP::Vec2.new(0.0, 0.0), CP::Vec2.new(0.0, 70),
                            CP::Vec2.new(25, 70), CP::Vec2.new(25, 0.0)]
            @shape = CP::Shape::Poly.new(@body, @shape_verts, CP::Vec2.new(0,0))
            @shape.collision_type = :zumbi

            @shape.u = FRICTION
            @shape.e = ELASTICITY

            @space.add_body(@body)
            @space.add_shape(@shape)

      end

end
