vim9script

# Mediator Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, type aliases, and abstract classes.

type OutputLines = list<string>

type Username = string

enum EventType
  Join,
  Leave,
  Message
endenum

interface IMediator
  def Notify(sender: string, event: EventType, payload: string, output: OutputLines): void
endinterface

interface IParticipant
  def Name(): string
  def Send(text: string, output: OutputLines): void
  def Receive(from: string, text: string, output: OutputLines): void
endinterface

abstract class ParticipantBase
  var mediator: IMediator
  var name: Username

  def Name(): string
    return this.name
  enddef

  abstract def Send(text: string, output: OutputLines): void
  abstract def Receive(from: string, text: string, output: OutputLines): void
endclass

class ChatUser extends ParticipantBase implements IParticipant
  def new(name: Username, mediator: IMediator)
    this.name = name
    this.mediator = mediator
  enddef

  def Send(text: string, output: OutputLines): void
    this.mediator.Notify(this.name, EventType.Message, text, output)
  enddef

  def Receive(from: string, text: string, output: OutputLines): void
    output->add($'[{this.name}] from {from}: {text}')
  enddef
endclass

class ChatRoom implements IMediator
  var participants: dict<IParticipant>

  def new()
    this.participants = {}
  enddef

  def Register(user: IParticipant, output: OutputLines)
    this.participants[user.Name()] = user
    this.Notify(user.Name(), EventType.Join, 'joined the room', output)
  enddef

  def Remove(name: Username, output: OutputLines)
    if has_key(this.participants, name)
      this.participants->remove(name)
      this.Notify(name, EventType.Leave, 'left the room', output)
    endif
  enddef

  def Notify(sender: string, event: EventType, payload: string, output: OutputLines): void
    if event == EventType.Message
      for [name, participant] in items(this.participants)
        if name != sender
          participant.Receive(sender, payload, output)
        endif
      endfor
      return
    endif

    var line = event == EventType.Join ? $"{sender} {payload}" : $"{sender} {payload}"
    output->add(line)
  enddef
endclass


def DemonstrateMediator(): OutputLines
  var results: OutputLines = []

  results->add("== MEDIATOR PATTERN DEMO ==")
  results->add("")

  var room = ChatRoom.new()
  var alice = ChatUser.new('Alice', room)
  var bob = ChatUser.new('Bob', room)
  var carol = ChatUser.new('Carol', room)

  room.Register(alice, results)
  room.Register(bob, results)
  room.Register(carol, results)

  results->add("")

  alice.Send('Hello everyone!', results)
  bob.Send('Hi Alice!', results)
  carol.Send('Welcome to the room.', results)

  results->add("")

  room.Remove('Bob', results)
  alice.Send('See you later!', results)

  results->add("")
  results->add("Note: Participants communicate through mediator")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunMediatorPatternDemo()
  echo "Mediator Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output = DemonstrateMediator()
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
  g:RunMediatorPatternDemo()
endif
