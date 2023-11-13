{lib, self, inputs, ...}: {
  options.vix = {
    inputs = lib.mkOption {
      description = "Name overridable inputs";
      default = inputs;
    };

    self = lib.mkOption {
      description = "User flake self-reference";
      default = self;
    };
  };
}