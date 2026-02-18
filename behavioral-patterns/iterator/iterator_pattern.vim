vim9script

# Iterator Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, type aliases, and abstract classes.

type OutputLines = list<string>

type Index = number

enum TraversalOrder
  Forward,
  Reverse
endenum

interface IIterator
  def HasNext(): bool
  def Next(): string
endinterface

interface IAggregate
  def CreateIterator(order: TraversalOrder): IIterator
endinterface

abstract class IteratorBase
  abstract def HasNext(): bool
  abstract def Next(): string
endclass

class StringCollection implements IAggregate
  var items: list<string>

  def new(items: list<string>)
    this.items = items
  enddef

  def CreateIterator(order: TraversalOrder): IIterator
    if order == TraversalOrder.Reverse
      return ReverseIterator.new(this.items)
    endif
    return ForwardIterator.new(this.items)
  enddef
endclass

class ForwardIterator extends IteratorBase implements IIterator
  var items: list<string>
  var index: Index

  def new(items: list<string>)
    this.items = items
    this.index = 0
  enddef

  def HasNext(): bool
    return this.index < len(this.items)
  enddef

  def Next(): string
    var value = this.items[this.index]
    this.index += 1
    return value
  enddef
endclass

class ReverseIterator extends IteratorBase implements IIterator
  var items: list<string>
  var index: Index

  def new(items: list<string>)
    this.items = items
    this.index = len(items) - 1
  enddef

  def HasNext(): bool
    return this.index >= 0
  enddef

  def Next(): string
    var value = this.items[this.index]
    this.index -= 1
    return value
  enddef
endclass


def DemonstrateIterator(): OutputLines
  var results: OutputLines = []

  results->add("== ITERATOR PATTERN DEMO ==")
  results->add("")

  var collection = StringCollection.new(['alpha', 'beta', 'gamma', 'delta'])

  var forward = collection.CreateIterator(TraversalOrder.Forward)
  results->add("Forward traversal:")
  while forward.HasNext()
    results->add('  ' .. forward.Next())
  endwhile
  results->add("")

  var reverse = collection.CreateIterator(TraversalOrder.Reverse)
  results->add("Reverse traversal:")
  while reverse.HasNext()
    results->add('  ' .. reverse.Next())
  endwhile
  results->add("")

  results->add("Note: Client uses iterator, not collection internals")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunIteratorPatternDemo()
  echo "Iterator Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output = DemonstrateIterator()
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
  g:RunIteratorPatternDemo()
endif
