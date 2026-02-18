vim9script

# Facade Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, and type aliases.

type OutputLines = list<string>

enum BackupMode
  Full,
  Incremental
endenum

# ============================================================================
# Example 1: Backup Subsystem Facade
# ============================================================================

interface ISubsystem
  def Name(): string
endinterface

abstract class SubsystemBase implements ISubsystem
  abstract def Name(): string
endclass

class FileScanner extends SubsystemBase
  def Name(): string
    return 'FileScanner'
  enddef

  def Scan(root: string): list<string>
    return [root .. '/docs', root .. '/src', root .. '/logs']
  enddef
endclass

class Compressor extends SubsystemBase
  def Name(): string
    return 'Compressor'
  enddef

  def Compress(paths: list<string>, mode: BackupMode): string
    var tag = mode == BackupMode.Full ? 'full' : 'inc'
    return $'backup_{tag}_{len(paths)}.zip'
  enddef
endclass

class Encryptor extends SubsystemBase
  def Name(): string
    return 'Encryptor'
  enddef

  def Encrypt(archiveName: string): string
    return archiveName .. '.enc'
  enddef
endclass

class TransferClient extends SubsystemBase
  def Name(): string
    return 'TransferClient'
  enddef

  def Upload(fileName: string, destination: string): string
    return $'uploaded {fileName} to {destination}'
  enddef
endclass

class BackupFacade
  var scanner: FileScanner
  var compressor: Compressor
  var encryptor: Encryptor
  var transfer: TransferClient

  def new()
    this.scanner = FileScanner.new()
    this.compressor = Compressor.new()
    this.encryptor = Encryptor.new()
    this.transfer = TransferClient.new()
  enddef

  def RunBackup(root: string, destination: string, mode: BackupMode): OutputLines
    var results: OutputLines = []
    results->add("== BACKUP FACADE ==")
    results->add($"Scanning {root}")

    var paths = this.scanner.Scan(root)
    results->add($"Found {len(paths)} locations")

    var archive = this.compressor.Compress(paths, mode)
    results->add($"Compressed into {archive}")

    var encrypted = this.encryptor.Encrypt(archive)
    results->add($"Encrypted as {encrypted}")

    var status = this.transfer.Upload(encrypted, destination)
    results->add(status)

    return results
  enddef
endclass


def DemonstrateBackupFacade(): OutputLines
  var facade = BackupFacade.new()
  return facade.RunBackup('~/project', 's3://backup-bucket', BackupMode.Full)
enddef


# ============================================================================
# Example 2: Media Playback Facade
# ============================================================================

enum PlaybackState
  Stopped,
  Playing,
  Paused
endenum

interface IPlayer
  def Load(track: string)
  def Play(): string
  def Pause(): string
  def Stop(): string
endinterface

class Decoder extends SubsystemBase
  def Name(): string
    return 'Decoder'
  enddef

  def Decode(track: string): string
    return $'decoded:{track}'
  enddef
endclass

class Renderer extends SubsystemBase
  def Name(): string
    return 'Renderer'
  enddef

  def Render(stream: string)
    # Rendering simulation
  enddef
endclass

class OutputDevice extends SubsystemBase
  def Name(): string
    return 'OutputDevice'
  enddef

  def Open(): string
    return 'output device ready'
  enddef
endclass

class MediaPlayerFacade implements IPlayer
  var decoder: Decoder
  var renderer: Renderer
  var output: OutputDevice
  var state: PlaybackState
  var current: string

  def new()
    this.decoder = Decoder.new()
    this.renderer = Renderer.new()
    this.output = OutputDevice.new()
    this.state = PlaybackState.Stopped
    this.current = ''
  enddef

  def Load(track: string)
    this.current = this.decoder.Decode(track)
    this.renderer.Render(this.current)
  enddef

  def Play(): string
    if this.state == PlaybackState.Playing
      return 'Already playing'
    endif
    this.state = PlaybackState.Playing
    return $'Playing {this.current}'
  enddef

  def Pause(): string
    if this.state != PlaybackState.Playing
      return 'Nothing playing'
    endif
    this.state = PlaybackState.Paused
    return 'Paused'
  enddef

  def Stop(): string
    this.state = PlaybackState.Stopped
    return 'Stopped'
  enddef
endclass


def DemonstrateMediaFacade(): OutputLines
  var player: IPlayer = MediaPlayerFacade.new()
  player.Load('theme.mp3')

  return [
    '== MEDIA FACADE ==',
    player.Play(),
    player.Pause(),
    player.Stop()
  ]
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunFacadePatternDemo()
  echo "Facade Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output1 = DemonstrateBackupFacade()
    for line in output1
      echo line
    endfor
    echo ""
    echo repeat("=", 60)
    echo ""

    var output2 = DemonstrateMediaFacade()
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
  g:RunFacadePatternDemo()
endif
