vim9script

# Observer Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, type aliases, and abstract classes.

type OutputLines = list<string>

type Temperature = float

enum AlertLevel
  Normal,
  Warning,
  Critical
endenum

interface IObserver
  def Update(temp: Temperature, level: AlertLevel, output: OutputLines): void
endinterface

interface ISubject
  def Attach(observer: IObserver)
  def Detach(observer: IObserver)
  def Notify(temp: Temperature, level: AlertLevel, output: OutputLines)
endinterface

abstract class SubjectBase
  var observers: list<IObserver>

  def Attach(observer: IObserver)
    this.observers->add(observer)
  enddef

  def Detach(observer: IObserver)
    this.observers = filter(this.observers, (_, item) => item != observer)
  enddef

  def Notify(temp: Temperature, level: AlertLevel, output: OutputLines)
    for observer in this.observers
      observer.Update(temp, level, output)
    endfor
  enddef
endclass

class WeatherStation extends SubjectBase implements ISubject
  var temperature: Temperature
  var level: AlertLevel

  def new()
    this.observers = []
    this.temperature = 0.0
    this.level = AlertLevel.Normal
  enddef

  def SetTemperature(temp: Temperature, output: OutputLines)
    this.temperature = temp
    if temp >= 35.0
      this.level = AlertLevel.Critical
    elseif temp >= 30.0
      this.level = AlertLevel.Warning
    else
      this.level = AlertLevel.Normal
    endif

    this.Notify(this.temperature, this.level, output)
  enddef
endclass

class ConsoleDisplay implements IObserver
  def Update(temp: Temperature, level: AlertLevel, output: OutputLines): void
    output->add($'Console: {temp}C ({level.name})')
  enddef
endclass

class CoolingSystem implements IObserver
  def Update(temp: Temperature, level: AlertLevel, output: OutputLines): void
    if level == AlertLevel.Critical
      output->add('Cooling system: ON (max)')
    elseif level == AlertLevel.Warning
      output->add('Cooling system: ON')
    else
      output->add('Cooling system: standby')
    endif
  enddef
endclass

class AlertService implements IObserver
  def Update(temp: Temperature, level: AlertLevel, output: OutputLines): void
    if level != AlertLevel.Normal
      output->add($'Alert sent: {temp}C ({level.name})')
    endif
  enddef
endclass


def DemonstrateObserver(): OutputLines
  var results: OutputLines = []

  results->add("== OBSERVER PATTERN DEMO ==")
  results->add("")

  var station = WeatherStation.new()
  var console = ConsoleDisplay.new()
  var cooling = CoolingSystem.new()
  var alerts = AlertService.new()

  station.Attach(console)
  station.Attach(cooling)
  station.Attach(alerts)

  results->add('Set temperature to 28C')
  station.SetTemperature(28.0, results)
  results->add('')

  results->add('Set temperature to 32C')
  station.SetTemperature(32.0, results)
  results->add('')

  results->add('Set temperature to 37C')
  station.SetTemperature(37.0, results)
  results->add('')

  station.Detach(console)
  results->add('Console detached; set temperature to 31C')
  station.SetTemperature(31.0, results)
  results->add('')

  results->add('Note: Observers react to subject state changes')

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunObserverPatternDemo()
  echo "Observer Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output = DemonstrateObserver()
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
  g:RunObserverPatternDemo()
endif
