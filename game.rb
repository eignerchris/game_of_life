#!/usr/bin/ruby

require 'rubygems'
require 'rubygame'
require 'pp'

class GoLMatrix
  
  attr_accessor :height, :width, :matrix
  
  def initialize(h, w)
    @height = h
    @width = w
    @matrix = Array.new(@height) { Array.new(@width) }.map { |row| row.fill 0 }
    @empty = Array.new(@height) { Array.new(@width) }.map { |row| row.fill 0 }  
    (@height * @width * 0.20 ).floor.times { @matrix[rand @height][rand @width] = 1 }
  end
  
  def iterate
    update
    draw
    exit if all_dead?
    return @matrix
  end
  
  def update
    to_be_killed = []
    to_be_risen = []
    @matrix.each_with_index do |row, x|
      row.each_with_index do |cell, y|
        state = cell == 0 ? :dead : :alive
        ns = neighbors(x, y)
        alive = ns.collect { |n| val = get_value(n[0], n[1]); n if val == 1 }.compact
        count = alive.length
        if count < 2 and state == :alive
          to_be_killed << [x,y] 
        elsif count > 3 and state == :alive
          to_be_killed << [x,y]
        elsif count == 3 and state == :dead 
          to_be_risen << [x,y]
        end
      end
    end
    
    to_be_killed.each { |c| @matrix[c[0]][c[1]] = 0 }
    to_be_risen.each { |c| @matrix[c[0]][c[1]] = 1 }
  end
  
  private

  def get_value(x,y)
    @matrix[x - 1][y - 1]
  end

  def neighbors(x,y)
    [ 
      [ x, y + 1], [x + 1, y + 1], [x + 1, y], [x + 1, y - 1], [x, y - 1], [x - 1, y - 1], [x - 1, y], [x + 1, y - 1]
    ].delete_if { |item| item.first == @height + 1 or item.last ==  @width + 1 or item.include? -1 }
  end
  
  def draw
    @matrix.each do |row|
      row.each do |cell|
        cell == 1 ? print("#") : print(" ")
      end
      puts ""
    end
  end
  
  def all_dead?
    (@matrix <=> @empty) == 0 ? true : false
  end
end

class Game
  include Rubygame
  
  def initialize(matrix)
    @matrix = matrix
  	@screen = Rubygame::Screen.new [@matrix.height, @matrix.width], 0, [Rubygame::HWSURFACE, Rubygame::DOUBLEBUF]
  	@screen.fill( :black )
		@screen.title = "Conway's Game of Life"
		@queue = Rubygame::EventQueue.new
		@clock = Rubygame::Clock.new
  	end
  	
  def run
  	loop do
  	  start = Time.now
			@matrix.iterate
			draw
			@clock.tick
			puts "#{Time.now - start} seconds"
		end
	end
  	
  def update
  	@queue.each do |ev|
  		case ev
  		when Rubygame::QuitEvent
  			Rubygame.quit
  			exit
  		end
  	end
  end

  def draw
    @matrix.matrix.each_with_index do |row, x|
      row.each_with_index do |cell, y|
        px = Surface.new( [1,1] ) 
        cell == 1 ? px.fill( :white ) : px.fill( :black )
        rect = Rubygame::Rect.new( x, y, 1, 1 )
        rect.center = [x, y]
        px.blit( @screen, rect )
      end
    end
    
    @screen.update
  end
end

m = GoLMatrix.new( ARGV[0], ARGV[1])

loop do
  m.run
end

#Game.new( m ).run