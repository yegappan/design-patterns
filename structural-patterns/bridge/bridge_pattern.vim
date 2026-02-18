vim9script

# Bridge Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, and type aliases.

type VolumeStep = number
type IndentSize = number
type OutputLines = list<string>

enum PowerState
  Off,
  On
endenum

enum LineStyle
  Plain,
  Bulleted
endenum

# ============================================================================
# Example 1: Remote and Device Bridge
# ============================================================================

interface IDevice
  def GetName(): string
  def GetVolume(): number
  def SetVolume(level: number)
  def TogglePower(): string
endinterface

abstract class DeviceBase implements IDevice
  var name: string
  var volume: number
  var power: PowerState

  def GetName(): string
    return this.name
  enddef

  def GetVolume(): number
    return this.volume
  enddef

  def SetVolume(level: number)
    this.volume = max([0, min([100, level])])
  enddef

  abstract def TogglePower(): string
endclass

class Radio extends DeviceBase
  def new(name: string, volume: number)
    this.name = name
    this.volume = volume
    this.power = PowerState.Off
  enddef

  def TogglePower(): string
    this.power = this.power == PowerState.Off ? PowerState.On : PowerState.Off
    return $'{this.name} power: {(this.power == PowerState.On ? "ON" : "OFF")}'
  enddef
endclass

class Tv extends DeviceBase
  def new(name: string, volume: number)
    this.name = name
    this.volume = volume
    this.power = PowerState.Off
  enddef

  def TogglePower(): string
    this.power = this.power == PowerState.Off ? PowerState.On : PowerState.Off
    return $'{this.name} power: {(this.power == PowerState.On ? "ON" : "OFF")}'
  enddef
endclass

class RemoteControl
  var device: IDevice
  var step: VolumeStep

  def new(device: IDevice, step: VolumeStep)
    this.device = device
    this.step = step
  enddef

  def TogglePower(): string
    return this.device.TogglePower()
  enddef

  def VolumeUp()
    this.device.SetVolume(this.device.GetVolume() + this.step)
  enddef

  def VolumeDown()
    this.device.SetVolume(this.device.GetVolume() - this.step)
  enddef

  def Status(): string
    return $'{this.device.GetName()} volume: {this.device.GetVolume()}'
  enddef
endclass

class SmartRemote extends RemoteControl
  var preset: number

  def new(device: IDevice, step: VolumeStep, preset: number)
    this.device = device
    this.step = step
    this.preset = preset
  enddef

  def SetPreset()
    this.device.SetVolume(this.preset)
  enddef
endclass

def DemonstrateDeviceBridge(): OutputLines
  var results: OutputLines = []

  results->add("== DEVICE / REMOTE BRIDGE DEMO ==")
  results->add("")

  var radio = Radio.new('Radio', 10)
  var tv = Tv.new('TV', 20)

  var basicRemote = RemoteControl.new(radio, 5)
  var smartRemote = SmartRemote.new(tv, 2, 15)

  results->add("Basic Remote -> Radio")
  results->add(basicRemote.TogglePower())
  basicRemote.VolumeUp()
  results->add(basicRemote.Status())
  results->add("")

  results->add("Smart Remote -> TV")
  results->add(smartRemote.TogglePower())
  smartRemote.SetPreset()
  results->add(smartRemote.Status())
  results->add("")

  results->add("Note: Remotes and devices vary independently")

  return results
enddef


# ============================================================================
# Example 2: Report and Formatter Bridge
# ============================================================================

interface IFormatter
  def Title(text: string): string
  def Line(text: string, style: LineStyle): string
endinterface

class PlainTextFormatter implements IFormatter
  var indent: IndentSize

  def new(indent: IndentSize)
    this.indent = indent
  enddef

  def Title(text: string): string
    return text
  enddef

  def Line(text: string, style: LineStyle): string
    if style == LineStyle.Bulleted
      return repeat(' ', this.indent) .. '- ' .. text
    endif
    return repeat(' ', this.indent) .. text
  enddef
endclass

class MarkdownFormatter implements IFormatter
  def Title(text: string): string
    return '# ' .. text
  enddef

  def Line(text: string, style: LineStyle): string
    if style == LineStyle.Bulleted
      return '- ' .. text
    endif
    return text
  enddef
endclass

class Report
  var formatter: IFormatter
  var title: string

  def new(formatter: IFormatter, title: string)
    this.formatter = formatter
    this.title = title
  enddef

  def Render(lines: list<string>, style: LineStyle): OutputLines
    var output: OutputLines = []
    output->add(this.formatter.Title(this.title))
    for line in lines
      output->add(this.formatter.Line(line, style))
    endfor
    return output
  enddef
endclass

class SalesReport extends Report
  def new(formatter: IFormatter)
    this.formatter = formatter
    this.title = 'Weekly Sales'
  enddef

  def RenderSummary(): OutputLines
    var lines = [
      'Orders: 128',
      'Revenue: $12430',
      'Top Region: West'
    ]
    return this.Render(lines, LineStyle.Bulleted)
  enddef
endclass

def DemonstrateReportBridge(): OutputLines
  var results: OutputLines = []

  results->add("== REPORT / FORMATTER BRIDGE DEMO ==")
  results->add("")

  var markdownReport = SalesReport.new(MarkdownFormatter.new())
  var plainReport = SalesReport.new(PlainTextFormatter.new(2))

  results->add("Markdown Formatter:")
  results->extend(markdownReport.RenderSummary())
  results->add("")

  results->add("Plain Text Formatter:")
  results->extend(plainReport.RenderSummary())
  results->add("")

  results->add("Note: Reports and formatters vary independently")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunBridgePatternDemo()
  echo "Bridge Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output1 = DemonstrateDeviceBridge()
    for line in output1
      echo line
    endfor
    echo ""
    echo repeat("=", 60)
    echo ""

    var output2 = DemonstrateReportBridge()
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
  g:RunBridgePatternDemo()
endif
