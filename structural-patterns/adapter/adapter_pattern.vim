vim9script

# Adapter Design Pattern in Vim9script
# Allows objects with incompatible interfaces to collaborate

type OutputLines = list<string>
type FileName = string
type Amount = float
type TransactionId = string
type JsonData = dict<any>
type XmlData = dict<any>
type PaymentResponse = dict<any>
type PaymentRefundResponse = dict<any>

enum MediaType
    Mp3,
    Vlc,
    Mp4,
    Unknown
endenum

enum TemperatureUnit
    Celsius,
    Fahrenheit
endenum

interface IMediaPlayer
    def Play(filename: FileName): OutputLines
endinterface

def MediaTypeFromExtension(extension: string): MediaType
    var ext = extension->tolower()
    if ext == 'mp3'
        return MediaType.Mp3
    elseif ext == 'vlc'
        return MediaType.Vlc
    elseif ext == 'mp4'
        return MediaType.Mp4
    endif
    return MediaType.Unknown
enddef

# ============================================================================
# Example 1: Media Player Adapter
# ============================================================================

# Target Interface - What the client expects
abstract class MediaPlayer implements IMediaPlayer
    abstract def Play(filename: FileName): OutputLines
endclass

# Adaptee 1 - MP3 Player (already compatible)
class MP3Player extends MediaPlayer
    def Play(filename: FileName): OutputLines
        return [$"Playing MP3 file: {filename}"]
    enddef
endclass

# Adaptee 2 - Advanced Audio Player (incompatible interface)
class AdvancedAudioPlayer
    def PlayVlc(filename: FileName): OutputLines
        return [$"Playing VLC file: {filename}"]
    enddef
    
    def PlayMp4(filename: FileName): OutputLines
        return [$"Playing MP4 file: {filename}"]
    enddef
endclass

# Adapter - Adapts AdvancedAudioPlayer to MediaPlayer interface
class MediaAdapter extends MediaPlayer
    var advancedPlayer: AdvancedAudioPlayer
    var audioType: MediaType
    
    def new(audioType: MediaType)
        this.audioType = audioType
        this.advancedPlayer = AdvancedAudioPlayer.new()
    enddef
    
    def Play(filename: FileName): OutputLines
        if this.audioType == MediaType.Vlc
            return this.advancedPlayer.PlayVlc(filename)
        elseif this.audioType == MediaType.Mp4
            return this.advancedPlayer.PlayMp4(filename)
        else
            return [$"Invalid media type: {this.audioType.name}"]
        endif
    enddef
endclass

# Universal Audio Player - Uses adapter when needed
class AudioPlayer extends MediaPlayer
    var mediaAdapter: MediaAdapter
    
    def new()
        this.mediaAdapter = null_object
    enddef
    
    def Play(filename: FileName): OutputLines
        # Extract file extension
        var extension = fnamemodify(filename, ':e')
        var mediaType = MediaTypeFromExtension(extension)
        
        if mediaType == MediaType.Mp3
            var mp3Player = MP3Player.new()
            return mp3Player.Play(filename)
        elseif mediaType == MediaType.Vlc || mediaType == MediaType.Mp4
            this.mediaAdapter = MediaAdapter.new(mediaType)
            return this.mediaAdapter.Play(filename)
        else
            return [$"Invalid media format: {extension}"]
        endif
    enddef
endclass


# ============================================================================
# Example 2: Payment Gateway Adapter
# ============================================================================

# Target Interface - Standard payment interface
interface IPaymentProcessor
    def ProcessPayment(amount: Amount): OutputLines
    def RefundPayment(transactionId: TransactionId): OutputLines
endinterface

abstract class PaymentProcessor implements IPaymentProcessor
    abstract def ProcessPayment(amount: Amount): OutputLines
    abstract def RefundPayment(transactionId: TransactionId): OutputLines
endclass

# Adaptee 1 - PayPal (different interface)
class PayPalAPI
    def SendPayment(amount: Amount, currency: string): JsonData
        return {
            'status': 'success',
            'transactionId': $"PP-{rand() % 10000}",
            'amount': amount,
            'currency': currency,
            'provider': 'PayPal'
        }
    enddef
    
    def RefundTransaction(transId: TransactionId): JsonData
        return {
            'status': 'refunded',
            'transactionId': transId,
            'provider': 'PayPal'
        }
    enddef
endclass

# Adaptee 2 - Stripe (different interface)
class StripeAPI
    def Charge(amountInCents: number, options: dict<any>): JsonData
        return {
            'success': true,
            'chargeId': $"ch_{rand() % 10000}",
            'amount': amountInCents,
            'provider': 'Stripe'
        }
    enddef
    
    def CreateRefund(chargeId: TransactionId): JsonData
        return {
            'success': true,
            'refundId': $"re_{rand() % 10000}",
            'chargeId': chargeId,
            'provider': 'Stripe'
        }
    enddef
endclass

# Adapter for PayPal
class PayPalAdapter extends PaymentProcessor
    var paypal: PayPalAPI
    var lastTransactionId: TransactionId
    
    def new()
        this.paypal = PayPalAPI.new()
        this.lastTransactionId = ""
    enddef
    
    def ProcessPayment(amount: Amount): OutputLines
        var result = this.paypal.SendPayment(amount, "USD")
        this.lastTransactionId = result.transactionId
        return [
            $"PayPal Payment Processed:",
            $"  Amount: ${amount}",
            $"  Transaction ID: {result.transactionId}",
            $"  Status: {result.status}"
        ]
    enddef
    
    def RefundPayment(transactionId: TransactionId): OutputLines
        var result = this.paypal.RefundTransaction(transactionId)
        return [
            $"PayPal Refund Processed:",
            $"  Transaction ID: {transactionId}",
            $"  Status: {result.status}"
        ]
    enddef
endclass

# Adapter for Stripe
class StripeAdapter extends PaymentProcessor
    var stripe: StripeAPI
    var lastChargeId: TransactionId
    
    def new()
        this.stripe = StripeAPI.new()
        this.lastChargeId = ""
    enddef
    
    def ProcessPayment(amount: Amount): OutputLines
        var amountInCents = float2nr(amount * 100)
        var result = this.stripe.Charge(amountInCents, {})
        this.lastChargeId = result.chargeId
        return [
            $"Stripe Payment Processed:",
            $"  Amount: ${amount}",
            $"  Charge ID: {result.chargeId}",
            $"  Success: {result.success ? 'Yes' : 'No'}"
        ]
    enddef
    
    def RefundPayment(transactionId: TransactionId): OutputLines
        var result = this.stripe.CreateRefund(transactionId)
        return [
            $"Stripe Refund Processed:",
            $"  Charge ID: {transactionId}",
            $"  Refund ID: {result.refundId}",
            $"  Success: {result.success ? 'Yes' : 'No'}"
        ]
    enddef
endclass


# ============================================================================
# Example 3: Data Format Adapter (XML to JSON)
# ============================================================================

# Target Interface - JSON Data Handler
interface IJSONHandler
    def ParseJSON(jsonString: string): JsonData
    def ToJSON(data: JsonData): string
endinterface

abstract class JSONHandler implements IJSONHandler
    abstract def ParseJSON(jsonString: string): JsonData
    abstract def ToJSON(data: JsonData): string
endclass

# Standard JSON Handler
class StandardJSONHandler extends JSONHandler
    def ParseJSON(jsonString: string): JsonData
        # Simplified JSON parsing simulation
        return {'data': jsonString, 'format': 'json'}
    enddef
    
    def ToJSON(data: JsonData): string
        return string(data)
    enddef
endclass

# Adaptee - XML Handler (incompatible interface)
class XMLHandler
    def ParseXML(xmlString: string): XmlData
        # Simplified XML parsing simulation
        var data = {
            'root': 'document',
            'content': xmlString,
            'format': 'xml'
        }
        return data
    enddef
    
    def ToXML(data: XmlData): string
        var xml = "<root>\n"
        for [key, value] in items(data)
            xml ..= $"  <{key}>{value}</{key}>\n"
        endfor
        xml ..= "</root>"
        return xml
    enddef
endclass

# Adapter - Converts XML to JSON interface
class XMLToJSONAdapter extends JSONHandler
    var xmlHandler: XMLHandler
    
    def new()
        this.xmlHandler = XMLHandler.new()
    enddef
    
    def ParseJSON(jsonString: string): JsonData
        # Assume input is actually XML, adapt it
        var xmlData = this.xmlHandler.ParseXML(jsonString)
        # Convert XML structure to JSON-like structure
        return {
            'data': xmlData.content,
            'originalFormat': 'xml',
            'convertedTo': 'json'
        }
    enddef
    
    def ToJSON(data: JsonData): string
        # Convert to XML first, then represent as "JSON"
        var xml = this.xmlHandler.ToXML(data)
        return $'{{"xmlContent": "{escape(xml, '"')}""}}'
    enddef
endclass


# ============================================================================
# Example 4: Legacy System Adapter
# ============================================================================

# Temperature Reading Data Class - More type-safe than dict<any>
class TemperatureReading
    public var value: Amount
    public var unit: TemperatureUnit
    public var location: string
    public var originalValue: Amount
    public var originalUnit: TemperatureUnit
    
    def new(value: Amount, unit: TemperatureUnit, location: string)
        this.value = value
        this.unit = unit
        this.location = location
        this.originalValue = value
        this.originalUnit = unit
    enddef
    
    def ToDict(): dict<any>
        return {
            'value': this.value,
            'unit': this.unit,
            'location': this.location,
            'originalValue': this.originalValue,
            'originalUnit': this.originalUnit
        }
    enddef
endclass

# Target Interface - Modern Temperature Sensor
interface ITemperatureSensor
    def GetTemperature(): TemperatureReading
    def GetUnit(): TemperatureUnit
endinterface

abstract class TemperatureSensor implements ITemperatureSensor
    abstract def GetTemperature(): TemperatureReading
    abstract def GetUnit(): TemperatureUnit
endclass

# Modern sensor (already compatible)
class ModernSensor extends TemperatureSensor
    var location: string
    
    def new(location: string)
        this.location = location
    enddef
    
    def GetTemperature(): TemperatureReading
        var temp = 20.0 + (rand() % 10)
        return TemperatureReading.new(temp, TemperatureUnit.Celsius, this.location)
    enddef
    
    def GetUnit(): TemperatureUnit
        return TemperatureUnit.Celsius
    enddef
endclass

# Adaptee - Legacy Sensor (incompatible interface)
class LegacyTemperatureSensor
    var sensorId: number
    
    def new(sensorId: number)
        this.sensorId = sensorId
    enddef
    
    # Legacy method returns raw temperature in Fahrenheit
    def ReadTemp(): Amount
        return 68.0 + (rand() % 20)
    enddef
    
    def GetSensorId(): number
        return this.sensorId
    enddef
endclass

# Adapter - Adapts legacy sensor to modern interface
class LegacySensorAdapter extends TemperatureSensor
    var legacySensor: LegacyTemperatureSensor
    
    def new(sensorId: number)
        this.legacySensor = LegacyTemperatureSensor.new(sensorId)
    enddef
    
    def GetTemperature(): TemperatureReading
        var fahrenheit = this.legacySensor.ReadTemp()
        var celsius = (fahrenheit - 32.0) * 5.0 / 9.0
        
        var reading = TemperatureReading.new(celsius, TemperatureUnit.Celsius, $"Legacy Sensor #{this.legacySensor.GetSensorId()}")
        reading.originalValue = fahrenheit
        reading.originalUnit = TemperatureUnit.Fahrenheit
        return reading
    enddef
    
    def GetUnit(): TemperatureUnit
        return TemperatureUnit.Celsius
    enddef
endclass


# ============================================================================
# Demonstration Functions
# ============================================================================

def DemonstrateMediaPlayerAdapter(): OutputLines
    var results: OutputLines = []
    
    results->add("╔════════════════════════════════════════╗")
    results->add("║    MEDIA PLAYER ADAPTER DEMO           ║")
    results->add("╚════════════════════════════════════════╝")
    results->add("")
    
    var player = AudioPlayer.new()
    
    results->add("Playing different media formats:")
    results->add("")
    
    var files = [
        "song.mp3",
        "movie.mp4",
        "video.vlc",
        "invalid.avi"
    ]
    
    for file in files
        results->add($"▶ {file}")
        var output = player.Play(file)
        for line in output
            results->add($"  {line}")
        endfor
        results->add("")
    endfor
    
    results->add("Note: The adapter seamlessly handles different formats")
    
    return results
enddef


def DemonstratePaymentAdapter(): OutputLines
    var results: OutputLines = []
    
    results->add("╔════════════════════════════════════════╗")
    results->add("║    PAYMENT GATEWAY ADAPTER DEMO        ║")
    results->add("╚════════════════════════════════════════╝")
    results->add("")
    
    # Create payment processors
    var paypalProcessor = PayPalAdapter.new()
    var stripeProcessor = StripeAdapter.new()
    
    results->add("1. Processing payment through PayPal:")
    results->extend(paypalProcessor.ProcessPayment(99.99))
    results->add("")
    
    results->add("2. Processing payment through Stripe:")
    results->extend(stripeProcessor.ProcessPayment(149.50))
    results->add("")
    
    results->add("3. Refunding PayPal transaction:")
    results->extend(paypalProcessor.RefundPayment(paypalProcessor.lastTransactionId))
    results->add("")
    
    results->add("4. Refunding Stripe transaction:")
    results->extend(stripeProcessor.RefundPayment(stripeProcessor.lastChargeId))
    results->add("")
    
    results->add("Note: Both adapters provide a unified interface")
    results->add("      despite different underlying APIs")
    
    return results
enddef


def DemonstrateDataFormatAdapter(): OutputLines
    var results: OutputLines = []
    
    results->add("╔════════════════════════════════════════╗")
    results->add("║    DATA FORMAT ADAPTER DEMO            ║")
    results->add("╚════════════════════════════════════════╝")
    results->add("")
    
    var jsonHandler = StandardJSONHandler.new()
    var xmlAdapter = XMLToJSONAdapter.new()
    
    results->add("1. Standard JSON Handler:")
    var jsonData = jsonHandler.ParseJSON('{"name": "John", "age": 30}')
    results->add($"  Parsed: {string(jsonData)}")
    results->add("")
    
    results->add("2. XML to JSON Adapter:")
    var xmlData = xmlAdapter.ParseJSON('<person><name>John</name><age>30</age></person>')
    results->add($"  Parsed: {string(xmlData)}")
    results->add("")
    
    results->add("3. Converting data to JSON via XML Adapter:")
    var data: JsonData = {'name': 'Jane', 'role': 'Developer'}
    var jsonOutput = xmlAdapter.ToJSON(data)
    results->add($"  Output: {jsonOutput}")
    results->add("")
    
    results->add("Note: The adapter allows XML data to work with")
    results->add("      a JSON-based interface")
    
    return results
enddef


def DemonstrateLegacySystemAdapter(): OutputLines
    var results: OutputLines = []
    
    results->add("╔════════════════════════════════════════╗")
    results->add("║    LEGACY SYSTEM ADAPTER DEMO          ║")
    results->add("╚════════════════════════════════════════╝")
    results->add("")
    
    # Create sensors
    var modernSensor = ModernSensor.new("Office")
    var legacyAdapter = LegacySensorAdapter.new(101)
    
    # Read from modern sensor
    results->add("1. Modern Sensor Reading:")
    var temp1 = modernSensor.GetTemperature()
    results->add($"  Location: {temp1.location}")
    results->add($"  Temperature: {printf('%.1f', temp1.value)}°{temp1.unit.name->toupper()}")
    results->add("")
    
    # Read from legacy sensor through adapter
    results->add("2. Legacy Sensor Reading (via adapter):")
    var temp2 = legacyAdapter.GetTemperature()
    results->add($"  Location: {temp2.location}")
    results->add($"  Temperature: {printf('%.1f', temp2.value)}°{temp2.unit.name->toupper()}")
    results->add($"  (Converted from: {printf('%.1f', temp2.originalValue)}°F)")
    results->add("")
    
    results->add("3. Comparing sensor interfaces:")
    results->add($"  Modern sensor unit: {modernSensor.GetUnit().name->tolower()}")
    results->add($"  Legacy sensor unit: {legacyAdapter.GetUnit().name->tolower()}")
    results->add("")
    
    results->add("Note: The adapter converts legacy Fahrenheit readings")
    results->add("      to match the modern Celsius interface")
    
    return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunAdapterPatternDemo()
    echo "Adapter Design Pattern Demo"
    echo repeat("=", 60)
    echo ""
    
    try
        # Media Player Demo
        var output1 = DemonstrateMediaPlayerAdapter()
        for line in output1
            echo line
        endfor
        echo ""
        echo repeat("=", 60)
        echo ""
        
        # Payment Gateway Demo
        var output2 = DemonstratePaymentAdapter()
        for line in output2
            echo line
        endfor
        echo ""
        echo repeat("=", 60)
        echo ""
        
        # Data Format Demo
        var output3 = DemonstrateDataFormatAdapter()
        for line in output3
            echo line
        endfor
        echo ""
        echo repeat("=", 60)
        echo ""
        
        # Legacy System Demo
        var output4 = DemonstrateLegacySystemAdapter()
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
    g:RunAdapterPatternDemo()
endif
