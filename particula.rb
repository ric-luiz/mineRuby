#As particulas são elementos do mapa que o personagem se choca
class Particula
      attr_reader :body
      def initialize(posicao,imagem,forma,win)
            @window = win
            @shape_verts = forma
            @imagem = imagem
            @body = posicao

            # # Codigo que faz parte da impressão das formas nas shapes
            # @color = Gosu::Color.new(255,0,255,0)
            # # the more elastic the greener
            # @color.saturation *= ELASTICITY
            # @color.value *= ELASTICITY
      end

      def draw
            @imagem.draw_rot(@body.p.x, @body.p.y, 1, 0, 0.0, 0.0)

            # Codigo para depuração das shapes. Esse codigo imprime o desenho das formas no cenario
            # @window.draw_quad(@body.p.x + @shape_verts[3].x, @body.p.y + @shape_verts[3].y, @color,
            #              @body.p.x + @shape_verts[2].x, @body.p.y + @shape_verts[2].y, @color,
            #              @body.p.x + @shape_verts[0].x, @body.p.y + @shape_verts[0].y, @color,
            #              @body.p.x + @shape_verts[1].x, @body.p.y + @shape_verts[1].y, @color,
            #              z=3)
      end
end
