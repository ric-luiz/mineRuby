class Esqueleto
      attr_accessor :body
      def initialize(space)
            #Recuperando os pedaços do corpo do personagem
            @tiled = Tileset.new('assets/personagens.json')

            #Montando as  imagens das partes do corpo do personagem
            @cabeca = @tiled.frame(13)
            @r_cabeca = Gosu::Image.new('skeleton_headr.png')
            @tronco = @tiled.frame(12)

            #Angulo da movimetação dos braços
            @movimentacao = 0.0

            #Detalhe: 2 braços
            @bracoLeft = @tiled.frame(11)
            @bracoRight = @bracoLeft

            #Detalhe: 2 pernas
            @pernaLeft = @tiled.frame(15)
            @pernaRight = @pernaLeft

            #Definindo Varivaeis space, window
            @space = space
            # @window = win

            #Vamos definir como será o corpo e a shape do personagem
            definirCorpo()

            #Angulo da movimetação dos braços
            @movimentacao = 0.0

            #Define para que lado a cabeça do personagem vai virar
            @lado_movimentacao = 1
      end

      def right
            @body.p.x +=0.2
            movimentacaoMembros()
            #Lado para qual o personagem deve virar o rosto
            @QualLado = false
      end

      def left
            @body.p.x -=0.2
            movimentacaoMembros()
            #Lado para qual o personagem deve virar o rosto
            @QualLado = true
      end

      def stand
            @movimentacao = 0.0
      end

      def jump

      end

      def perseguir(jogX,jogY)
            if Gosu.distance(@body.p.x,@body.p.y,jogX,jogY) <= 300
                  if @body.p.x < jogX
                        right()
                  else
                        left()
                  end
            else
                  stand()
            end
      end

      def draw

            #Fazer os membros balancarem para ambos os lados
            if @movimentacao >= 60
                  @lado_movimentacao = -1
            elsif @movimentacao <= -60
                  @lado_movimentacao = 1
            end

            #Define a posicao dos elementos do corpo do personagem
            definirPosicao()

            #escolhe qual para que lado a cabeca estara virada
            if @QualLado
                  @cabeca.draw_rot(@posicaoCabecaX,@posicaoCabecaY,2,0,0.5,0.5)
            else
                  @r_cabeca.draw_rot(@posicaoCabecaX,@posicaoCabecaY,2,0,0.5,0.5)
            end

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

      #Fazendo os membro se mexerem
      def movimentacaoMembros
            @movimentacao += @lado_movimentacao
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

            @body.p = CP::Vec2.new(400, 50)

            @shape_verts = [CP::Vec2.new(0.0, 0.0), CP::Vec2.new(0.0, 70),
                            CP::Vec2.new(25, 70), CP::Vec2.new(25, 0.0)]
            @shape = CP::Shape::Poly.new(@body, @shape_verts, CP::Vec2.new(0,0))
            @shape.collision_type = :esqueleto

            @shape.u = FRICTION
            @shape.e = ELASTICITY

            @space.add_body(@body)
            @space.add_shape(@shape)

      end



end
