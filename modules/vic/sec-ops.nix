{ vic, ... }:
{
  vic.everywhere.includes = [ vic.sec-ops ];
  vic.sec-ops.hm =
    { self', ... }:
    {
      home.packages = [
        self'.packages.vic-sops-get
        self'.packages.vic-sops-rotate
      ];
    };
}
