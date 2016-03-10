class Jogador
<<<<<<< HEAD
      attr_accessor :body,:shape,:limites_mapa_jogador,:podePular,:particula,:podeSom,:espada
=======
      attr_accessor :body,:shape,:limites_mapa_jogador,:podePular,:particula,:podeSom, :vida,:atacado
>>>>>>> f4c46446c79dd05094dd494c24eaae747f157873
      def initialize(space,win,world)
            #Recuperando os pedaços do corpo do personagem
            @tiled = Tileset.new('assets/personagens.json')

            #Montando as  imagens das partes do corpo do personagem
            @cabeca = @tiled.frame(8)
            @r_cabeca = @tiled.frame(9)
            @tronco = @tiled.frame(7)

            #Angulo da movimetação dos braços
            @movimentacao = 0.0
            @movAtaque = 0

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
            #Essa variavel ajsuta a angulação da espada(lado direito) quando pula
            @ajustePuloEspada = 0

            #ataque com a espada
            @ataque = [0,0]

            #Vamos definir como será o corpo e a shape do personagem
            definirCorpo()

            #Verifica se o jogador pode pular
            @podePular = false
            @particula = ''

            #Sons do personagem
            @somEspada = Gosu::Sample.new("assets/sounds/sword.flac")
            @somVoz = Gosu::Sample.new("assets/sounds/human.wav")
            @somPulo = Gosu::Sample.new("assets/sounds/jump.wav")
            @podeSom = true
            #jogador aguenta 6 hits
            @vida = 6
            @atacado = false

      end

      #Movimentação para esquerda
      def left
            @body.apply_impulse(CP::Vec2.new(-4.0, 0), CP::Vec2.new(0, 0))
            movimentacaoMembros()
            #Lado para qual o personagem deve virar o rosto
            @QualLado = true
      end

      #Movimentação para Direita
      def right
            @body.apply_impulse(CP::Vec2.new(4.0, 0), CP::Vec2.new(0, 0))
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
            if @podePular and @body.p.y+60 < @particula.body.p.y
                  @body.apply_impulse(CP::Vec2.new(0.0, -700.0), CP::Vec2.new(0, 0))
                  @somPulo.play(0.5)
            end
            #Variavel para verificar se o personagem está no chão
            @podePular = false
      end

      #Vamos atacar os inimigos com a nossa espada :)
      def atacar
            @espada.atacando = true
            if @podeSom
                @somEspada.play(0.5)
<<<<<<< HEAD
                @somVoz.play(0.5)
=======
>>>>>>> f4c46446c79dd05094dd494c24eaae747f157873
                @podeSom = false
            end

            if @QualLado
                  @movAtaque = 100
            else
                  @movAtaque = -100
            end
      end
<<<<<<< HEAD

      #Faz com que o jogador fique em uma posição valida no mapa
      def posicaoValida
          if @body.p.x > 770
              @body.p.x = 770
          elsif @body.p.x < 0
              @body.p.x = 0
          end
      end

=======
      #em contato com monstro, afasta o jogador e diminui uma vida
      def podePerdeVida
          if @atacado
            @vida -= 1
            if @QualLado
                  @body.apply_impulse(CP::Vec2.new(-500.0, -200.0), CP::Vec2.new(0, 0))
            else
                  @body.apply_impulse(CP::Vec2.new(500.0, 200.0), CP::Vec2.new(0, 0))
            end
          end
          @atacado = false
      end
>>>>>>> f4c46446c79dd05094dd494c24eaae747f157873
      def draw

            podePerdeVida()
            #Fazer os membros balançarem para ambos os lados
            @ajustePuloEspada = 0
            if !@podePular
                  @movimentacao = 60
                  @ajustePuloEspada = -20
            elsif @movimentacao >= 60
                  @lado_movimentacao = -1
            elsif @movimentacao <= -60
                  @lado_movimentacao = 1
            end

            if @movAtaque != 0
                  movimentoAtaque
            end

            #Faz com que o personagem sempre esteja em uma posição valida
            posicaoValida()

            #Define a posição dos elementos do corpo do personagem
            definirPosicao()

            ##Depuração da angulação dos objetos na ponta da mao
            # puts "#{Math.cos(@movimentacao.gosu_to_radians)*@bracoLeft.height}---#{Math.sin(-@movimentacao.gosu_to_radians)*@bracoLeft.height}___#{@movimentacao}"
            # @cabeca.draw(@pontaMaoX,@pontaMaoY,10,0.5,0.5)

            #escolhe qual para que lado a cabeça estará virada
            if @QualLado
                  @cabeca.draw_rot(@posicaoCabecaX,@posicaoCabecaY,2,0,0.5,0.5)
                  @espada.posicaoEspada(-100,@movimentacao+@movAtaque/2-10)
            else
                  @r_cabeca.draw_rot(@posicaoCabecaX,@posicaoCabecaY,2,0,0.5,0.5)
                  @espada.posicaoEspada(0,@movimentacao+@movAtaque/2+@ajustePuloEspada)
            end

            ###########################Desenha o tronco###################################
            @tronco.draw_rot(@posicaoTroncoX,@posicaoTroncoY,2,0,0,0)                    #

            ###########################Desenha os braços##################################
            @bracoLeft.draw_rot(@posicaoBracoX,@posicaoBracoY,1,@movimentacao,0.5,0)     #
                                                                                         #
            @bracoRight.draw_rot(@posicaoBracoX,@posicaoBracoY,3,-@movimentacao+@movAtaque,0.5,0)   #
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

      def movimentoAtaque
            if @movAtaque > 0
                  @movAtaque -= 10
            else
                  @movAtaque += 10
            end
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
            @shape.object = self

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
            @pontaMaoY = @body.p.y + @tronco.height + Math.sin(-(@movimentacao-@movAtaque).gosu_to_radians)*@bracoLeft.height
            @pontaMaoX = @body.p.x + @tronco.width + Math.cos((@movimentacao-@movAtaque).gosu_to_radians)*@bracoLeft.height
      end

end
