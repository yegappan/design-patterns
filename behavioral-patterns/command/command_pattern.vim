vim9script

# Command Design Pattern in Vim9script
# Demonstrates classes, interfaces, enums, type aliases, and abstract classes.

type OutputLines = list<string>

type Amount = number

enum CommandType
  Deposit,
  Withdraw,
  Transfer
endenum

interface ICommand
  def Execute(output: OutputLines): void
  def Describe(): string
endinterface

abstract class CommandBase
  abstract def Execute(output: OutputLines): void
  abstract def Describe(): string
endclass

class BankAccount
  var owner: string
  var balance: Amount

  def new(owner: string, balance: Amount)
    this.owner = owner
    this.balance = balance
  enddef

  def Deposit(amount: Amount): void
    this.balance += amount
  enddef

  def Withdraw(amount: Amount): bool
    if amount > this.balance
      return false
    endif
    this.balance -= amount
    return true
  enddef

  def Summary(): string
    return $'{this.owner} balance: {this.balance}'
  enddef
endclass

class DepositCommand extends CommandBase implements ICommand
  var account: BankAccount
  var amount: Amount

  def new(account: BankAccount, amount: Amount)
    this.account = account
    this.amount = amount
  enddef

  def Execute(output: OutputLines): void
    this.account.Deposit(this.amount)
    output->add($'Deposited {this.amount} -> {this.account.Summary()}')
  enddef

  def Describe(): string
    return $'Deposit {this.amount} to {this.account.owner}'
  enddef
endclass

class WithdrawCommand extends CommandBase implements ICommand
  var account: BankAccount
  var amount: Amount

  def new(account: BankAccount, amount: Amount)
    this.account = account
    this.amount = amount
  enddef

  def Execute(output: OutputLines): void
    if this.account.Withdraw(this.amount)
      output->add($'Withdrew {this.amount} -> {this.account.Summary()}')
    else
      output->add($'Withdraw failed ({this.amount}) -> {this.account.Summary()}')
    endif
  enddef

  def Describe(): string
    return $'Withdraw {this.amount} from {this.account.owner}'
  enddef
endclass

class TransferCommand extends CommandBase implements ICommand
  var fromAccount: BankAccount
  var toAccount: BankAccount
  var amount: Amount

  def new(fromAccount: BankAccount, toAccount: BankAccount, amount: Amount)
    this.fromAccount = fromAccount
    this.toAccount = toAccount
    this.amount = amount
  enddef

  def Execute(output: OutputLines): void
    if this.fromAccount.Withdraw(this.amount)
      this.toAccount.Deposit(this.amount)
      output->add($'Transferred {this.amount} from {this.fromAccount.owner} to {this.toAccount.owner}')
    else
      output->add($'Transfer failed ({this.amount}) from {this.fromAccount.owner}')
    endif
    output->add($'  {this.fromAccount.Summary()}')
    output->add($'  {this.toAccount.Summary()}')
  enddef

  def Describe(): string
    return $'Transfer {this.amount} from {this.fromAccount.owner} to {this.toAccount.owner}'
  enddef
endclass

class CommandInvoker
  var queue: list<ICommand>

  def new()
    this.queue = []
  enddef

  def Add(command: ICommand)
    this.queue->add(command)
  enddef

  def Run(output: OutputLines)
    for command in this.queue
      output->add($'Running: {command.Describe()}')
      command.Execute(output)
    endfor
  enddef
endclass


def DemonstrateCommand(): OutputLines
  var results: OutputLines = []

  results->add("== COMMAND PATTERN DEMO ==")
  results->add("")

  var checking = BankAccount.new('Checking', 500)
  var savings = BankAccount.new('Savings', 1000)

  var invoker = CommandInvoker.new()
  invoker.Add(DepositCommand.new(checking, 200))
  invoker.Add(WithdrawCommand.new(checking, 150))
  invoker.Add(TransferCommand.new(checking, savings, 400))

  invoker.Run(results)

  results->add("")
  results->add("Note: Commands encapsulate operations and can be queued")

  return results
enddef


# ============================================================================
# Main Demo Function
# ============================================================================

def g:RunCommandPatternDemo()
  echo "Command Design Pattern Demo"
  echo repeat("=", 60)
  echo ""

  try
    var output = DemonstrateCommand()
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
  g:RunCommandPatternDemo()
endif
