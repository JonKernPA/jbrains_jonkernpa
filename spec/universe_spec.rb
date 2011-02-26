require 'rubygems'
require 'spec'
#require 'source/universe'

class Cell
  def initialize(alive)
    @alive = alive
  end
  
  def self.alive
    self.new(true)
  end
  
  def self.dead
    self.new(false)
  end
  
  def evolve(live_neighbors)
    @alive = live_neighbors_needed_to_live.include?(live_neighbors)
  end
  
  def live_neighbors_needed_to_live
    alive? ? (2..3) : [3]
  end
  
  def alive?
    @alive
  end
end

class Population
  def initialize(grid)
    @grid = grid
  end
  
  def self.with(grid)
    self.new(grid)
  end
  
  def evolve
    center_cell.evolve(live_neighbors_of(center_cell))
  end
  
  def live_neighbors_of(cell)
    alive_cells = neighborhood_of(cell).select { |each| each.alive? }
    alive_cells.size - (cell.alive? ? 1 : 0)
  end
  
  def neighborhood_of(cell)
    @grid.flatten
  end
  
  def center_cell
    @grid[1][1]
  end
end

def alive
  Cell.alive
end

def dead
  Cell.dead
end

describe "Evolving the universe a single tick" do
  context "evolving the entire population" do
    def mock_cell_expecting_evolve
      cell = mock("cell").as_null_object
      cell.should_receive(:evolve)
      cell
    end
    
    it "attempts to evolve each cell once" do
      population = Population.with([[mock_cell_expecting_evolve, mock_cell_expecting_evolve, mock_cell_expecting_evolve], 
      [mock_cell_expecting_evolve, mock_cell_expecting_evolve, mock_cell_expecting_evolve], 
      [mock_cell_expecting_evolve, mock_cell_expecting_evolve, mock_cell_expecting_evolve]])
      
      population.evolve
    end
  end
  
  context "evolving only the center cell" do
    context "center cell starts alive" do
      it "stays alive with two live neighbors" do
        center_cell = Cell.alive
        Population.with([[alive, alive, dead], [dead, center_cell, dead], [dead, dead, dead]]).evolve
        center_cell.should be_alive
      end

      it "dies with four live neighbors" do
        center_cell = Cell.alive
        Population.with([[alive, alive, alive], [alive, center_cell, dead], [dead, dead, dead]]).evolve
        center_cell.should_not be_alive
      end
  
      it "stays alive with three live neighbors" do
        center_cell = Cell.alive
        Population.with([[alive, alive, alive], [dead, center_cell, dead], [dead, dead, dead]]).evolve
        center_cell.should be_alive
      end
    end
  
    context "center cell starts dead" do
      it "comes alive with three live neighbors" do
        center_cell = Cell.dead
        Population.with([[alive, alive, alive], [dead, center_cell, dead], [dead, dead, dead]]).evolve
        center_cell.should be_alive
      end
      it "should stay dead with only two live neighbors" do
        center_cell = Cell.dead
        Population.with([[alive, alive, dead], [dead, center_cell, dead], [dead, dead, dead]]).evolve
        center_cell.should_not be_alive
      end
    end
  end
end