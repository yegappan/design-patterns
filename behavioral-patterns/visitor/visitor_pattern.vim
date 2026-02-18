vim9script

# Visitor Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, type aliases, and abstract classes.

type OutputLines = list<string>

type Money = float

enum ItemKind
  Book,
  Electronics
endenum

interface IVisitor
  def VisitBook(book: any, output: OutputLines): void
  def VisitElectronics(item: any, output: OutputLines): void
endinterface

interface IElement
  def Accept(visitor: IVisitor, output: OutputLines): void
  def Kind(): ItemKind
endinterface

abstract class ItemBase
  abstract def Accept(visitor: IVisitor, output: OutputLines): void
  abstract def Kind(): ItemKind
endclass

class Book extends ItemBase implements IElement
  var title: string
  var price: Money

  def new(title: string, price: Money)
    this.title = title
    this.price = price
  enddef

  def Accept(visitor: IVisitor, output: OutputLines): void
    visitor.VisitBook(this, output)
  enddef

  def Kind(): ItemKind
    return ItemKind.Book
  enddef
endclass

class Electronics extends ItemBase implements IElement
  var name: string
  var price: Money

  def new(name: string, price: Money)
    this.name = name
    this.price = price
  enddef

  def Accept(visitor: IVisitor, output: OutputLines): void
    visitor.VisitElectronics(this, output)
  enddef

  def Kind(): ItemKind
    return ItemKind.Electronics
  enddef
endclass

class PriceVisitor implements IVisitor
  def VisitBook(book: any, output: OutputLines): void
    var tax = book.price * 0.05
    var total = book.price + tax
    output->add($'Book: {book.title} total {printf('%.2f', total)}')
  enddef

  def VisitElectronics(item: any, output: OutputLines): void
    var tax = item.price * 0.15
    var total = item.price + tax
    output->add($'Electronics: {item.name} total {printf('%.2f', total)}')
  enddef
endclass

class DiscountVisitor implements IVisitor
  def VisitBook(book: any, output: OutputLines): void
    var total = book.price * 0.90
    output->add($'Book: {book.title} discounted {printf('%.2f', total)}')
  enddef

  def VisitElectronics(item: any, output: OutputLines): void
    var total = item.price * 0.80
    output->add($'Electronics: {item.name} discounted {printf('%.2f', total)}')
  enddef
endclass

class Cart
  var items: list<IElement>

  def new()
    this.items = []
  enddef

  def Add(item: IElement)
    this.items->add(item)
  enddef

  def Apply(visitor: IVisitor, output: OutputLines)
    for item in this.items
      item.Accept(visitor, output)
    endfor
  enddef
endclass


def DemonstrateVisitor(): OutputLines
  var results: OutputLines = []

  results->add("== VISITOR PATTERN DEMO ==")
  results->add("")

  var cart = Cart.new()
  cart.Add(Book.new('Clean Code', 30.0))
  cart.Add(Electronics.new('Headphones', 80.0))

  var priceVisitor = PriceVisitor.new()
  var discountVisitor = DiscountVisitor.new()

  results->add('Price visitor:')
  cart.Apply(priceVisitor, results)

  results->add('')
  results->add('Discount visitor:')
  cart.Apply(discountVisitor, results)

  results->add('')
  results->add('Note: Visitor adds operations without changing elements')

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunVisitorPatternDemo()
  echo "Visitor Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output = DemonstrateVisitor()
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


# Run demo if executed directly
if expand('%:p') == expand('<sfile>:p')
  g:RunVisitorPatternDemo()
endif
