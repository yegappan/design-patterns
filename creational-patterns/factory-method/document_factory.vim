vim9script

# Factory Method Design Pattern - Document Example
# This example demonstrates creating different types of documents based on editor type

type Content = string
type FileName = string
type OutputLines = list<string>

enum DocumentKind
    Text,
    Markdown
endenum

interface IDocument
    def GetContent(): Content
    def GetExtension(): string
    def Save(filename: FileName): string
endinterface

# ============================================================================
# Product Interface - Document
# ============================================================================

abstract class Document implements IDocument
    abstract def GetContent(): Content
    abstract def GetExtension(): string
    
    def Save(filename: FileName): string
        var fullname = $"{filename}.{this.GetExtension()}"
        return $"Saving {fullname}:\n{this.GetContent()}"
    enddef
endclass


# ============================================================================
# Concrete Products - Specific Document Types
# ============================================================================

class TextDocument extends Document
    public var text: Content
    
    def new(text: Content)
        this.text = text
    enddef
    
    def GetContent(): Content
        return this.text
    enddef
    
    def GetExtension(): string
        return 'txt'
    enddef
endclass


class MarkdownDocument extends Document
    public var markdown: Content
    
    def new(markdown: Content)
        this.markdown = markdown
    enddef
    
    def GetContent(): Content
        return this.markdown
    enddef
    
    def GetExtension(): string
        return 'md'
    enddef
endclass


# ============================================================================
# Creator Interface - DocumentCreator
# ============================================================================

interface IDocumentCreator
    def CreateDocument(content: Content): IDocument
    def NewDocument(content: Content, filename: FileName): string
endinterface

abstract class DocumentCreator implements IDocumentCreator
    abstract def CreateDocument(content: Content): IDocument
    
    def NewDocument(content: Content, filename: FileName): string
        var doc = this.CreateDocument(content)
        return doc.Save(filename)
    enddef
endclass


# ============================================================================
# Concrete Creators - Specific Editors
# ============================================================================

class TextEditor extends DocumentCreator
    def CreateDocument(content: Content): IDocument
        return TextDocument.new(content)
    enddef
endclass


class MarkdownEditor extends DocumentCreator
    def CreateDocument(content: Content): IDocument
        return MarkdownDocument.new($"# Document\n\n{content}")
    enddef
endclass


# ============================================================================
# Client Code
# ============================================================================

def DemonstrateDocumentFactory(): OutputLines
    var results: OutputLines = []
    
    results->add("Document Factory Method Pattern Demo")
    results->add(repeat("=", 50))
    results->add("")
    
    # Create a text document
    results->add("📝 Text Editor:")
    results->add(repeat("-", 50))
    var textEditor = TextEditor.new()
    results->add(textEditor.NewDocument("Hello, World!", "readme"))
    results->add("")
    
    # Create a markdown document
    results->add("📄 Markdown Editor:")
    results->add(repeat("-", 50))
    var mdEditor = MarkdownEditor.new()
    results->add(mdEditor.NewDocument("This is a markdown document.", "readme"))
    results->add("")
    
    results->add(repeat("=", 50))
    results->add("Demo completed!")
    
    return results
enddef


# ============================================================================
# Demo Execution
# ============================================================================

def g:RunDocumentFactoryDemo()
    echo "Document Factory Method Pattern Demo"
    echo repeat("=", 60)
    echo ""

    try
        var output = DemonstrateDocumentFactory()
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
    g:RunDocumentFactoryDemo()
endif
