vim9script

# State Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, type aliases, and abstract classes.

type OutputLines = list<string>

enum DoorStateKind
  Locked,
  Unlocked,
  Open
endenum

interface IState
  def Kind(): DoorStateKind
  def OnLock(ctx: any, output: OutputLines): void
  def OnUnlock(ctx: any, output: OutputLines): void
  def OnOpen(ctx: any, output: OutputLines): void
  def OnClose(ctx: any, output: OutputLines): void
endinterface

abstract class DoorStateBase
  abstract def Kind(): DoorStateKind
  abstract def OnLock(ctx: any, output: OutputLines): void
  abstract def OnUnlock(ctx: any, output: OutputLines): void
  abstract def OnOpen(ctx: any, output: OutputLines): void
  abstract def OnClose(ctx: any, output: OutputLines): void
endclass

class LockedState extends DoorStateBase implements IState
  def Kind(): DoorStateKind
    return DoorStateKind.Locked
  enddef

  def OnLock(ctx: any, output: OutputLines): void
    output->add('Door already locked')
  enddef

  def OnUnlock(ctx: any, output: OutputLines): void
    ctx.SetState(UnlockedState.new())
    output->add('Door unlocked')
  enddef

  def OnOpen(ctx: any, output: OutputLines): void
    output->add('Cannot open: door is locked')
  enddef

  def OnClose(ctx: any, output: OutputLines): void
    output->add('Door already closed and locked')
  enddef
endclass

class UnlockedState extends DoorStateBase implements IState
  def Kind(): DoorStateKind
    return DoorStateKind.Unlocked
  enddef

  def OnLock(ctx: any, output: OutputLines): void
    ctx.SetState(LockedState.new())
    output->add('Door locked')
  enddef

  def OnUnlock(ctx: any, output: OutputLines): void
    output->add('Door already unlocked')
  enddef

  def OnOpen(ctx: any, output: OutputLines): void
    ctx.SetState(OpenState.new())
    output->add('Door opened')
  enddef

  def OnClose(ctx: any, output: OutputLines): void
    output->add('Door already closed')
  enddef
endclass

class OpenState extends DoorStateBase implements IState
  def Kind(): DoorStateKind
    return DoorStateKind.Open
  enddef

  def OnLock(ctx: any, output: OutputLines): void
    output->add('Cannot lock: door is open')
  enddef

  def OnUnlock(ctx: any, output: OutputLines): void
    output->add('Door already unlocked and open')
  enddef

  def OnOpen(ctx: any, output: OutputLines): void
    output->add('Door already open')
  enddef

  def OnClose(ctx: any, output: OutputLines): void
    ctx.SetState(UnlockedState.new())
    output->add('Door closed')
  enddef
endclass

class DoorContext
  var state: IState

  def new()
    this.state = LockedState.new()
  enddef

  def SetState(state: IState): void
    this.state = state
  enddef

  def Lock(output: OutputLines)
    this.state.OnLock(this, output)
  enddef

  def Unlock(output: OutputLines)
    this.state.OnUnlock(this, output)
  enddef

  def Open(output: OutputLines)
    this.state.OnOpen(this, output)
  enddef

  def Close(output: OutputLines)
    this.state.OnClose(this, output)
  enddef

  def Describe(): string
    return $'Door state: {this.state.Kind().name}'
  enddef
endclass


def DemonstrateState(): OutputLines
  var results: OutputLines = []

  results->add("== STATE PATTERN DEMO ==")
  results->add("")

  var door = DoorContext.new()
  results->add(door.Describe())

  door.Unlock(results)
  results->add(door.Describe())

  door.Open(results)
  results->add(door.Describe())

  door.Lock(results)
  results->add(door.Describe())

  door.Close(results)
  results->add(door.Describe())

  door.Lock(results)
  results->add(door.Describe())

  results->add("")
  results->add("Note: Behavior changes with current state")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunStatePatternDemo()
  echo "State Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output = DemonstrateState()
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
  g:RunStatePatternDemo()
endif
