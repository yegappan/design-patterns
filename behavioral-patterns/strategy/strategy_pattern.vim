vim9script

# Strategy Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, type aliases, and abstract classes.

type OutputLines = list<string>

type Amount = float

enum DiscountType
  None,
  Seasonal,
  Loyalty
endenum

interface IDiscountStrategy
  def Apply(amount: Amount): Amount
  def Name(): string
endinterface

abstract class DiscountBase
  abstract def Apply(amount: Amount): Amount
  abstract def Name(): string
endclass

class NoDiscount extends DiscountBase implements IDiscountStrategy
  def Apply(amount: Amount): Amount
    return amount
  enddef

  def Name(): string
    return 'No Discount'
  enddef
endclass

class SeasonalDiscount extends DiscountBase implements IDiscountStrategy
  var percent: number

  def new(percent: number)
    this.percent = percent
  enddef

  def Apply(amount: Amount): Amount
    return amount * (1.0 - (this.percent / 100.0))
  enddef

  def Name(): string
    return $'Seasonal {this.percent}%'
  enddef
endclass

class LoyaltyDiscount extends DiscountBase implements IDiscountStrategy
  var tiers: dict<number>

  def new()
    this.tiers = {
      1: 2,
      2: 5,
      3: 10
    }
  enddef

  def Apply(amount: Amount): Amount
    var tier = amount >= 500 ? 3 : amount >= 200 ? 2 : 1
    var percent = this.tiers[tier]
    return amount * (1.0 - (percent / 100.0))
  enddef

  def Name(): string
    return 'Loyalty Tiered'
  enddef
endclass

class PricingContext
  var strategy: IDiscountStrategy

  def new(strategy: IDiscountStrategy)
    this.strategy = strategy
  enddef

  def SetStrategy(strategy: IDiscountStrategy)
    this.strategy = strategy
  enddef

  def FinalPrice(amount: Amount): Amount
    return this.strategy.Apply(amount)
  enddef
endclass


def DemonstrateStrategy(): OutputLines
  var results: OutputLines = []

  results->add("== STRATEGY PATTERN DEMO ==")
  results->add("")

  var baseAmount: Amount = 350.0
  var context = PricingContext.new(NoDiscount.new())

  var strategies: list<IDiscountStrategy> = [
    NoDiscount.new(),
    SeasonalDiscount.new(15),
    LoyaltyDiscount.new()
  ]

  for strat in strategies
    context.SetStrategy(strat)
    var final = context.FinalPrice(baseAmount)
    results->add($"{strat.Name()} -> {printf('%.2f', final)}")
  endfor

  results->add("")
  results->add("Note: Strategy changes pricing without changing context")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunStrategyPatternDemo()
  echo "Strategy Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output = DemonstrateStrategy()
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
  g:RunStrategyPatternDemo()
endif
