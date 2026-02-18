vim9script

# Singleton Design Pattern in Vim9script
# Ensures a class has only one instance and provides a global point of access to it

type SettingKey = string
type Settings = dict<any>
type OutputLines = list<string>
type LogHistory = list<string>

enum LogLevel
    Debug,
    Info,
    Warning,
    Error
endenum

enum ConnectionState
    Disconnected,
    Connected
endenum

enum AuthState
    Anonymous,
    Authenticated
endenum

interface IConfigManager
    def Get(key: SettingKey): any
    def Set(key: SettingKey, value: any): void
    def GetAll(): Settings
    def Display(): OutputLines
endinterface

interface ILogger
    def SetLevel(level: LogLevel): void
    def Log(level: LogLevel, message: string): void
    def GetHistory(count: number = 10): LogHistory
    def Clear(): void
endinterface

interface IDatabaseConnection
    def Connect(): bool
    def Disconnect(): void
    def Query(sql: string): list<string>
    def GetStatus(): OutputLines
endinterface

interface IApplicationState
    def Login(username: string): void
    def Logout(): void
    def SetSessionData(key: string, value: any): void
    def GetSessionData(key: string): any
    def GetInfo(): OutputLines
endinterface

def LogLevelLabel(level: LogLevel): string
    return level.name->toupper()
enddef

# ============================================================================
# Example 1: Configuration Manager Singleton
# ============================================================================

class ConfigurationManager implements IConfigManager
    public var settings: Settings
    public var configFile: string
    
    def new(configFile: string)
        this.configFile = configFile
        this.settings = {}
        this.LoadDefaults()
    enddef
    
    def LoadDefaults(): void
        this.settings = {
            'theme': 'dark',
            'fontSize': 12,
            'autoSave': true,
            'indentSize': 4
        }
    enddef
    
    def Get(key: SettingKey): any
        return has_key(this.settings, key) ? this.settings[key] : null
    enddef
    
    def Set(key: SettingKey, value: any): void
        this.settings[key] = value
    enddef
    
    def GetAll(): Settings
        return copy(this.settings)
    enddef
    
    def Display(): OutputLines
        var result: OutputLines = []
        result->add("Configuration Settings:")
        result->add(repeat("-", 40))
        for key in keys(this.settings)->sort()
            result->add(printf("  %-15s: %s", key, string(this.settings[key])))
        endfor
        return result
    enddef
endclass

# Singleton instance holder (script-local variable)
var configInstance: ConfigurationManager = null_object

# Factory function to get the singleton instance
def g:GetConfigurationManager(): ConfigurationManager
    if configInstance == null_object
        configInstance = ConfigurationManager.new("config.vim")
    endif
    return configInstance
enddef


# ============================================================================
# Example 2: Logger Singleton
# ============================================================================

class Logger implements ILogger
    public var logLevel: LogLevel
    public var logHistory: LogHistory
    public var maxHistorySize: number
    
    def new()
        this.logLevel = LogLevel.Info
        this.logHistory = []
        this.maxHistorySize = 100
    enddef
    
    def SetLevel(level: LogLevel): void
        this.logLevel = level
    enddef
    
    def Log(level: LogLevel, message: string): void
        var timestamp = strftime("%Y-%m-%d %H:%M:%S")
        var logEntry = printf("[%s] %s: %s", timestamp, LogLevelLabel(level), message)
        
        # Add to history
        this.logHistory->add(logEntry)
        
        # Trim history if too large
        if len(this.logHistory) > this.maxHistorySize
            this.logHistory = this.logHistory[-this.maxHistorySize : ]
        endif
        
        # Only output if level is appropriate
        if this.ShouldLog(level)
            echo logEntry
        endif
    enddef
    
    def ShouldLog(level: LogLevel): bool
        var levels = [LogLevel.Debug, LogLevel.Info, LogLevel.Warning, LogLevel.Error]
        var currentLevelIndex = index(levels, this.logLevel)
        var messageLevelIndex = index(levels, level)
        return messageLevelIndex >= currentLevelIndex
    enddef
    
    def Debug(message: string): void
        this.Log(LogLevel.Debug, message)
    enddef
    
    def Info(message: string): void
        this.Log(LogLevel.Info, message)
    enddef
    
    def Warning(message: string): void
        this.Log(LogLevel.Warning, message)
    enddef
    
    def Error(message: string): void
        this.Log(LogLevel.Error, message)
    enddef
    
    def GetHistory(count: number = 10): LogHistory
        var histLen = len(this.logHistory)
        if histLen == 0
            return []
        endif
        var startIdx = max([0, histLen - count])
        return this.logHistory[startIdx : ]
    enddef
    
    def Clear(): void
        this.logHistory = []
    enddef
endclass

# Singleton instance holder
var loggerInstance: Logger = null_object

# Factory function to get the singleton instance
def g:GetLogger(): Logger
    if loggerInstance == null_object
        loggerInstance = Logger.new()
    endif
    return loggerInstance
enddef


# ============================================================================
# Example 3: Database Connection Singleton
# ============================================================================

class DatabaseConnection implements IDatabaseConnection
    public var host: string
    public var port: number
    public var database: string
    public var state: ConnectionState
    public var connectionTime: string
    public var queryCount: number
    
    def new(host: string, port: number, database: string)
        this.host = host
        this.port = port
        this.database = database
        this.state = ConnectionState.Disconnected
        this.connectionTime = ""
        this.queryCount = 0
    enddef
    
    def Connect(): bool
        if this.state == ConnectionState.Connected
            echo "Already connected to database"
            return true
        endif
        
        # Simulate connection
        this.state = ConnectionState.Connected
        this.connectionTime = strftime("%Y-%m-%d %H:%M:%S")
        echo $"Connected to {this.database} at {this.host}:{this.port}"
        return true
    enddef
    
    def Disconnect(): void
        if this.state == ConnectionState.Connected
            this.state = ConnectionState.Disconnected
            echo $"Disconnected from {this.database}"
        endif
    enddef
    
    def Query(sql: string): list<string>
        if this.state != ConnectionState.Connected
            throw "Not connected to database"
        endif
        
        this.queryCount += 1
        # Simulate query execution
        return [$"Query executed: {sql}", $"Rows affected: {this.queryCount}"]
    enddef
    
    def GetStatus(): OutputLines
        var result: OutputLines = []
        result->add("Database Connection Status:")
        result->add(repeat("-", 40))
        result->add($"  Host:            {this.host}:{this.port}")
        result->add($"  Database:        {this.database}")
        result->add($"  Connected:       {this.state == ConnectionState.Connected ? 'Yes' : 'No'}")
        if this.state == ConnectionState.Connected
            result->add($"  Connected since: {this.connectionTime}")
            result->add($"  Queries run:     {this.queryCount}")
        endif
        return result
    enddef
endclass

# Singleton instance holder
var dbInstance: DatabaseConnection = null_object

# Factory function to get the singleton instance
def g:GetDatabaseConnection(): DatabaseConnection
    if dbInstance == null_object
        dbInstance = DatabaseConnection.new("localhost", 5432, "myapp_db")
    endif
    return dbInstance
enddef


# ============================================================================
# Example 4: Application State Singleton
# ============================================================================

class ApplicationState implements IApplicationState
    public var currentUser: string
    public var authState: AuthState
    public var sessionData: dict<any>
    public var startTime: string
    
    def new()
        this.currentUser = "guest"
        this.authState = AuthState.Anonymous
        this.sessionData = {}
        this.startTime = strftime("%Y-%m-%d %H:%M:%S")
    enddef
    
    def Login(username: string): void
        this.currentUser = username
        this.authState = AuthState.Authenticated
        this.sessionData['loginTime'] = strftime("%Y-%m-%d %H:%M:%S")
        echo $"User '{username}' logged in successfully"
    enddef
    
    def Logout(): void
        var username = this.currentUser
        this.currentUser = "guest"
        this.authState = AuthState.Anonymous
        this.sessionData = {}
        echo $"User '{username}' logged out"
    enddef
    
    def SetSessionData(key: string, value: any): void
        this.sessionData[key] = value
    enddef
    
    def GetSessionData(key: string): any
        return has_key(this.sessionData, key) ? this.sessionData[key] : null
    enddef
    
    def GetInfo(): OutputLines
        var result: OutputLines = []
        result->add("Application State:")
        result->add(repeat("-", 40))
        result->add($"  Current User:    {this.currentUser}")
        result->add($"  Authenticated:   {this.authState == AuthState.Authenticated ? 'Yes' : 'No'}")
        result->add($"  Started:         {this.startTime}")
        result->add($"  Session Data:    {len(this.sessionData)} items")
        return result
    enddef
endclass

# Singleton instance holder
var appStateInstance: ApplicationState = null_object

# Factory function to get the singleton instance
def g:GetApplicationState(): ApplicationState
    if appStateInstance == null_object
        appStateInstance = ApplicationState.new()
    endif
    return appStateInstance
enddef


# ============================================================================
# Demonstration Functions
# ============================================================================

def DemonstrateConfigurationSingleton(): OutputLines
    var results: OutputLines = []
    
    results->add("╔════════════════════════════════════════╗")
    results->add("║  CONFIGURATION MANAGER SINGLETON       ║")
    results->add("╚════════════════════════════════════════╝")
    results->add("")
    
    # Get first instance
    var config1 = g:GetConfigurationManager()
    results->add("1. Got first configuration instance")
    results->extend(config1.Display())
    results->add("")
    
    # Modify settings
    config1.Set('theme', 'light')
    config1.Set('fontSize', 14)
    results->add("2. Modified settings in first instance")
    results->add("")
    
    # Get "second" instance - should be the same object
    var config2 = g:GetConfigurationManager()
    results->add("3. Got second configuration instance")
    results->extend(config2.Display())
    results->add("")
    
    results->add("4. Verification: Both instances share the same data")
    results->add($"   Instance 1 theme: {config1.Get('theme')}")
    results->add($"   Instance 2 theme: {config2.Get('theme')}")
    results->add($"   Same instance: {config1 == config2 ? 'Yes' : 'No'}")
    
    return results
enddef


def DemonstrateLoggerSingleton(): OutputLines
    var results: OutputLines = []
    
    results->add("╔════════════════════════════════════════╗")
    results->add("║      LOGGER SINGLETON DEMO             ║")
    results->add("╚════════════════════════════════════════╝")
    results->add("")
    
    # Get logger instance
    var logger1 = g:GetLogger()
    logger1.SetLevel(LogLevel.Info)
    
    results->add("1. Logging messages from first instance:")
    logger1.Info("Application started")
    logger1.Warning("Low memory warning")
    logger1.Error("Connection failed")
    results->add("")
    
    # Get another reference to the logger
    var logger2 = g:GetLogger()
    
    results->add("2. Logging from second instance:")
    logger2.Info("Processing request")
    results->add("")
    
    results->add("3. History from second instance shows all logs:")
    var history = logger2.GetHistory(5)
    for entry in history
        results->add($"   {entry}")
    endfor
    results->add("")
    
    results->add($"4. Same instance: {logger1 == logger2 ? 'Yes' : 'No'}")
    
    return results
enddef


def DemonstrateDatabaseSingleton(): OutputLines
    var results: OutputLines = []
    
    results->add("╔════════════════════════════════════════╗")
    results->add("║    DATABASE CONNECTION SINGLETON       ║")
    results->add("╚════════════════════════════════════════╝")
    results->add("")
    
    # Get database connection
    var db1 = g:GetDatabaseConnection()
    db1.Connect()
    results->add("1. First connection opened")
    results->extend(db1.GetStatus())
    results->add("")
    
    # Execute some queries
    db1.Query("SELECT * FROM users")
    db1.Query("UPDATE settings SET value = 'new'")
    results->add("2. Executed queries on first connection")
    results->add("")
    
    # Get another reference
    var db2 = g:GetDatabaseConnection()
    results->add("3. Got second connection reference")
    results->extend(db2.GetStatus())
    results->add("")
    
    results->add("4. Both references point to same connection")
    results->add($"   Same instance: {db1 == db2 ? 'Yes' : 'No'}")
    results->add($"   Query count from db1: {db1.queryCount}")
    results->add($"   Query count from db2: {db2.queryCount}")
    
    return results
enddef


def DemonstrateApplicationStateSingleton(): OutputLines
    var results: OutputLines = []
    
    results->add("╔════════════════════════════════════════╗")
    results->add("║    APPLICATION STATE SINGLETON         ║")
    results->add("╚════════════════════════════════════════╝")
    results->add("")
    
    # Get application state
    var app1 = g:GetApplicationState()
    results->add("1. Initial application state:")
    results->extend(app1.GetInfo())
    results->add("")
    
    # Login user
    app1.Login("john.doe")
    app1.SetSessionData("lastPage", "/dashboard")
    app1.SetSessionData("preferences", {'theme': 'dark', 'lang': 'en'})
    results->add("2. After user login:")
    results->extend(app1.GetInfo())
    results->add("")
    
    # Get state from another part of application
    var app2 = g:GetApplicationState()
    results->add("3. State accessed from another component:")
    results->extend(app2.GetInfo())
    results->add("")
    
    results->add("4. Verification:")
    results->add($"   Same instance: {app1 == app2 ? 'Yes' : 'No'}")
    results->add($"   Current user from app1: {app1.currentUser}")
    results->add($"   Current user from app2: {app2.currentUser}")
    
    return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunSingletonPatternDemo()
    echo "Singleton Design Pattern Demo"
    echo repeat("=", 60)
    echo ""
    
    try
        # Configuration Manager Demo
        var output1 = DemonstrateConfigurationSingleton()
        for line in output1
            echo line
        endfor
        echo ""
        echo repeat("=", 60)
        echo ""
        
        # Logger Demo
        var output2 = DemonstrateLoggerSingleton()
        for line in output2
            echo line
        endfor
        echo ""
        echo repeat("=", 60)
        echo ""
        
        # Database Demo
        var output3 = DemonstrateDatabaseSingleton()
        for line in output3
            echo line
        endfor
        echo ""
        echo repeat("=", 60)
        echo ""
        
        # Application State Demo
        var output4 = DemonstrateApplicationStateSingleton()
        for line in output4
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
    g:RunSingletonPatternDemo()
endif
