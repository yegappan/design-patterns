vim9script

# Memento Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, type aliases, and abstract classes.

type OutputLines = list<string>

type SnapshotId = number

enum DocumentState
  Clean,
  Dirty
endenum

interface IMemento
  def Id(): SnapshotId
  def Describe(): string
endinterface

class DocumentMemento implements IMemento
  var id: SnapshotId
  var content: string
  var cursor: number
  var state: DocumentState

  def new(id: SnapshotId, content: string, cursor: number, state: DocumentState)
    this.id = id
    this.content = content
    this.cursor = cursor
    this.state = state
  enddef

  def Id(): SnapshotId
    return this.id
  enddef

  def Describe(): string
    return $'Snapshot #{this.id} ({this.state.name}, cursor {this.cursor})'
  enddef
endclass

class TextDocument
  var content: string
  var cursor: number
  var state: DocumentState

  def new(content: string)
    this.content = content
    this.cursor = 0
    this.state = DocumentState.Clean
  enddef

  def Insert(text: string)
    var prefix = this.content[: this.cursor - 1]
    var suffix = this.content[this.cursor : ]
    this.content = prefix .. text .. suffix
    this.cursor += len(text)
    this.state = DocumentState.Dirty
  enddef

  def MoveCursor(pos: number)
    this.cursor = max([0, min([len(this.content), pos])])
  enddef

  def CreateMemento(id: SnapshotId): IMemento
    return DocumentMemento.new(id, this.content, this.cursor, this.state)
  enddef

  def Restore(memento: IMemento)
    if !instanceof(memento, DocumentMemento)
      throw 'Invalid memento'
    endif

    var snapshot: any = memento
    this.content = snapshot.content
    this.cursor = snapshot.cursor
    this.state = snapshot.state
  enddef

  def Summary(): string
    return $'Doc("{this.content}", cursor {this.cursor}, {this.state.name})'
  enddef
endclass

class HistoryCaretaker
  var snapshots: list<IMemento>

  def new()
    this.snapshots = []
  enddef

  def Save(memento: IMemento)
    this.snapshots->add(memento)
  enddef

  def Last(): IMemento
    if len(this.snapshots) == 0
      throw 'No snapshots'
    endif
    return this.snapshots[-1]
  enddef

  def Get(index: number): IMemento
    if index < 0 || index >= len(this.snapshots)
      throw 'Snapshot index out of range'
    endif
    return this.snapshots[index]
  enddef

  def List(): OutputLines
    var output: OutputLines = []
    for snap in this.snapshots
      output->add(snap.Describe())
    endfor
    return output
  enddef
endclass


def DemonstrateMemento(): OutputLines
  var results: OutputLines = []

  results->add("== MEMENTO PATTERN DEMO ==")
  results->add("")

  var doc = TextDocument.new('Hello')
  var history = HistoryCaretaker.new()

  history.Save(doc.CreateMemento(1))
  results->add('Saved: ' .. doc.Summary())

  doc.Insert(', world')
  history.Save(doc.CreateMemento(2))
  results->add('Saved: ' .. doc.Summary())

  doc.MoveCursor(5)
  doc.Insert(' wonderful')
  history.Save(doc.CreateMemento(3))
  results->add('Saved: ' .. doc.Summary())

  results->add("")
  results->add('Snapshots:')
  results->extend(history.List())

  results->add("")
  results->add('Restore to snapshot #1')
  doc.Restore(history.Get(0))
  results->add('Current: ' .. doc.Summary())

  results->add("")
  results->add("Note: Mementos capture internal state without exposing it")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunMementoPatternDemo()
  echo "Memento Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output = DemonstrateMemento()
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
  g:RunMementoPatternDemo()
endif
