vim9script

# Prototype Design Pattern in Vim9script
# This example demonstrates cloning objects instead of creating them from scratch

type ShapeId = string
type OutputLines = list<string>

enum ShapeKind
    Circle,
    Rectangle,
    Triangle,
    Complex
endenum

interface IShape
    def Clone(): IShape
    def GetKind(): ShapeKind
    def GetColor(): string
    def SetColor(color: string): void
    def SetId(newId: ShapeId): void
    def SetPosition(x: number, y: number): void
    def Display(): OutputLines
endinterface

# ============================================================================
# Prototype Interface
# ============================================================================

abstract class Shape implements IShape
    public var id: ShapeId
    public var type: ShapeKind
    public var x: number
    public var y: number
    public var color: string
    
    # Abstract clone method that must be implemented by subclasses
    abstract def Clone(): IShape

    def GetKind(): ShapeKind
        return this.type
    enddef

    def GetColor(): string
        return this.color
    enddef

    def SetColor(color: string): void
        this.color = color
    enddef

    def SetId(newId: ShapeId): void
        this.id = newId
    enddef

    def SetPosition(x: number, y: number): void
        this.x = x
        this.y = y
    enddef
    
    # Display shape information
    def Display(): OutputLines
        var result: OutputLines = []
        result->add($"Shape ID:   {this.id}")
        result->add($"Type:       {this.type.name}")
        result->add($"Position:   ({this.x}, {this.y})")
        result->add($"Color:      {this.color}")
        return result
    enddef
endclass


# ============================================================================
# Concrete Prototypes
# ============================================================================

class Circle extends Shape
    public var radius: number
    
    def new(id: ShapeId, x: number, y: number, color: string, radius: number)
        this.id = id
        this.type = ShapeKind.Circle
        this.x = x
        this.y = y
        this.color = color
        this.radius = radius
    enddef
    
    # Clone method creates a copy of this circle
    def Clone(): IShape
        return Circle.new(this.id, this.x, this.y, this.color, this.radius)
    enddef
    
    def Display(): OutputLines
        var result = super.Display()
        result->add($"Radius:     {this.radius}")
        return result
    enddef
endclass


class Rectangle extends Shape
    public var width: number
    public var height: number
    
    def new(id: ShapeId, x: number, y: number, color: string, width: number, height: number)
        this.id = id
        this.type = ShapeKind.Rectangle
        this.x = x
        this.y = y
        this.color = color
        this.width = width
        this.height = height
    enddef
    
    # Clone method creates a copy of this rectangle
    def Clone(): IShape
        return Rectangle.new(this.id, this.x, this.y, this.color, this.width, this.height)
    enddef
    
    def Display(): OutputLines
        var result = super.Display()
        result->add($"Width:      {this.width}")
        result->add($"Height:     {this.height}")
        return result
    enddef
endclass


class Triangle extends Shape
    public var base: number
    public var height: number
    
    def new(id: ShapeId, x: number, y: number, color: string, base: number, height: number)
        this.id = id
        this.type = ShapeKind.Triangle
        this.x = x
        this.y = y
        this.color = color
        this.base = base
        this.height = height
    enddef
    
    # Clone method creates a copy of this triangle
    def Clone(): IShape
        return Triangle.new(this.id, this.x, this.y, this.color, this.base, this.height)
    enddef
    
    def Display(): OutputLines
        var result = super.Display()
        result->add($"Base:       {this.base}")
        result->add($"Height:     {this.height}")
        return result
    enddef
endclass


# ============================================================================
# Prototype Registry - Manages prototype instances
# ============================================================================

class ShapeRegistry
    public var prototypes: dict<IShape>
    
    def new()
        this.prototypes = {}
    enddef
    
    # Register a prototype shape
    def AddPrototype(key: string, prototype: IShape): void
        this.prototypes[key] = prototype
    enddef
    
    # Get a clone of a registered prototype
    def GetPrototype(key: string): IShape
        if !has_key(this.prototypes, key)
            throw $"Prototype '{key}' not found in registry"
        endif
        return this.prototypes[key].Clone()
    enddef
    
    # List all registered prototypes
    def ListPrototypes(): OutputLines
        var result: OutputLines = []
        result->add("Registered Prototypes:")
        result->add(repeat("-", 40))
        
        for key in keys(this.prototypes)->sort()
            var proto = this.prototypes[key]
            result->add($"  {key}: {proto.GetKind().name} - {proto.GetColor()}")
        endfor
        
        return result
    enddef
endclass


# ============================================================================
# Client Code
# ============================================================================

def DemonstratePrototypePattern(): OutputLines
    var results: OutputLines = []
    
    # Create a registry and add prototype shapes
    var registry = ShapeRegistry.new()
    
    # Register some prototype shapes
    registry.AddPrototype("red-circle", Circle.new("proto-1", 0, 0, "red", 10))
    registry.AddPrototype("blue-rectangle", Rectangle.new("proto-2", 0, 0, "blue", 20, 15))
    registry.AddPrototype("green-triangle", Triangle.new("proto-3", 0, 0, "green", 12, 8))
    
    results->add("╔════════════════════════════════════════╗")
    results->add("║    PROTOTYPE DESIGN PATTERN DEMO       ║")
    results->add("╚════════════════════════════════════════╝")
    results->add("")
    
    # List registered prototypes
    results->extend(registry.ListPrototypes())
    results->add("")
    results->add(repeat("=", 60))
    results->add("")
    
    # Clone prototypes and customize them
    results->add("Creating instances by cloning prototypes:")
    results->add("")
    
    # Clone a red circle and move it
    var circle1 = registry.GetPrototype("red-circle")
    circle1.SetId("circle-1")
    circle1.SetPosition(100, 50)
    
    results->add("1. Cloned red-circle prototype:")
    results->extend(circle1.Display())
    results->add("")
    
    # Clone another red circle with different position
    var circle2: any = registry.GetPrototype("red-circle")
    circle2.SetId("circle-2")
    circle2.SetPosition(200, 150)
    # Modify the radius using instanceof() to check type
    if instanceof(circle2, Circle)
        circle2.radius = 15
    endif
    
    results->add("2. Cloned red-circle prototype (modified):")
    results->extend(circle2.Display())
    results->add("")
    
    # Clone a blue rectangle
    var rect1 = registry.GetPrototype("blue-rectangle")
    rect1.SetId("rect-1")
    rect1.SetPosition(50, 75)
    rect1.SetColor("navy")  # Change color
    
    results->add("3. Cloned blue-rectangle prototype (recolored):")
    results->extend(rect1.Display())
    results->add("")
    
    # Clone a green triangle
    var tri1 = registry.GetPrototype("green-triangle")
    tri1.SetId("tri-1")
    tri1.SetPosition(300, 200)
    
    results->add("4. Cloned green-triangle prototype:")
    results->extend(tri1.Display())
    results->add("")
    
    return results
enddef


# ============================================================================
# Advanced Example: Deep Copy with Complex Objects
# ============================================================================

class ComplexShape extends Shape
    public var children: list<IShape>
    public var metadata: dict<any>
    
    def new(id: ShapeId, x: number, y: number, color: string)
        this.id = id
        this.type = ShapeKind.Complex
        this.x = x
        this.y = y
        this.color = color
        this.children = []
        this.metadata = {}
    enddef
    
    # Deep clone including children
    def Clone(): IShape
        var cloned = ComplexShape.new(this.id, this.x, this.y, this.color)
        
        # Clone all children
        for child in this.children
            cloned.children->add(child.Clone())
        endfor
        
        # Copy metadata (shallow copy of dict)
        cloned.metadata = copy(this.metadata)
        
        return cloned
    enddef
    
    def AddChild(child: IShape): void
        this.children->add(child)
    enddef
    
    def Display(): OutputLines
        var result = super.Display()
        result->add($"Children:   {len(this.children)}")
        result->add($"Metadata:   {string(this.metadata)}")
        return result
    enddef
endclass


def DemonstrateDeepCopy(): OutputLines
    var results: OutputLines = []
    
    results->add("╔════════════════════════════════════════╗")
    results->add("║      DEEP COPY DEMONSTRATION           ║")
    results->add("╚════════════════════════════════════════╝")
    results->add("")
    
    # Create a complex shape with children
    var original = ComplexShape.new("complex-1", 0, 0, "purple")
    original.AddChild(Circle.new("child-1", 10, 10, "red", 5))
    original.AddChild(Rectangle.new("child-2", 20, 20, "blue", 10, 8))
    original.metadata = {'author': 'John Doe', 'version': 1}
    
    results->add("Original Complex Shape:")
    results->extend(original.Display())
    results->add("")
    
    # Clone the complex shape (deep copy)
    var cloned: any = original.Clone()
    cloned.id = "complex-2"
    cloned.x = 100
    cloned.y = 100
    # Modify metadata using instanceof() to check type
    if instanceof(cloned, ComplexShape)
        cloned.metadata['version'] = 2
    endif
    
    results->add("Cloned Complex Shape (modified):")
    results->extend(cloned.Display())
    results->add("")
    
    results->add("Note: Original and clone have independent children")
    results->add($"Original children count: {len(original.children)}")
    # Access cloned children using instanceof() to check type
    if instanceof(cloned, ComplexShape)
        results->add($"Cloned children count: {len(cloned.children)}")
    endif
    
    return results
enddef


# ============================================================================
# Demo Execution
# ============================================================================

def g:RunPrototypePatternDemo()
    echo "Prototype Design Pattern Demo"
    echo repeat("=", 60)
    echo ""
    
    try
        var output = DemonstratePrototypePattern()
        for line in output
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


def g:RunDeepCopyDemo()
    echo "Deep Copy Demonstration"
    echo repeat("=", 60)
    echo ""
    
    try
        var output = DemonstrateDeepCopy()
        for line in output
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


# Run demos if executed directly
if expand('%:p') == expand('<sfile>:p')
    g:RunPrototypePatternDemo()
    echo ""
    g:RunDeepCopyDemo()
endif
