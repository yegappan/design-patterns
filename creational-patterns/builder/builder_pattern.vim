vim9script

# Builder Design Pattern in Vim9script
# This example demonstrates building complex objects step by step with different configurations

type PartSpec = string
type OutputLines = list<string>

enum ComputerProfile
    Gaming,
    Workstation,
    Laptop,
    Budget
endenum

# ============================================================================
# Product Being Built
# ============================================================================

class Computer
    public var cpu: PartSpec
    public var ram: PartSpec
    public var storage: PartSpec
    public var gpu: PartSpec
    public var powerSupply: PartSpec
    public var cooling: PartSpec
    
    # Display the computer configuration
    def Display(): OutputLines
        var result: OutputLines = []
        result->add("╔════════════════════════════════════════╗")
        result->add("║         COMPUTER CONFIGURATION         ║")
        result->add("╚════════════════════════════════════════╝")
        result->add("")
        result->add($"CPU:           {this.cpu}")
        result->add($"RAM:           {this.ram}")
        result->add($"Storage:       {this.storage}")
        result->add($"GPU:           {this.gpu}")
        result->add($"Power Supply:  {this.powerSupply}")
        result->add($"Cooling:       {this.cooling}")
        result->add("")
        return result
    enddef
endclass


# ============================================================================
# Abstract Builder Interface
# ============================================================================

interface IComputerBuilder
    def BuildCPU(): void
    def BuildRAM(): void
    def BuildStorage(): void
    def BuildGPU(): void
    def BuildPowerSupply(): void
    def BuildCooling(): void
    def GetComputer(): Computer
endinterface

abstract class ComputerBuilder implements IComputerBuilder
    public var computer: Computer
    
    abstract def BuildCPU(): void
    abstract def BuildRAM(): void
    abstract def BuildStorage(): void
    abstract def BuildGPU(): void
    abstract def BuildPowerSupply(): void
    abstract def BuildCooling(): void
    
    def GetComputer(): Computer
        return this.computer
    enddef
endclass


# ============================================================================
# Concrete Builders
# ============================================================================

class GamingComputerBuilder extends ComputerBuilder
    def new()
        this.computer = Computer.new()
    enddef
    
    def BuildCPU(): void
        this.computer.cpu = "Intel Core i9-14900K (24 cores, 6.0 GHz)"
    enddef
    
    def BuildRAM(): void
        this.computer.ram = "64GB DDR5 6000MHz"
    enddef
    
    def BuildStorage(): void
        this.computer.storage = "2x 2TB NVMe SSD RAID 0"
    enddef
    
    def BuildGPU(): void
        this.computer.gpu = "NVIDIA RTX 4090 (24GB GDDR6X)"
    enddef
    
    def BuildPowerSupply(): void
        this.computer.powerSupply = "1200W 80+ Platinum"
    enddef
    
    def BuildCooling(): void
        this.computer.cooling = "Custom Liquid Cooling (360mm AIO)"
    enddef
endclass


class WorkstationBuilder extends ComputerBuilder
    def new()
        this.computer = Computer.new()
    enddef
    
    def BuildCPU(): void
        this.computer.cpu = "AMD Ryzen Threadripper PRO 5995WX (64 cores)"
    enddef
    
    def BuildRAM(): void
        this.computer.ram = "256GB ECC DDR4 3200MHz"
    enddef
    
    def BuildStorage(): void
        this.computer.storage = "2x 4TB Enterprise SSD with redundancy"
    enddef
    
    def BuildGPU(): void
        this.computer.gpu = "NVIDIA RTX 6000 Ada (48GB GDDR6)"
    enddef
    
    def BuildPowerSupply(): void
        this.computer.powerSupply = "1600W 80+ Titanium"
    enddef
    
    def BuildCooling(): void
        this.computer.cooling = "Custom Dual-Loop Liquid Cooling"
    enddef
endclass


class LaptopBuilder extends ComputerBuilder
    def new()
        this.computer = Computer.new()
    enddef
    
    def BuildCPU(): void
        this.computer.cpu = "Intel Core Ultra 7 165H (14 cores, 5.5 GHz)"
    enddef
    
    def BuildRAM(): void
        this.computer.ram = "32GB LPDDR5X"
    enddef
    
    def BuildStorage(): void
        this.computer.storage = "2TB NVMe SSD"
    enddef
    
    def BuildGPU(): void
        this.computer.gpu = "Intel Arc A770M (4GB)"
    enddef
    
    def BuildPowerSupply(): void
        this.computer.powerSupply = "100W USB-C PD Adapter"
    enddef
    
    def BuildCooling(): void
        this.computer.cooling = "Passive thermal management + fans"
    enddef
endclass


class BudgetComputerBuilder extends ComputerBuilder
    def new()
        this.computer = Computer.new()
    enddef
    
    def BuildCPU(): void
        this.computer.cpu = "AMD Ryzen 5 7600X (6 cores, 5.3 GHz)"
    enddef
    
    def BuildRAM(): void
        this.computer.ram = "16GB DDR5 5600MHz"
    enddef
    
    def BuildStorage(): void
        this.computer.storage = "512GB NVMe SSD"
    enddef
    
    def BuildGPU(): void
        this.computer.gpu = "AMD Radeon RX 6700 (10GB)"
    enddef
    
    def BuildPowerSupply(): void
        this.computer.powerSupply = "650W 80+ Bronze"
    enddef
    
    def BuildCooling(): void
        this.computer.cooling = "Stock CPU cooler"
    enddef
endclass


# ============================================================================
# Director - Orchestrates the Building Process
# ============================================================================

class ComputerDirector
    public var builder: ComputerBuilder
    
    def new(builder: ComputerBuilder)
        this.builder = builder
    enddef
    
    # Complete build process
    def Construct(): Computer
        this.builder.BuildCPU()
        this.builder.BuildRAM()
        this.builder.BuildStorage()
        this.builder.BuildGPU()
        this.builder.BuildPowerSupply()
        this.builder.BuildCooling()
        
        return this.builder.GetComputer()
    enddef
endclass


# ============================================================================
# Client Code
# ============================================================================

def BuildComputer(computerType: ComputerProfile): Computer
    var builder: ComputerBuilder
    
    # Select appropriate builder
    if computerType == ComputerProfile.Gaming
        builder = GamingComputerBuilder.new()
    elseif computerType == ComputerProfile.Workstation
        builder = WorkstationBuilder.new()
    elseif computerType == ComputerProfile.Laptop
        builder = LaptopBuilder.new()
    elseif computerType == ComputerProfile.Budget
        builder = BudgetComputerBuilder.new()
    else
        throw $"Unknown computer type: {computerType.name}"
    endif
    
    # Use director to build
    var director = ComputerDirector.new(builder)
    return director.Construct()
enddef


def DemonstrateBuilderPattern(): OutputLines
    var results: OutputLines = []
    
    # Build different computer types
    for computerType in [ComputerProfile.Gaming, ComputerProfile.Workstation, ComputerProfile.Laptop, ComputerProfile.Budget]
        try
            var computer = BuildComputer(computerType)
            results->extend(computer.Display())
        catch
            results->add($"Error building {computerType.name}: {v:exception}")
        endtry
    endfor
    
    return results
enddef


# ============================================================================
# Demo Execution
# ============================================================================

def g:RunBuilderPatternDemo()
    echo "Builder Design Pattern Demo"
    echo repeat("=", 60)
    echo ""
    
    try
        var output = DemonstrateBuilderPattern()
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


# ============================================================================
# Alternative: Step-by-Step Manual Building
# ============================================================================

def DemonstrateFluent(): OutputLines
    var results: OutputLines = []
    
    results->add("Alternative: Manual Step-by-Step Building")
    results->add(repeat("=", 60))
    results->add("")
    
    # Manually build a custom gaming laptop
    var builder = GamingComputerBuilder.new()
    builder.BuildCPU()
    builder.BuildRAM()
    builder.BuildStorage()
    # Use laptop GPU instead
    builder.computer.gpu = "NVIDIA RTX 4090 Mobile (16GB)"
    builder.BuildPowerSupply()
    builder.BuildCooling()
    
    results->extend(builder.GetComputer().Display())
    
    return results
enddef


def g:RunFluentBuilderDemo()
    echo "Custom Computer Building (Manual Steps)"
    echo repeat("=", 60)
    echo ""
    
    try
        var output = DemonstrateFluent()
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
    g:RunBuilderPatternDemo()
    echo ""
    g:RunFluentBuilderDemo()
endif
