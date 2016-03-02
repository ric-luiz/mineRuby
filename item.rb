class Item
      def initialize(space)
            @tiled = Tileset.new('assets/item.json')
            @espada = @tiled.frame(0)
            #Variavel que server para definir para qual lado a espada vai ser desenhada
            @paraQualLado = 0
            #Usado para inserir a angulação da espada durante o movimento do braço do personagem
            @angulo = 0
      end

      def draw(x,y)
            @espada.draw_rot(x,y,2,@angulo,0.2,0.8)
      end

      #Este Metodo define a posição da espada na mão do personagem. Pode ser para a Esquerda ou Direita
      def posicaoEspada(direcao,angulo)
            @paraQualLado = direcao
            @angulo = -angulo + @paraQualLado
      end
end
