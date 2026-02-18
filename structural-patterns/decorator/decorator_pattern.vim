vim9script

# Decorator Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, and type aliases.

type Money = float
type OutputLines = list<string>

enum DrinkSize
  Small,
  Medium,
  Large
endenum

# ============================================================================
# Example 1: Beverage Decorators
# ============================================================================

interface IBeverage
  def GetDescription(): string
  def GetSize(): DrinkSize
  def GetCost(): Money
endinterface

class Espresso implements IBeverage
  var size: DrinkSize

  def new(size: DrinkSize)
    this.size = size
  enddef

  def GetDescription(): string
    return 'Espresso'
  enddef

  def GetSize(): DrinkSize
    return this.size
  enddef

  def GetCost(): Money
    if this.size == DrinkSize.Small
      return 2.00
    elseif this.size == DrinkSize.Medium
      return 2.50
    endif
    return 3.00
  enddef
endclass

class HouseBlend implements IBeverage
  var size: DrinkSize

  def new(size: DrinkSize)
    this.size = size
  enddef

  def GetDescription(): string
    return 'House Blend'
  enddef

  def GetSize(): DrinkSize
    return this.size
  enddef

  def GetCost(): Money
    if this.size == DrinkSize.Small
      return 1.75
    elseif this.size == DrinkSize.Medium
      return 2.25
    endif
    return 2.75
  enddef
endclass

abstract class BeverageDecorator
  var beverage: IBeverage

  abstract def GetDescription(): string
  abstract def GetSize(): DrinkSize
  abstract def GetCost(): Money
endclass

class MilkDecorator extends BeverageDecorator implements IBeverage
  def new(beverage: IBeverage)
    this.beverage = beverage
  enddef

  def GetDescription(): string
    return this.beverage.GetDescription() .. ', Milk'
  enddef

  def GetSize(): DrinkSize
    return this.beverage.GetSize()
  enddef

  def GetCost(): Money
    return this.beverage.GetCost() + 0.25
  enddef
endclass

class MochaDecorator extends BeverageDecorator implements IBeverage
  def new(beverage: IBeverage)
    this.beverage = beverage
  enddef

  def GetDescription(): string
    return this.beverage.GetDescription() .. ', Mocha'
  enddef

  def GetSize(): DrinkSize
    return this.beverage.GetSize()
  enddef

  def GetCost(): Money
    return this.beverage.GetCost() + 0.35
  enddef
endclass

class WhipDecorator extends BeverageDecorator implements IBeverage
  def new(beverage: IBeverage)
    this.beverage = beverage
  enddef

  def GetDescription(): string
    return this.beverage.GetDescription() .. ', Whip'
  enddef

  def GetSize(): DrinkSize
    return this.beverage.GetSize()
  enddef

  def GetCost(): Money
    return this.beverage.GetCost() + 0.20
  enddef
endclass


def DemonstrateBeverageDecorator(): OutputLines
  var results: OutputLines = []

  results->add("== BEVERAGE DECORATOR DEMO ==")
  results->add("")

  var drink1: IBeverage = Espresso.new(DrinkSize.Small)
  drink1 = MilkDecorator.new(drink1)
  drink1 = MochaDecorator.new(drink1)

  results->add("Order 1:")
  results->add($"  {drink1.GetDescription()}")
  results->add($"  Cost: ${printf('%.2f', drink1.GetCost())}")
  results->add("")

  var drink2: IBeverage = HouseBlend.new(DrinkSize.Large)
  drink2 = WhipDecorator.new(MochaDecorator.new(MilkDecorator.new(drink2)))

  results->add("Order 2:")
  results->add($"  {drink2.GetDescription()}")
  results->add($"  Cost: ${printf('%.2f', drink2.GetCost())}")
  results->add("")

  results->add("Note: Decorators add features without changing base classes")

  return results
enddef


# ============================================================================
# Example 2: Notification Decorators
# ============================================================================

type ChannelList = list<string>

enum Priority
  Normal,
  Urgent
endenum

interface INotifier
  def Notify(message: string, priority: Priority): ChannelList
endinterface

class BaseNotifier implements INotifier
  def Notify(message: string, priority: Priority): ChannelList
    return [$"Base: {message} ({priority == Priority.Urgent ? 'urgent' : 'normal'})"]
  enddef
endclass

abstract class NotifierDecorator
  var notifier: INotifier

  abstract def Notify(message: string, priority: Priority): ChannelList
endclass

class EmailDecorator extends NotifierDecorator implements INotifier
  def new(notifier: INotifier)
    this.notifier = notifier
  enddef

  def Notify(message: string, priority: Priority): ChannelList
    var output = this.notifier.Notify(message, priority)
    output->add($"Email: {message}")
    return output
  enddef
endclass

class SmsDecorator extends NotifierDecorator implements INotifier
  def new(notifier: INotifier)
    this.notifier = notifier
  enddef

  def Notify(message: string, priority: Priority): ChannelList
    var output = this.notifier.Notify(message, priority)
    output->add($"SMS: {message}")
    return output
  enddef
endclass

class SlackDecorator extends NotifierDecorator implements INotifier
  def new(notifier: INotifier)
    this.notifier = notifier
  enddef

  def Notify(message: string, priority: Priority): ChannelList
    var output = this.notifier.Notify(message, priority)
    output->add($"Slack: {message}")
    return output
  enddef
endclass


def DemonstrateNotifierDecorator(): OutputLines
  var results: OutputLines = []

  results->add("== NOTIFICATION DECORATOR DEMO ==")
  results->add("")

  var notifier: INotifier = BaseNotifier.new()
  notifier = EmailDecorator.new(SlackDecorator.new(notifier))

  results->add("Normal message:")
  var normal = notifier.Notify('Build completed', Priority.Normal)
  for line in normal
    results->add('  ' .. line)
  endfor
  results->add("")

  notifier = SmsDecorator.new(notifier)

  results->add("Urgent message:")
  var urgent = notifier.Notify('Server is down', Priority.Urgent)
  for line in urgent
    results->add('  ' .. line)
  endfor
  results->add("")

  results->add("Note: Channels are added dynamically via decorators")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunDecoratorPatternDemo()
  echo "Decorator Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output1 = DemonstrateBeverageDecorator()
    for line in output1
      echo line
    endfor
    echo ""
    echo repeat("=", 60)
    echo ""

    var output2 = DemonstrateNotifierDecorator()
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
  g:RunDecoratorPatternDemo()
endif
