#!/usr/bin/env ruby

# Falling squares Gosu + Chipmunk test by Leonardo Boiko <leoboiko@gmail.com>
# Public domain.

require 'rubygems'
require 'ostruct'
require 'optparse'
require 'rational'

require 'gosu'
require 'chipmunk'


BLACK = 0xff000000
WHITE = 0xffffffff

# It's weird that ruby has no builtin constant for infinity (^^);
INFINITY = 1.0/0


# Convenience methods for converting between Gosu degrees, radians,
# and Vec2 vectors.
#
class Numeric
  def gosu_to_radians
    (self - 90) * Math::PI / 180.0
  end

  def radians_to_gosu
    self * 180.0 / Math::PI + 90
  end

  def radians_to_vec2
    CP::Vec2.new(Math::cos(self), Math::sin(self))
  end
end


# Unlike the other gosu-chipmunk tutorials, I like to keep shape and
# drawing code in the game objects, not in the universe.  Therefore,
# game objects need a reference to their containing world.

# Static line object used for walls and floor.
#
# I think you could use a single body for all of them like in
# MoreChipmunkAndRmagick.rb, but whatever.
#
class Wall
  attr_reader :world, :body, :shape, :a, :b
  attr_accessor :color

  # Pos is the starting position; shape_a and shape_b are the
  # endpoints of the wall's line shape.
  #
  # Don't confuse shape and position like I did! Shapes are in
  # object-local coordinates (I think?).  Consider them independent
  # from position.
  #
  def initialize(world, pos, shape_a, shape_b, color)
    @world = world
    @color = color
    @a = shape_a
    @b = shape_b

    @body = CP::Body.new(INFINITY, INFINITY)
    @body.p = pos
    @body.v = CP::Vec2.new(0, 0)
#    @body.a = ?

    @shape = CP::Shape::Segment.new(@body, @a, @b, 1)
    @shape.e = 0
    @shape.u = 1


    @world.space.add_static_shape(@shape)
  end

  def draw
    @world.draw_line(@body.p.x + a.x, @body.p.y + a.y, @color,
                     @body.p.x + b.x, @body.p.y + b.y, @color,
                     z=0)
  end

end


class Square

  attr_reader :world, :body, :shape, :color

  # Elasticity is a float between 0 and 1; 1 is perfectly elastic.
  #
  def initialize(world, pos, elasticity)
    @win = world

    @body = CP::Body.new(10,200)
    @body.p = pos
    @body.v = CP::Vec2.new(0, 0)
    @body.a = (3*Math::PI/2.0)

    # Anti-clockwise, like Chipmunk wants.
    @shape_verts = [
                    CP::Vec2.new(-10, 10),
                    CP::Vec2.new(10, 10),
                    CP::Vec2.new(10, -10),
                    CP::Vec2.new(-10, -10),
                   ]


    @shape = CP::Shape::Poly.new(@body,
                                 @shape_verts,
                                 CP::Vec2.new(0,0)) # FIXME: really?

    @shape.e = elasticity
    @color = Gosu::Color.new(255,
                             0,
                             255,
                             0)
    # the more elastic the greener
    @color.saturation *= elasticity
    @color.value *= elasticity

    @shape.u = 1

    @win.space.add_body(@body)
    @win.space.add_shape(@shape)

  end

  def draw
    # Order the vertices in "read order" like Gosu wants.  Recall that
    # top = -10, left = -10.
    #

    # the naive drawing method below doesn't take rotation into
    # account; it would draw unrotated squares in the screen while
    # they invisibly collided as if rotated.
    #
    # @win.draw_quad(@body.p.x + @shape_verts[3].x, @body.p.y + @shape_verts[3].y, @color,
    #                @body.p.x + @shape_verts[2].x, @body.p.y + @shape_verts[2].y, @color,
    #                @body.p.x + @shape_verts[0].x, @body.p.y + @shape_verts[0].y, @color,
    #                @body.p.x + @shape_verts[1].x, @body.p.y + @shape_verts[1].y, @color,
    #                z=0)

    top_left, top_right, bottom_left, bottom_right = self.rotate
    @win.draw_quad(top_left.x, top_left.y, @color,
                   top_right.x, top_right.y, @color,
                   bottom_left.x, bottom_left.y, @color,
                   bottom_right.x, bottom_right.y, @color,
                   z=0)
  end

  # Return current points at [top left, top right, bottom left, bottom right]
  # according to current body rotation.
  #
  # Math for rotation by Julian Raschke.  In the real world it would
  # probably be much easier to load an image instead.
  #
  def rotate

    half_diagonal = Math.sqrt(2) * 10 # 10 = half side
    [-45, +45, -135, +135].collect do |angle|
      CP::Vec2.new(@body.p.x + Gosu::offset_x(@body.a.radians_to_gosu + angle,
                                              half_diagonal),

                   @body.p.y + Gosu::offset_y(@body.a.radians_to_gosu + angle,
                                              half_diagonal))
    end
  end

end


class FallingSquaresDemo < Gosu::Window
  attr_reader :w, :h, :pad, :tick
  attr_reader :space, :walls, :squares

  # This class method keeps default options in a single place.
  def FallingSquaresDemo::default_options
    return OpenStruct.new(:w => 640,
                          :h => 480,
                          :padding => 20,
                          :tick => Rational(1,60),
                          :nsquares => (20 + rand(30)),
                          :fullscreen => false)
  end

  def initialize(o = FallingSquaresDemo::default_options)
    @w = o.w
    @h = o.h
    @pad = o.padding
    @tick = o.tick

    super(@w, @h, o.fullscreen, 16)
    self.caption = "Falling Squares demo"

    @space = CP::Space.new
    @space.gravity = CP::Vec2.new(0, 100)

    @walls = []

    # If the wall definitions look confusing, try to consider them
    # with no padding first.

    # floor
    @walls << Wall.new(self,
                       CP::Vec2.new(@pad, @h - @pad),
                       CP::Vec2.new(0, 0),
                       CP::Vec2.new(@w - (@pad * 2), 0),
                       BLACK)

    # left wall
    @walls << Wall.new(self,
                       CP::Vec2.new(@pad, @pad),
                       CP::Vec2.new(0, 0),
                       CP::Vec2.new(0, @h - (@pad * 2)),
                       BLACK)

    # right wall
    @walls << Wall.new(self,
                       CP::Vec2.new(@w - @pad, @pad),
                       CP::Vec2.new(0, 0),
                       CP::Vec2.new(0, @h - (@pad * 2)),
                       BLACK)

    @squares = []
    o.nsquares.times do
      # with no padding, they may fall outside the walls and out of
      # the screen.  that's intended ;)
      s = Square.new(self,
                     CP::Vec2.new(rand(@w),
                                  rand(@h)),
                     rand())

      s.body.v = CP::Vec2.new(-50 + rand(101),
                              0)
      @squares << s
    end

    puts self
  end

  def draw
    # white background
    draw_quad(0, 0, WHITE,
              @w, 0, WHITE,
              0, @h, WHITE,
              @w, @h, WHITE,
              z=0)

    @walls.each do |wall|
      wall.draw
    end
    @squares.each do |square|
      square.draw
    end
  end

  def update
    @space.step(@tick)
  end

  def button_down(id)
    if id == Gosu::Button::KbEscape
      close
    end
  end

  def to_s
    "#{@w}x#{@h} world (padding #{@pad})," +
      " #{@squares.size} squares"
  end
end


if __FILE__ == $0

  srand(Time.now.usec)

  opt = FallingSquaresDemo::default_options

  OptionParser.new { |parser|
    parser.banner = "Usage: #{$0} [options]"
    parser.banner += "\nOptions:"

    parser.on('-f', '--fullscreen',
          "run fullscreen (default: #{opt.fullscreen}") do |f|
      opt.fullscreen = f
    end

    parser.on('-w', '--width <integer>',
          "screen width (default: #{opt.w})") do |w|
      opt.w = w.to_i
    end

    parser.on('-h', '--height <integer>',
          "screen height (default: #{opt.h})") do |h|
      opt.h = h.to_i
    end

    parser.on('-p', '--padding <integer>',
              'padding between walls and window border' +
              " (default: #{opt.padding})") do |p|
      opt.padding = p.to_i
    end

    parser.on('-n', '--nsquares <integer>',
          "number of squares in simulation (default: #{opt.nsquares})") do |n|
      opt.nsquares = n.to_i
    end

    parser.on('-t',  '--tick <float>',
              "Time increment over which to apply a physics 'step'" +
              " (default: #{opt.tick})") do |t|
      opt.tick = t.to_f
    end

    }.parse!

  game = FallingSquaresDemo.new(opt)
  game.show
end
