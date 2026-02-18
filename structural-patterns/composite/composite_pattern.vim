vim9script

# Composite Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, and type aliases.

type IndentSize = number
type OutputLines = list<string>

enum NodeKind
  Leaf,
  Composite
endenum

# ============================================================================
# Example 1: UI Component Tree
# ============================================================================

interface IComponent
  def GetName(): string
  def GetKind(): NodeKind
  def Render(indent: IndentSize): OutputLines
endinterface

abstract class ComponentBase implements IComponent
  var name: string

  def GetName(): string
    return this.name
  enddef

  abstract def GetKind(): NodeKind
  abstract def Render(indent: IndentSize): OutputLines
endclass

class Label extends ComponentBase
  var text: string

  def new(name: string, text: string)
    this.name = name
    this.text = text
  enddef

  def GetKind(): NodeKind
    return NodeKind.Leaf
  enddef

  def Render(indent: IndentSize): OutputLines
    return [repeat(' ', indent) .. $'Label({this.name}): "{this.text}"']
  enddef
endclass

class Button extends ComponentBase
  var action: string

  def new(name: string, action: string)
    this.name = name
    this.action = action
  enddef

  def GetKind(): NodeKind
    return NodeKind.Leaf
  enddef

  def Render(indent: IndentSize): OutputLines
    return [repeat(' ', indent) .. $'Button({this.name}): {this.action}']
  enddef
endclass

class Panel extends ComponentBase
  var children: list<IComponent>

  def new(name: string)
    this.name = name
    this.children = []
  enddef

  def Add(child: IComponent)
    this.children->add(child)
  enddef

  def RemoveByName(name: string)
    this.children = filter(this.children, (_, item) => item.GetName() != name)
  enddef

  def GetKind(): NodeKind
    return NodeKind.Composite
  enddef

  def Render(indent: IndentSize): OutputLines
    var output: OutputLines = []
    output->add(repeat(' ', indent) .. $'Panel({this.name})')
    for child in this.children
      output->extend(child.Render(indent + 2))
    endfor
    return output
  enddef
endclass


def DemonstrateUiComposite(): OutputLines
  var results: OutputLines = []

  results->add("== UI COMPONENT COMPOSITE DEMO ==")
  results->add("")

  var root = Panel.new('Root')
  var header = Panel.new('Header')
  var content = Panel.new('Content')

  header.Add(Label.new('Title', 'Dashboard'))
  header.Add(Button.new('Refresh', 'Reload data'))

  content.Add(Label.new('Summary', 'KPI Summary'))
  content.Add(Button.new('Export', 'Download CSV'))

  root.Add(header)
  root.Add(content)

  results->extend(root.Render(0))
  results->add("")
  results->add("Note: Panels and leaf widgets share one interface")

  return results
enddef


# ============================================================================
# Example 2: Menu Composite
# ============================================================================

interface IMenuItem
  def GetTitle(): string
  def GetKind(): NodeKind
  def Render(indent: IndentSize): OutputLines
endinterface

abstract class MenuItemBase implements IMenuItem
  var title: string

  def GetTitle(): string
    return this.title
  enddef

  abstract def GetKind(): NodeKind
  abstract def Render(indent: IndentSize): OutputLines
endclass

class MenuItem extends MenuItemBase
  var shortcut: string

  def new(title: string, shortcut: string)
    this.title = title
    this.shortcut = shortcut
  enddef

  def GetKind(): NodeKind
    return NodeKind.Leaf
  enddef

  def Render(indent: IndentSize): OutputLines
    return [repeat(' ', indent) .. $'- {this.title} ({this.shortcut})']
  enddef
endclass

class Menu extends MenuItemBase
  var items: list<IMenuItem>

  def new(title: string)
    this.title = title
    this.items = []
  enddef

  def Add(item: IMenuItem)
    this.items->add(item)
  enddef

  def GetKind(): NodeKind
    return NodeKind.Composite
  enddef

  def Render(indent: IndentSize): OutputLines
    var output: OutputLines = []
    output->add(repeat(' ', indent) .. this.title)
    for item in this.items
      output->extend(item.Render(indent + 2))
    endfor
    return output
  enddef
endclass


def DemonstrateMenuComposite(): OutputLines
  var results: OutputLines = []

  results->add("== MENU COMPOSITE DEMO ==")
  results->add("")

  var fileMenu = Menu.new('File')
  fileMenu.Add(MenuItem.new('New', 'Ctrl+N'))
  fileMenu.Add(MenuItem.new('Open', 'Ctrl+O'))
  fileMenu.Add(MenuItem.new('Save', 'Ctrl+S'))

  var editMenu = Menu.new('Edit')
  editMenu.Add(MenuItem.new('Undo', 'Ctrl+Z'))
  editMenu.Add(MenuItem.new('Redo', 'Ctrl+Y'))

  var mainMenu = Menu.new('Main Menu')
  mainMenu.Add(fileMenu)
  mainMenu.Add(editMenu)

  results->extend(mainMenu.Render(0))
  results->add("")
  results->add("Note: Menus and menu items are treated uniformly")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunCompositePatternDemo()
  echo "Composite Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output1 = DemonstrateUiComposite()
    for line in output1
      echo line
    endfor
    echo ""
    echo repeat("=", 60)
    echo ""

    var output2 = DemonstrateMenuComposite()
    for line in output2
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
  g:RunCompositePatternDemo()
endif
