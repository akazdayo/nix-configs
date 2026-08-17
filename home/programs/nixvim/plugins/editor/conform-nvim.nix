{ pkgs, ... }:
let
  src = pkgs.fetchFromGitHub {
    owner = "ethanuppal";
    repo = "spadefmt";
    rev = "2238c2562517f92ffee59668d212529f1b798f9b";
    hash = "sha256-s0AwhkwB2d2gGCOfC7LXrRFtxP6ivWT3bZ6tTg3SF9s=";
  };

  spadefmt = pkgs.rustPlatform.buildRustPackage {
    pname = "spadefmt";
    version = "0-unstable-2026-08-16";
    inherit src;

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
      outputHashes = {
        "spade-ast-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-ast-lowering-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-common-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-diagnostics-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-hir-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-hir-lowering-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-lang-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-macros-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-mir-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-parser-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-typeinference-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
        "spade-types-0.14.0" = "sha256-qw8bOPKc5TBLxl2mkf4MqUIpa/sO1nnaZ+TPCBAo8rM=";
      };
    };

    meta = {
      description = "Opinionated formatter for the Spade HDL";
      homepage = "https://github.com/ethanuppal/spadefmt";
      license = pkgs.lib.licenses.gpl3Only;
      mainProgram = "spadefmt";
    };
  };
in
{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;

    settings = {
      format_on_save = {
        lsp_format = "fallback";
        timeout_ms = 500;
      };

      formatters_by_ft = {
        nix = [ "nixfmt" ];
        lua = [ "stylua" ];
        python = [ "ruff_format" ];
        rust = [ "rustfmt" ];
        spade = [ "spadefmt" ];
        sh = [ "shfmt" ];
        systemverilog = [ "verible" ];
        verilog = [ "verible" ];
        markdown = [
          "prettierd"
          "prettier"
        ];
        "_" = [ "trim_whitespace" ];
      };

      formatters = {
        treefmt = {
          require_cwd = false;
        };
        spadefmt = {
          command = "${spadefmt}/bin/spadefmt";
          args = [ "$FILENAME" ];
          stdin = false;
          cwd = ''require("conform.util").root_file({ "spadefmt.toml" }) '';
          require_cwd = true;
        };
      };
    };

    autoInstall = {
      enable = true;
      overrides = {
        "treefmt" = null;
        "spadefmt" = spadefmt;
      };
    };
  };
}
