# Use Jekyll's existing Rouge highlighter for ```plank (or ```plk) fences.
# Reference: monorepo-plank2/plank-tree-sitter/grammar.js and
# plank-vscode/syntaxes/plank.tmLanguage.json.
require 'rouge'

module Rouge
  module Lexers
    class Plank < RegexLexer
      title 'Plank'
      tag 'plank'
      aliases 'plk'
      filenames '*.plk'

      state :root do
        rule %r/\s+/, Text
        rule %r{//[^\n]*}, Comment::Single
        rule %r{/\*}, Comment::Multiline, :comment
        rule %r/(?:hex)?"/, Str::Double, :string
        rule %r/@[a-zA-Z_][a-zA-Z0-9_]*/, Name::Builtin
        rule %r/\$[a-zA-Z_][a-zA-Z0-9_]*/, Keyword::Type
        rule %r/\b(?:if|else|match|while|return|inline|const|let|mut|fn|struct|tuple|init|run|pub|use|import|as|comptime|eager)\b/, Keyword
        rule %r/\b(?:and|or)\b/, Operator::Word
        rule %r/\b(?:Self|u256|bool|void|type|function|never|cbytes|memptr)\b/, Keyword::Type
        rule %r/\b(?:true|false)\b/, Keyword::Constant
        rule %r/\b0x[0-9a-fA-F][0-9a-fA-F_]*\b/, Num::Hex
        rule %r/\b0b[01][01_]*\b/, Num::Bin
        rule %r/\b[0-9][0-9_]*\b/, Num::Integer
        rule %r/[a-zA-Z_][a-zA-Z0-9_]*(?=\s*\()/, Name::Function
        rule %r/[a-zA-Z_][a-zA-Z0-9_]*/, Name
        rule %r{[+*-]%|[+<>-]/|<<|>>|==|!=|<=|>=|=>|[+*/%<>=!~&|^\-]}, Operator
        rule %r/[{}()\[\],;:.]/, Punctuation
      end

      state :comment do
        rule %r{/\*}, Comment::Multiline, :push
        rule %r{\*/}, Comment::Multiline, :pop!
        rule %r{[^*/]+|[*/]}, Comment::Multiline
      end

      state :string do
        rule %r/\\./m, Str::Escape
        rule %r/"/, Str::Double, :pop!
        rule %r/[^"\\]+/, Str::Double
      end
    end
  end
end
