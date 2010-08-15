#!/usr/bin/ruby
# Author: Chris Eigner
# Description: Conway's Game of Life in ruby.
# Arguments: height, width, init fill factor in dec form
# Example1: ruby gol.rb 100 100 0.2     => 100 x 100 game board, 20% of cells are initialized "alive"
# Example2: ruby gol.rb 500 500 0.1     => 500 x 500 game board, 10% of cells are initialized "alive"

require 'rubygems'

class GoL
  
  attr_accessor :height, :width, :matrix
  
  def initialize(h, w)
    @height = h
    @width  = w
    @matrix = Array.new(@height) { Array.new(@width) }.map { |row| row.fill 0 }
    @empty  = Array.new(@height) { Array.new(@width) }.map { |row| row.fill 0 }
    populate_matrix_with_random(ARGV[2].to_f)       # should be low percentage in dec form: 0.2, 0.3 work well
  end
  
  def run
    loop do
      update
      draw
      exit if all_dead?
    end
  end
  
  def update
    to_be_killed = []
    to_be_risen = []
    
    @matrix.each_with_index do |row, x|
      row.each_with_index do |cell, y|
        state = cell == 0 ? :dead : :alive
        ns = neighbors(x, y)    # fetch neighbors of cell...
        alive = ns.collect { |n| val = @matrix[n[0]][n[1]]; n if val == 1 }.compact     # count alive neighbors
        count = alive.length
        
        # begin state machine; collect those that need updating
        if count < 2 and state == :alive
          to_be_killed << [x,y]
        elsif count > 3 and state == :alive
          to_be_killed << [x,y]
        elsif count == 3 and state == :dead 
          to_be_risen << [x,y]
        end
      end
    end
    
    # update matrix with new values
    to_be_killed.each { |c| @matrix[c[0]][c[1]] = 0 }
    to_be_risen.each  { |c| @matrix[c[0]][c[1]] = 1 }
  end
  
  private
  
  def neighbors(x,y)
    [ 
      [ x, y + 1], [x + 1, y + 1], [x + 1, y], [x + 1, y - 1], [x, y - 1], [x - 1, y - 1], [x - 1, y], [x - 1, y + 1]
    ].delete_if { |item| item.include? @height or item.include? @width }    # delete out of bounds indeces
  end
  
  def draw
    @matrix.each do |row|
      row.each { |cell| cell == 1 ? print("#") : print(" ") }
      puts ""
    end
  end
  
  def populate_matrix_with_random(dec)
    ( @height * @width * dec ).floor.times { @matrix[rand @height][rand @width] = 1 }
  end
  
  def all_dead?
    @matrix == @empty 
  end
end

g = GoL.new( ARGV[0].to_i, ARGV[1].to_i )
g.run
