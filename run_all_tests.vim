vim9script

# Design Patterns - Comprehensive Test Runner
# This script sources and runs all design pattern examples to verify correctness
# Usage: :source run_all_tests.vim

# Global test results
var test_results: list<dict<any>> = []
var total_tests = 0
var passed_tests = 0
var failed_tests = 0

# Print header
def PrintHeader()
  echo ""
  echo repeat("=", 80)
  echo "DESIGN PATTERNS TEST RUNNER"
  echo repeat("=", 80)
  echo ""
enddef

# Test individual pattern
def RunPatternTest(pattern_name: string, pattern_path: string, demo_function: string): bool
  var test_name = $"{pattern_name}"
  var success = true
  var error_msg = ""

  try
    # Source the pattern file
    execute $'source {pattern_path}'

    # Run the demo function
    execute $'call {demo_function}()'

  catch
    success = false
    error_msg = v:exception
  endtry

  # Record result
  test_results->add({
    'name': test_name,
    'path': pattern_path,
    'success': success,
    'error': error_msg
  })

  if success
    echohl None
    echo $'✓ {test_name}'
    passed_tests += 1
  else
    echohl ErrorMsg
    echo $'✗ {test_name}: {error_msg}'
    echohl None
  endif

  total_tests += 1
  return success
enddef

# Print summary report
def PrintSummary()
  echo ""
  echo repeat("=", 80)
  echo "TEST SUMMARY"
  echo repeat("=", 80)

  if failed_tests == 0
    echohl MoreMsg
    echo $"✓ All {passed_tests} tests passed!"
    echohl None
  else
    echohl ErrorMsg
    echo $"✗ {failed_tests} test(s) failed out of {total_tests}"
    echohl None
    echo ""
    echo "Failed tests:"
    for result in test_results
      if !result.success
        echo $"  - {result.name}"
        echo $"    Error: {result.error}"
      endif
    endfor
  endif

  echo ""
  echo repeat("=", 80)
  echo $"Total Tests: {total_tests} | Passed: {passed_tests} | Failed: {failed_tests}"
  echo repeat("=", 80)
  echo ""
enddef

# Main test execution
def RunAllTests()
  PrintHeader()

  # Behavioral Patterns
  echo "BEHAVIORAL PATTERNS"
  echo repeat("-", 80)
  RunPatternTest("Chain of Responsibility",
    'behavioral-patterns/chain-of-responsibility/chain_of_responsibility.vim',
    'g:RunChainOfResponsibilityDemo')
  RunPatternTest("Command",
    'behavioral-patterns/command/command_pattern.vim',
    'g:RunCommandPatternDemo')
  RunPatternTest("Iterator",
    'behavioral-patterns/iterator/iterator_pattern.vim',
    'g:RunIteratorPatternDemo')
  RunPatternTest("Mediator",
    'behavioral-patterns/mediator/mediator_pattern.vim',
    'g:RunMediatorPatternDemo')
  RunPatternTest("Memento",
    'behavioral-patterns/memento/memento_pattern.vim',
    'g:RunMementoPatternDemo')
  RunPatternTest("Observer",
    'behavioral-patterns/observer/observer_pattern.vim',
    'g:RunObserverPatternDemo')
  RunPatternTest("State",
    'behavioral-patterns/state/state_pattern.vim',
    'g:RunStatePatternDemo')
  RunPatternTest("Strategy",
    'behavioral-patterns/strategy/strategy_pattern.vim',
    'g:RunStrategyPatternDemo')
  RunPatternTest("Template Method",
    'behavioral-patterns/template-method/template_method_pattern.vim',
    'g:RunTemplateMethodDemo')
  RunPatternTest("Visitor",
    'behavioral-patterns/visitor/visitor_pattern.vim',
    'g:RunVisitorPatternDemo')

  echo ""
  echo "CREATIONAL PATTERNS"
  echo repeat("-", 80)
  RunPatternTest("Abstract Factory",
    'creational-patterns/abstract-factory/abstract_factory.vim',
    'g:RunAbstractFactoryDemo')
  RunPatternTest("Builder",
    'creational-patterns/builder/builder_pattern.vim',
    'g:RunBuilderPatternDemo')
  RunPatternTest("Builder - Fluent",
    'creational-patterns/builder/builder_pattern.vim',
    'g:RunFluentBuilderDemo')
  RunPatternTest("Factory Method - Dialog",
    'creational-patterns/factory-method/dialog_factory.vim',
    'g:RunDialogFactoryDemo')
  RunPatternTest("Factory Method - Document",
    'creational-patterns/factory-method/document_factory.vim',
    'g:RunDocumentFactoryDemo')
  RunPatternTest("Prototype",
    'creational-patterns/prototype/prototype_pattern.vim',
    'g:RunPrototypePatternDemo')
  RunPatternTest("Prototype - Deep Copy",
    'creational-patterns/prototype/prototype_pattern.vim',
    'g:RunDeepCopyDemo')
  RunPatternTest("Singleton",
    'creational-patterns/singleton/singleton_pattern.vim',
    'g:RunSingletonPatternDemo')

  echo ""
  echo "STRUCTURAL PATTERNS"
  echo repeat("-", 80)
  RunPatternTest("Adapter",
    'structural-patterns/adapter/adapter_pattern.vim',
    'g:RunAdapterPatternDemo')
  RunPatternTest("Bridge",
    'structural-patterns/bridge/bridge_pattern.vim',
    'g:RunBridgePatternDemo')
  RunPatternTest("Composite",
    'structural-patterns/composite/composite_pattern.vim',
    'g:RunCompositePatternDemo')
  RunPatternTest("Decorator",
    'structural-patterns/decorator/decorator_pattern.vim',
    'g:RunDecoratorPatternDemo')
  RunPatternTest("Facade",
    'structural-patterns/facade/facade_pattern.vim',
    'g:RunFacadePatternDemo')
  RunPatternTest("Flyweight",
    'structural-patterns/flyweight/flyweight_pattern.vim',
    'g:RunFlyweightPatternDemo')
  RunPatternTest("Proxy",
    'structural-patterns/proxy/proxy_pattern.vim',
    'g:RunProxyPatternDemo')

  PrintSummary()
enddef

# Execute tests
RunAllTests()
