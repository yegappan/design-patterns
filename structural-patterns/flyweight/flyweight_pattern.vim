vim9script

# Flyweight Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, and type aliases.

type Pixel = dict<number>
type OutputLines = list<string>

enum ShapeKind
  Circle,
  Square
endenum

# ============================================================================
# Flyweight Interface and Concrete Flyweights
# ============================================================================

interface IShape
  def Draw(x: number, y: number, size: number): string
endinterface

# Tree item to hold flyweight and its extrinsic state
class TreeItem
  public var shape: IShape
  public var x: number
  public var y: number
  public var size: number
  
  def new(shape: IShape, x: number, y: number, size: number)
    this.shape = shape
    this.x = x
    this.y = y
    this.size = size
  enddef
endclass

abstract class ShapeBase implements IShape
  abstract def Draw(x: number, y: number, size: number): string
endclass

class CircleShape extends ShapeBase
  var color: string
  var texture: string

  def new(color: string, texture: string)
    this.color = color
    this.texture = texture
  enddef

  def Draw(x: number, y: number, size: number): string
    return $'Circle({this.color}, {this.texture}) at ({x}, {y}) size {size}'
  enddef
endclass

class SquareShape extends ShapeBase
  var color: string
  var texture: string

  def new(color: string, texture: string)
    this.color = color
    this.texture = texture
  enddef

  def Draw(x: number, y: number, size: number): string
    return $'Square({this.color}, {this.texture}) at ({x}, {y}) size {size}'
  enddef
endclass

# ============================================================================
# Flyweight Factory
# ============================================================================

class ShapeFactory
  var cache: dict<IShape>

  def new()
    this.cache = {}
  enddef

  def GetShape(kind: ShapeKind, color: string, texture: string): IShape
    var key = $'{kind.name}-{color}-{texture}'
    if has_key(this.cache, key)
      return this.cache[key]
    endif

    var shape: IShape
    if kind == ShapeKind.Circle
      shape = CircleShape.new(color, texture)
    else
      shape = SquareShape.new(color, texture)
    endif

    this.cache[key] = shape
    return shape
  enddef

  def CacheSize(): number
    return len(this.cache)
  enddef
endclass

# ============================================================================
# Example: Forest Renderer Using Flyweights
# ============================================================================

class ForestRenderer
  var factory: ShapeFactory
  var items: list<TreeItem>

  def new(factory: ShapeFactory)
    this.factory = factory
    this.items = []
  enddef

  def AddTree(kind: ShapeKind, color: string, texture: string, x: number, y: number, size: number)
    var shape = this.factory.GetShape(kind, color, texture)
    this.items->add(TreeItem.new(shape, x, y, size))
  enddef

  def Render(): OutputLines
    var output: OutputLines = []
    for item in this.items
      output->add(item.shape.Draw(item.x, item.y, item.size))
    endfor
    return output
  enddef
endclass


def DemonstrateFlyweight(): OutputLines
  var results: OutputLines = []

  results->add("== FLYWEIGHT DEMO ==")
  results->add("")

  var factory = ShapeFactory.new()
  var forest = ForestRenderer.new(factory)

  forest.AddTree(ShapeKind.Circle, 'green', 'leafy', 10, 12, 5)
  forest.AddTree(ShapeKind.Circle, 'green', 'leafy', 14, 20, 6)
  forest.AddTree(ShapeKind.Square, 'brown', 'bark', 3, 8, 4)
  forest.AddTree(ShapeKind.Circle, 'green', 'leafy', 18, 5, 7)
  forest.AddTree(ShapeKind.Square, 'brown', 'bark', 9, 11, 4)

  results->extend(forest.Render())
  results->add("")
  results->add($"Flyweights created: {factory.CacheSize()}")
  results->add("Note: Intrinsic state is shared, extrinsic state is per tree")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunFlyweightPatternDemo()
  echo "Flyweight Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output1 = DemonstrateFlyweight()
    for line in output1
      echo line
    endfor
  catch
    echohl ErrorMsg
    echo $"Error: {v:exception}"
    echohl None
  endtry

  echo ""
  echo repeat("=", 60)
  echo "Demo completed!"
enddef


# Run demo if executed directly
if expand('%:p') == expand('<sfile>:p')
  g:RunFlyweightPatternDemo()
endif
