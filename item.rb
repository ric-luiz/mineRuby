class Item
      def initialize(space)
            @tiled = Tileset.new('assets/item.json')
            @espada = @tiled.frame(0)
            @a=0
      end

      def draw(x,y)
            @a +=1
            if @a >= 60
                  @a = 0
            end
            @espada.draw_rot(x,y,2,@a,0.2,0.8)
      end
end
