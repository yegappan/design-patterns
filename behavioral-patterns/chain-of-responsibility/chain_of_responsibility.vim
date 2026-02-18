vim9script

# Chain of Responsibility Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, type aliases, and abstract classes.

type OutputLines = list<string>
type Amount = number

enum RequestKind
  Auth,
  Payment,
  Inventory
endenum

interface IRequest
  def Kind(): RequestKind
  def Describe(): string
  def GetAmount(): Amount
endinterface

class Request implements IRequest
  var kind: RequestKind
  var details: string
  var amount: Amount

  def new(kind: RequestKind, details: string, amount: Amount)
    this.kind = kind
    this.details = details
    this.amount = amount
  enddef

  def Kind(): RequestKind
    return this.kind
  enddef

  def Describe(): string
    return $'{this.kind.name} request: {this.details} (amount {this.amount})'
  enddef

  def GetAmount(): Amount
    return this.amount
  enddef
endclass

interface IHandler
  def SetNext(handler: IHandler): IHandler
  def Handle(request: IRequest, output: OutputLines): bool
endinterface

abstract class Handler
  var next: IHandler

  def SetNext(handler: IHandler): IHandler
    this.next = handler
    return handler
  enddef

  def Handle(request: IRequest, output: OutputLines): bool
    if this.next != null_object
      return this.next.Handle(request, output)
    endif

    output->add($'No handler for {request.Describe()}')
    return false
  enddef
endclass

class AuthHandler extends Handler implements IHandler
  def new()
    this.next = null_object
  enddef

  def Handle(request: IRequest, output: OutputLines): bool
    if request.Kind() == RequestKind.Auth
      output->add($'Auth handled: {request.Describe()}')
      return true
    endif
    return super.Handle(request, output)
  enddef
endclass

class PaymentHandler extends Handler implements IHandler
  var maxAmount: Amount

  def new(maxAmount: Amount)
    this.next = null_object
    this.maxAmount = maxAmount
  enddef

  def Handle(request: IRequest, output: OutputLines): bool
    if request.Kind() == RequestKind.Payment
      if request.GetAmount() <= this.maxAmount
        output->add($'Payment approved: {request.Describe()}')
      else
        output->add($'Payment rejected (limit {this.maxAmount}): {request.Describe()}')
      endif
      return true
    endif
    return super.Handle(request, output)
  enddef
endclass

class InventoryHandler extends Handler implements IHandler
  def new()
    this.next = null_object
  enddef

  def Handle(request: IRequest, output: OutputLines): bool
    if request.Kind() == RequestKind.Inventory
      output->add($'Inventory checked: {request.Describe()}')
      return true
    endif
    return super.Handle(request, output)
  enddef
endclass


def DemonstrateChain(): OutputLines
  var results: OutputLines = []

  results->add("== CHAIN OF RESPONSIBILITY DEMO ==")
  results->add("")

  var auth = AuthHandler.new()
  var payment = PaymentHandler.new(500)
  var inventory = InventoryHandler.new()

  auth.SetNext(payment).SetNext(inventory)

  var requests: list<IRequest> = [
    Request.new(RequestKind.Auth, 'User login', 0),
    Request.new(RequestKind.Payment, 'Order #145', 250),
    Request.new(RequestKind.Payment, 'Order #146', 800),
    Request.new(RequestKind.Inventory, 'Check stock for SKU-99', 0)
  ]

  for req in requests
    auth.Handle(req, results)
  endfor

  results->add("")
  results->add("Note: Requests flow through handlers until one processes them")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunChainOfResponsibilityDemo()
  echo "Chain of Responsibility Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output = DemonstrateChain()
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
  g:RunChainOfResponsibilityDemo()
endif
