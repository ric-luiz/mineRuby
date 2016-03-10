class Zumbi
      attr_accessor :body,:shape,:podePerdeVida,:atacado,:vida,:qualLado
      def initialize(space,win)
            #Recuperando os pedaços do corpo do personagem
            @tiled = Tileset.new('assets/personagens.json')

            #Montando as  imagens das partes do corpo do personagem
            @cabeca = @tiled.frame(18)
            @r_cabeca = @tiled.frame(19)
            @tronco = @tiled.frame(17)

            #Detalhe: 2 braços
            @bracoLeft = @tiled.frame(16)
            @bracoRight = @bracoLeft

            #Detalhe: 2 pernas
            @pernaLeft = @tiled.frame(20)
            @pernaRight = @pernaLeft

            #Definindo Varivaeis space, window
            @space = space
            @window = win

            #Vamos definir como será o corpo e a shape do personagem
            definirCorpo()

            #Angulo da movimetação dos braços
            @movimentacao = 0.0

            #Define para que lado a cabeça do personagem vai virar
            @lado_movimentacao = 5

            #Verifica se o zumbi foi atacado
            @atacado = false

            #vidas do Personagem
            @vida = 5
            #pode perder vida?
            @podePerdeVida = true

            #Sons do zumbi
            @somZumbi = Gosu::Sample.new("assets/sounds/zombie.wav")
            @tempoSom = 0
            @podeEmitirSom = true
      end

      #Ir para direita
      def right
            @body.p.x += 1
            movimentacaoMembros()
            #Lado para qual o personagem deve virar o rosto
            @qualLado = false
      end

      #Foi Atacado?
      def atacado
            if @atacado
                  if @body.p.x < @posicaoXJogador
                        @body.apply_impulse(CP::Vec2.new(-500.0, -200.0), CP::Vec2.new(0, 0))
                  else
                        @body.apply_impulse(CP::Vec2.new(500.0, -200.0), CP::Vec2.new(0, 0))
                  end

                  retirarVida()
            end
            @atacado = false
      end

      #Ir para esquerda
      def left
            @body.p.x -= 1
            movimentacaoMembros()
            #Lado para qual o personagem deve virar o rosto
            @qualLado = true
      end

      #ficar parado
      def stand
            @movimentacao = 0.0
      end

      #Retirar A vida do Zumbi
      def retirarVida
            if @podePerdeVida
              @vida -= 1
              @podePerdeVida = false
            end
      end

      #Persiga o jogador
      def perseguir(jogX,jogY)
            if Gosu.distance(@body.p.x,@body.p.y,jogX,jogY) <= 300
                  @posicaoXJogador = jogX                
                  if @body.p.x+10 < @posicaoXJogador
                        right()
                  elsif @body.p.x-10 > @posicaoXJogador
                        left()
                  else
                        stand()
                  end
            else
                  stand()
            end
      end

      def draw

            atacado()

            #Fazer os membros balançarem para ambos os lados
            if @movimentacao >= 60
                  @lado_movimentacao = -5
            elsif @movimentacao <= -60
                  @lado_movimentacao = 5
            end

            #Define a posição dos elementos do corpo do personagem
            definirPosicao()

            #escolhe qual para que lado a cabeça estará virada
            if @qualLado
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


            # Esse trecho de codigo é usado para depuração das shapes no jogador
            # @window.draw_quad(@body.p.x + @shape.vert(3).x, @body.p.y + @shape.vert(3).y, @color,
            #              @body.p.x + @shape.vert(2).x, @body.p.y + @shape.vert(2).y, @color,
            #              @body.p.x + @shape.vert(0).x, @body.p.y + @shape.vert(0).y, @color,
            #              @body.p.x + @shape.vert(1).x, @body.p.y + @shape.vert(1).y, @color,
            #              z=3)
      end

      def sons
          @tempoSom = Gosu::milliseconds()/1000
          #Emite o som do zumbi Automaticamente a cada 10 segundos
          if @tempoSom%10 == 0 and @podeEmitirSom and @tempoSom != 0 then
              @somZumbi.play(0.5)
              @podeEmitirSom = false
          end

          #Esse bloco de codigo garante que seja possivel emitir o som a cada 10 segundos
          if @tempoSom%11 == 0
              @podeEmitirSom = true
          end
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

            @body.p = CP::Vec2.new(500, 100)

            @shape_verts = [CP::Vec2.new(0.0, 0.0), CP::Vec2.new(0.0, 70),
                            CP::Vec2.new(25, 70), CP::Vec2.new(25, 0.0)]
            @shape = CP::Shape::Poly.new(@body, @shape_verts, CP::Vec2.new(0,0))
            @shape.collision_type = :zumbi

            @shape.u = FRICTION
            @shape.e = ELASTICITY
            #Passa para dentro do chipmunk o objeto zumbi
            @shape.object = self

            @space.add_body(@body)
            @space.add_shape(@shape)

            # #Usado para depuração das shapes no jogo
            # @color = Gosu::Color.new(255,0,255,0)
            # # the more elastic the greener
            # @color.saturation *= ELASTICITY
            # @color.value *= ELASTICITY

      end

end
