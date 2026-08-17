{ pkgs, ... }:
let
  enhancedHighlights = pkgs.writeText "spade-highlights.scm" ''
    ; extends

    (attribute
      (identifier) @attribute)

    (struct_definition
      (identifier) @type.definition)

    (enum_definition
      (identifier) @type.definition)

    (trait
      (identifier) @type.definition)

    (trait
      (scoped_identifier
        name: (identifier) @type.definition))

    (enum_member
      (identifier) @constant)

    (mod
      (identifier) @module)

    (generic_param
      (identifier) @type.parameter .)

    (function_call
      (identifier) @function.call)

    (function_call
      (scoped_identifier
        name: (identifier) @function.call))

    (entity_instance
      (identifier) @function.call)

    (entity_instance
      (scoped_identifier
        name: (identifier) @function.call))

    (pipeline_instance
      (identifier) @function.call)

    (pipeline_instance
      (scoped_identifier
        name: (identifier) @function.call))

    (method_call
      name: (identifier) @function.method.call)

    (field_access
      (_)
      "."
      (identifier) @variable.member)

    (reg_reset
      "reset" @function.builtin)

    (reg_initial
      "initial" @function.builtin)

    (string_literal) @string
    (char_literal) @character
    (label) @label
    (label_ref) @label

    [
      "extern"
      "trait"
      "where"
      "for"
    ] @keyword
  '';

  spade-vim = pkgs.vimUtils.buildVimPlugin {
    pname = "spade-vim";
    version = "0-unstable-1016b4e";
    src = pkgs.fetchFromGitLab {
      owner = "spade-lang";
      repo = "spade-vim";
      rev = "1016b4eafabaa75728569b1ba1bfbf8a849a4ec4";
      hash = "sha256-U4LrO89wHRPQXjILI+tttbWk23TDS2kVPaJbSS33Xvc=";
    };

    postInstall = ''
      install -Dm644 ${enhancedHighlights} "$out/after/queries/spade/highlights.scm"
    '';
  };
in
{
  programs.nixvim.extraPlugins = [ spade-vim ];
}
