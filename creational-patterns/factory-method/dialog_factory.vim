vim9script

# Factory Method Design Pattern - Dialog Example
# This example demonstrates creating different types of dialogs based on platform

type Title = string
type OutputLines = list<string>

enum Platform
    Windows,
    Linux,
    MacOS
endenum

interface IDialog
    def Render(): string
    def Show(): string
endinterface

# ============================================================================
# Product Interface - Dialog
# ============================================================================

# Abstract base class for all dialogs
abstract class Dialog implements IDialog
    public var title: Title

    # Factory method to be implemented by subclasses
    abstract def Render(): string

    # Common operation using the factory method
    def Show(): string
        var content = this.Render()
        return $"=== {this.title} ===\n{content}\n{repeat('=', strlen(this.title) + 8)}"
    enddef
endclass


# ============================================================================
# Concrete Products - Specific Dialog Types
# ============================================================================

# Windows-style dialog
class WindowsDialog extends Dialog
    public var buttons: list<string>

    def new(title: Title, buttons: list<string> = ['OK', 'Cancel'])
        this.title = title
        this.buttons = buttons
    enddef

    def Render(): string
        var result = "Windows Dialog Box\n"
        result ..= "┌" .. repeat("─", 40) .. "┐\n"
        result ..= "│ " .. this.title->strpart(0, 38)->printf("%-38s") .. " │\n"
        result ..= "└" .. repeat("─", 40) .. "┘\n"
        result ..= "Buttons: [" .. this.buttons->join("] [") .. "]"
        return result
    enddef
endclass


# Linux/GTK-style dialog
class LinuxDialog extends Dialog
    public var icon: string

    def new(title: Title, icon: string = '💡')
        this.title = title
        this.icon = icon
    enddef

    def Render(): string
        var result = "GTK Dialog\n"
        result ..= $"{this.icon} {this.title}\n"
        result ..= repeat("─", 40) .. "\n"
        result ..= "[ OK ] [ Cancel ]"
        return result
    enddef
endclass


# MacOS-style dialog
class MacOSDialog extends Dialog
    public var style: string
    public var icon: string = '🍎'

    def new(title: Title, style: string = 'light')
        this.title = title
        this.style = style
    enddef

    def Render(): string
        var result = "macOS Dialog\n"
        result ..= $"Style: {this.style}\n"
        result ..= "╭" .. repeat("─", 40) .. "╮\n"
        result ..= "│ " .. this.icon->printf("%s %-36s", this.title) .. " │\n"
        result ..= "╰" .. repeat("─", 40) .. "╯\n"
        result ..= "        Cancel        OK"
        return result
    enddef
endclass


# ============================================================================
# Creator Interface - Application
# ============================================================================

# Abstract creator class with factory method
interface IApplication
    def Run(): OutputLines
endinterface

abstract class Application implements IApplication
    public var name: string

    # Factory Method - to be overridden by subclasses
    abstract def CreateDialog(title: Title): IDialog

    # Business logic that uses the factory method
    def Run(): OutputLines
        var results: OutputLines = []
        
        results->add($"Starting {this.name}...")
        
        # The application doesn't know which concrete dialog will be created
        var confirmDialog = this.CreateDialog("Save changes?")
        results->add(confirmDialog.Show())
        
        var alertDialog = this.CreateDialog("Operation completed!")
        results->add(alertDialog.Show())
        
        return results
    enddef
endclass


# ============================================================================
# Concrete Creators - Platform-specific Applications
# ============================================================================

class WindowsApplication extends Application
    def new(name: string = "Windows App")
        this.name = name
    enddef

    # Factory Method implementation
    def CreateDialog(title: Title): IDialog
        return WindowsDialog.new(title, ['Yes', 'No'])
    enddef
endclass


class LinuxApplication extends Application
    def new(name: string = "Linux App")
        this.name = name
    enddef

    # Factory Method implementation
    def CreateDialog(title: Title): IDialog
        return LinuxDialog.new(title, '🐧')
    enddef
endclass


class MacOSApplication extends Application
    def new(name: string = "macOS App")
        this.name = name
    enddef

    # Factory Method implementation
    def CreateDialog(title: Title): IDialog
        return MacOSDialog.new(title, 'dark')
    enddef
endclass


# ============================================================================
# Client Code
# ============================================================================

def DemonstrateFactoryMethod(platform: Platform): OutputLines
    var app: Application
    
    # Client code works with creator through the abstract interface
    if platform == Platform.Windows
        app = WindowsApplication.new()
    elseif platform == Platform.Linux
        app = LinuxApplication.new()
    elseif platform == Platform.MacOS
        app = MacOSApplication.new()
    else
        throw $"Unknown platform: {platform.name}"
    endif
    
    return app.Run()
enddef


# ============================================================================
# Demo Execution
# ============================================================================

def g:RunDialogFactoryDemo()
    echo "Dialog Factory Method Pattern Demo"
    echo repeat("=", 60)
    echo ""
    
    # Test all platforms
    for platform in [Platform.Windows, Platform.Linux, Platform.MacOS]
        echo $"🎯 Running on {platform.name->toupper()}:"
        echo repeat("-", 60)
        
        try
            var output = DemonstrateFactoryMethod(platform)
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
    g:RunDialogFactoryDemo()
endif
