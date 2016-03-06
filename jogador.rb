class Jogador
      attr_reader :body,:shape,:limites_mapa_jogador
      def initialize(space,win,world)
            #Recuperando os pedaços do corpo do personagem
            @tiled = Tileset.new('assets/personagens.json')

            #Montando as  imagens das partes do corpo do personagem
            @cabeca = @tiled.frame(8)
            @r_cabeca = @tiled.frame(9)
            @tronco = @tiled.frame(7)

            #Angulo da movimetação dos braços
            @movimentacao = 0.0

            #Define para que lado a cabeça do personagem vai virar
            @lado_movimentacao = 1

            #Detalhe: 2 braços
            @bracoLeft = @tiled.frame(6)
            @bracoRight = @bracoLeft

            #Detalhe: 2 pernas
            @pernaLeft = @tiled.frame(10)
            @pernaRight = @pernaLeft

            #Definindo Varivaeis space, window e world
            @space = space
            @window = win
            # @world = world

            #Instanciando Arma do Jogador
            @espada = Item.new(@space,:espada,@window)

            #Vamos definir como será o corpo e a shape do personagem
            definirCorpo()

            #Detectando colisões. Esta sendo usada para os saltos
            @space.add_collision_func(:jogador, :particula) do |jog, par|
               @par = par
               @podePular = true
            end
      end

      #Movimentação para esquerda
      def left
            #Verifica se o personagem ainda pode anda para esquerda, ou seja se ele chegou
            #no limite esquerdo do mapa
            if @body.p.x > 0
                  @body.apply_impulse(CP::Vec2.new(-4.0, 0), CP::Vec2.new(0, 0))
            else
                  @body.p.x = 0
            end
            movimentacaoMembros()
            #Lado para qual o personagem deve virar o rosto
            @QualLado = true
      end

      #Movimentação para Direita
      def right
            #Verifica se o personagem ainda pode anda para direita, ou seja se ele chegou
            #no limite direito do mapa
            if @body.p.x < 770
                  @body.apply_impulse(CP::Vec2.new(4.0, 0), CP::Vec2.new(0, 0))
            else
                  @body.p.x = 770
            end
            movimentacaoMembros()
            #Lado para qual o personagem deve virar o rosto
            @QualLado = false
      end

      #Ficar na Posição Parada
      def stand
            if @movimentacao != 0.0
                  if @movimentacao < 0
                        @movimentacao += 1
                  else
                        @movimentacao -= 1
                  end
            end
      end

      #Ação de pulo do personagem
      def jump
            if @podePular and @body.p.y+60 < @par.body.p.y
                  @body.apply_impulse(CP::Vec2.new(0.0, -700.0), CP::Vec2.new(0, 0))
            end
            #Variavel para verificar se o personagem está no chão
            @podePular = false
      end

      def draw
            #Fazer os membros balançarem para ambos os lados
            if @movimentacao >= 60
                  @lado_movimentacao = -1
            elsif @movimentacao <= -60
                  @lado_movimentacao = 1
            end

            #Define a posição dos elementos do corpo do personagem
            definirPosicao()

            ##Depuração da angulação dos objetos na ponta da mao
            # puts "#{Math.cos(@movimentacao.gosu_to_radians)*@bracoLeft.height}---#{Math.sin(-@movimentacao.gosu_to_radians)*@bracoLeft.height}___#{@movimentacao}"
            # @cabeca.draw(@pontaMaoX,@pontaMaoY,10,0.5,0.5)

            #escolhe qual para que lado a cabeça estará virada
            if @QualLado
                  @cabeca.draw_rot(@posicaoCabecaX,@posicaoCabecaY,2,0,0.5,0.5)
                  @espada.posicaoEspada(-120,@movimentacao)
            else
                  @r_cabeca.draw_rot(@posicaoCabecaX,@posicaoCabecaY,2,0,0.5,0.5)
                  @espada.posicaoEspada(0,@movimentacao)
            end

            ###########################Desenha o tronco###################################
            @tronco.draw_rot(@posicaoTroncoX,@posicaoTroncoY,2,0,0,0)                    #

            ###########################Desenha os braços##################################
            @bracoLeft.draw_rot(@posicaoBracoX,@posicaoBracoY,1,@movimentacao,0.5,0)     #
                                                                                         #
            @bracoRight.draw_rot(@posicaoBracoX,@posicaoBracoY,3,-@movimentacao,0.5,0)   #
            ##############################################################################

            ###########################Desenha a espada do personagem#####################
            @espada.draw(@pontaMaoX,@pontaMaoY)                                          #

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

      #Insere uma forma em volta do corpo do personagem para detectar colisoes e etc.
      def definirCorpo
            @body = CP::Body.new(10.0,1.0/0)

            @body.p = CP::Vec2.new(800, 100)

            @shape_verts = [CP::Vec2.new(0.0, 0.0), CP::Vec2.new(0.0, 70),
                            CP::Vec2.new(25, 70), CP::Vec2.new(25, 0.0)]
            @shape = CP::Shape::Poly.new(@body, @shape_verts, CP::Vec2.new(0,0))
            @shape.collision_type = :jogador

            @shape.u = FRICTION
            @shape.e = ELASTICITY

            @space.add_body(@body)
            @space.add_shape(@shape)

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

            #Uso Conceitos da trigonometria para calular a ponta da mao através do angulo
            @pontaMaoY = @body.p.y + @tronco.height + Math.sin(-@movimentacao.gosu_to_radians)*@bracoLeft.height
            @pontaMaoX = @body.p.x + @tronco.width + Math.cos(@movimentacao.gosu_to_radians)*@bracoLeft.height
      end

end
