vim9script

# Proxy Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, and type aliases.

type QueryResult = list<string>
type OutputLines = list<string>

enum AccessLevel
  Guest,
  User,
  Admin
endenum

# ============================================================================
# Example 1: Database Access Proxy
# ============================================================================

interface IDataStore
  def Query(sql: string): QueryResult
endinterface

abstract class DataStoreBase implements IDataStore
  abstract def Query(sql: string): QueryResult
endclass

class RealDatabase extends DataStoreBase
  def Query(sql: string): QueryResult
    return [
      $'Executing: {sql}',
      'Row 1: user=alex',
      'Row 2: user=jamie'
    ]
  enddef
endclass

class DatabaseProxy extends DataStoreBase
  var db: RealDatabase
  var cache: dict<QueryResult>
  var access: AccessLevel

  def new(access: AccessLevel)
    this.db = RealDatabase.new()
    this.cache = {}
    this.access = access
  enddef

  def Query(sql: string): QueryResult
    if this.access == AccessLevel.Guest && sql =~? 'delete|drop|update'
      return ['Access denied: read-only for guests']
    endif

    if has_key(this.cache, sql)
      var cached = this.cache[sql]
      return ['(cache hit)'] + cached
    endif

    var result = this.db.Query(sql)
    this.cache[sql] = result
    return result
  enddef
endclass


def DemonstrateDatabaseProxy(): OutputLines
  var results: OutputLines = []

  results->add("== DATABASE PROXY DEMO ==")
  results->add("")

  var guestProxy: IDataStore = DatabaseProxy.new(AccessLevel.Guest)
  results->add("Guest query:")
  results->extend(guestProxy.Query('select * from users'))
  results->add("")

  results->add("Guest attempt to modify:")
  results->extend(guestProxy.Query('delete from users where id=1'))
  results->add("")

  var adminProxy: IDataStore = DatabaseProxy.new(AccessLevel.Admin)
  results->add("Admin query (first time):")
  results->extend(adminProxy.Query('select * from users'))
  results->add("")

  results->add("Admin query (cached):")
  results->extend(adminProxy.Query('select * from users'))
  results->add("")

  results->add("Note: Proxy adds access control and caching")

  return results
enddef


# ============================================================================
# Example 2: Image Loading Proxy
# ============================================================================

enum ImageState
  NotLoaded,
  Loaded
endenum

interface IImage
  def Display(): OutputLines
endinterface

abstract class ImageBase implements IImage
  abstract def Display(): OutputLines
endclass

class RealImage extends ImageBase
  var path: string

  def new(path: string)
    this.path = path
    this.LoadFromDisk()
  enddef

  def LoadFromDisk()
    # Simulate expensive load
  enddef

  def Display(): OutputLines
    return [$'Displaying image: {this.path}']
  enddef
endclass

class ProxyImage extends ImageBase
  var path: string
  var real: RealImage
  var state: ImageState

  def new(path: string)
    this.path = path
    this.real = null_object
    this.state = ImageState.NotLoaded
  enddef

  def Display(): OutputLines
    if this.state == ImageState.NotLoaded
      this.real = RealImage.new(this.path)
      this.state = ImageState.Loaded
      return ['Loaded on demand'] + this.real.Display()
    endif

    return this.real.Display()
  enddef
endclass


def DemonstrateImageProxy(): OutputLines
  var results: OutputLines = []

  results->add("== IMAGE PROXY DEMO ==")
  results->add("")

  var image: IImage = ProxyImage.new('assets/hero.png')
  results->add("First display:")
  results->extend(image.Display())
  results->add("")

  results->add("Second display:")
  results->extend(image.Display())
  results->add("")

  results->add("Note: Proxy delays object creation until needed")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunProxyPatternDemo()
  echo "Proxy Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output1 = DemonstrateDatabaseProxy()
    for line in output1
      echo line
    endfor
    echo ""
    echo repeat("=", 60)
    echo ""

    var output2 = DemonstrateImageProxy()
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
  g:RunProxyPatternDemo()
endif
