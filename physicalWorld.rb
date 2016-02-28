#A classe PhysicalWorld serve para definir qualquer aspecto da fisica do jogo
class PhysicalWorld
      attr_accessor :space
      attr_accessor :dt
      def initialize
            @space = CP::Space.new
            @space.damping = DAMPING
            @space.gravity = CP::Vec2.new(0.0,GRAVITY)

            # Time increment over which to apply a physics "step" ("delta t")
            @dt = (1.0/60.0)
      end
end
