{ vic, ... }:
{
  vic.everywhere.includes = [ vic.ai ];
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
