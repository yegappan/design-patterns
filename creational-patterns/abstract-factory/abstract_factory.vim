vim9script

# Abstract Factory Design Pattern in Vim9script
# This example demonstrates creating families of related UI components for different platforms

type Label = string
type Placeholder = string
type OutputLines = list<string>

enum Platform
    Windows,
    Linux,
    MacOS
endenum

interface IButton
    def Render(): string
endinterface

interface ICheckbox
    def Render(): string
endinterface

interface ITextInput
    def Render(): string
endinterface

# ============================================================================
# Abstract Product Families
# ============================================================================

# Abstract Button interface
abstract class Button implements IButton
    public var label: Label
    
    abstract def Render(): string
endclass


# Abstract Checkbox interface
abstract class Checkbox implements ICheckbox
    public var label: Label
    public var checked: bool = false
    
    abstract def Render(): string
endclass


# Abstract TextInput interface
abstract class TextInput implements ITextInput
    public var placeholder: Placeholder
    
    abstract def Render(): string
endclass


# ============================================================================
# Concrete Products - Windows UI Components
# ============================================================================

class WindowsButton extends Button
    def new(label: string)
        this.label = label
    enddef
    
    def Render(): string
        return $"[{this.label}] (Windows Button)"
    enddef
endclass


class WindowsCheckbox extends Checkbox
    def new(label: string, checked: bool = false)
        this.label = label
        this.checked = checked
    enddef
    
    def Render(): string
        var state = this.checked ? '☑' : '☐'
        return $"{state} {this.label} (Windows Checkbox)"
    enddef
endclass


class WindowsTextInput extends TextInput
    def new(placeholder: string)
        this.placeholder = placeholder
    enddef
    
    def Render(): string
        var padded = printf("%-19s", this.placeholder)
        return $"┌─────────────────────┐\n│ {padded} │\n└─────────────────────┘ (Windows TextInput)"
    enddef
endclass


# ============================================================================
# Concrete Products - Linux/GTK UI Components
# ============================================================================

class LinuxButton extends Button
    def new(label: string)
        this.label = label
    enddef
    
    def Render(): string
        return $"( {this.label} ) (GTK Button)"
    enddef
endclass


class LinuxCheckbox extends Checkbox
    def new(label: string, checked: bool = false)
        this.label = label
        this.checked = checked
    enddef
    
    def Render(): string
        var state = this.checked ? '✓' : ' '
        return $"[{state}] {this.label} (GTK Checkbox)"
    enddef
endclass


class LinuxTextInput extends TextInput
    def new(placeholder: string)
        this.placeholder = placeholder
    enddef
    
    def Render(): string
        return $"|_{this.placeholder}_| (GTK TextInput)"
    enddef
endclass


# ============================================================================
# Concrete Products - macOS UI Components
# ============================================================================

class MacOSButton extends Button
    def new(label: string)
        this.label = label
    enddef
    
    def Render(): string
        return $"‹ {this.label} › (macOS Button)"
    enddef
endclass


class MacOSCheckbox extends Checkbox
    def new(label: string, checked: bool = false)
        this.label = label
        this.checked = checked
    enddef
    
    def Render(): string
        var state = this.checked ? '◉' : '◯'
        return $"{state} {this.label} (macOS Checkbox)"
    enddef
endclass


class MacOSTextInput extends TextInput
    def new(placeholder: string)
        this.placeholder = placeholder
    enddef
    
    def Render(): string
        var padded = printf("%-19s", this.placeholder)
        return $"╭─────────────────────╮\n│ {padded} │\n╰─────────────────────╯ (macOS TextInput)"
    enddef
endclass


# ============================================================================
# Abstract Factory Interface
# ============================================================================

interface IGUIFactory
    def CreateButton(label: Label): IButton
    def CreateCheckbox(label: Label, checked: bool): ICheckbox
    def CreateTextInput(placeholder: Placeholder): ITextInput
endinterface

abstract class GUIFactory implements IGUIFactory
    abstract def CreateButton(label: Label): IButton
    abstract def CreateCheckbox(label: Label, checked: bool): ICheckbox
    abstract def CreateTextInput(placeholder: Placeholder): ITextInput
endclass


# ============================================================================
# Concrete Factories
# ============================================================================

class WindowsFactory extends GUIFactory
    def CreateButton(label: Label): IButton
        return WindowsButton.new(label)
    enddef
    
    def CreateCheckbox(label: Label, checked: bool): ICheckbox
        return WindowsCheckbox.new(label, checked)
    enddef
    
    def CreateTextInput(placeholder: Placeholder): ITextInput
        return WindowsTextInput.new(placeholder)
    enddef
endclass


class LinuxFactory extends GUIFactory
    def CreateButton(label: Label): IButton
        return LinuxButton.new(label)
    enddef
    
    def CreateCheckbox(label: Label, checked: bool): ICheckbox
        return LinuxCheckbox.new(label, checked)
    enddef
    
    def CreateTextInput(placeholder: Placeholder): ITextInput
        return LinuxTextInput.new(placeholder)
    enddef
endclass


class MacOSFactory extends GUIFactory
    def CreateButton(label: Label): IButton
        return MacOSButton.new(label)
    enddef
    
    def CreateCheckbox(label: Label, checked: bool): ICheckbox
        return MacOSCheckbox.new(label, checked)
    enddef
    
    def CreateTextInput(placeholder: Placeholder): ITextInput
        return MacOSTextInput.new(placeholder)
    enddef
endclass


# ============================================================================
# Application - Uses Abstract Factory
# ============================================================================

class LoginDialog
    public var factory: IGUIFactory
    public var button: IButton
    public var rememberCheckbox: ICheckbox
    public var usernameInput: ITextInput
    public var passwordInput: ITextInput
    
    def new(factory: IGUIFactory)
        this.factory = factory
        # Create all UI components using the factory
        this.button = factory.CreateButton("Login")
        this.rememberCheckbox = factory.CreateCheckbox("Remember me", false)
        this.usernameInput = factory.CreateTextInput("Username")
        this.passwordInput = factory.CreateTextInput("Password")
    enddef
    
    def Render(): OutputLines
        var result: OutputLines = []
        
        result->add("╔════════════════════════════╗")
        result->add("║      LOGIN DIALOG          ║")
        result->add("╚════════════════════════════╝")
        result->add("")
        
        result->add("Username:")
        for line in this.usernameInput.Render()->split("\n")
            result->add($"  {line}")
        endfor
        result->add("")
        
        result->add("Password:")
        for line in this.passwordInput.Render()->split("\n")
            result->add($"  {line}")
        endfor
        result->add("")
        
        result->add($"  {this.rememberCheckbox.Render()}")
        result->add("")
        
        result->add($"  {this.button.Render()}")
        
        return result
    enddef
endclass


# ============================================================================
# Client Code
# ============================================================================

def CreateFactory(platform: Platform): IGUIFactory
    if platform == Platform.Windows
        return WindowsFactory.new()
    elseif platform == Platform.Linux
        return LinuxFactory.new()
    elseif platform == Platform.MacOS
        return MacOSFactory.new()
    else
        throw $"Unknown platform: {platform.name}"
    endif
enddef


def DemonstrateAbstractFactory(platform: Platform): OutputLines
    var results: OutputLines = []
    
    var factory = CreateFactory(platform)
    var dialog = LoginDialog.new(factory)
    
    results->extend(dialog.Render())
    
    return results
enddef


# ============================================================================
# Demo Execution
# ============================================================================

def g:RunAbstractFactoryDemo()
    echo "Abstract Factory Design Pattern Demo"
    echo repeat("=", 60)
    echo ""
    
    # Test all platforms
    for platform in [Platform.Windows, Platform.Linux, Platform.MacOS]
        echo $"\n🎯 {platform.name->toupper()} Platform:"
        echo repeat("-", 60)
        
        try
            var output = DemonstrateAbstractFactory(platform)
            for line in output
                echo line
            endfor
        catch
            echohl ErrorMsg
            echo $"Error: {v:exception}"
            echohl None
        endtry
        
        echo ""
    endfor
    
    echo repeat("=", 60)
    echo "Demo completed!"
enddef


# Run demo if executed directly
if expand('%:p') == expand('<sfile>:p')
    g:RunAbstractFactoryDemo()
endif
