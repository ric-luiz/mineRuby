#As particulas são elementos do mapa que o personagem se choca
class Particula
      attr_reader :body
      def initialize(posicao,imagem,forma,win)
            @window = win
            @shape_verts = forma
            @imagem = imagem
            @body = posicao
      end

      def draw
            @imagem.draw_rot(@body.p.x, @body.p.y, 1, 0, 0.0, 0.0)
      end
end
