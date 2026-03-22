{ vic, den, ... }:
{
  vic.everywhere.includes = [ vic.ai ];

  vic.ai.includes = [
    (den.provides.unfree [ "copilot-language-server" ])
  ];

  vic.ai.hmLinux =
    { pkgs, ... }:
    {
      home.packages = [
        pkgs.copilot-language-server
        pkgs.aider-chat
        pkgs.gemini-cli-bin
      ];
    };
}
