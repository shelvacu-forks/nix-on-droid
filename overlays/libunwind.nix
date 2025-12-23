new: old:
let
  overrideLib =
    oldLibunwind:
    oldLibunwind.overrideAttrs (oldAttrs: {
      env = (oldAttrs.env or {}) // {
        LDFLAGS = if (oldAttrs.env.LDFLAGS or "") != "" then
          "${oldAttrs.env.LDFLAGS} -unwindlib=none"
        else
          "-unwindlib=none";
      };
    });
  overridePkgSet =
    pkgSet:
    pkgSet // {
      libunwind = overrideLib pkgSet.libunwind;
    };
in
{
  llvmPackages_20 = overridePkgSet old.llvmPackages_20;
  llvmPackages_19 = overridePkgSet old.llvmPackages_20;
  llvmPackages_18 = overridePkgSet old.llvmPackages_20;
  llvmPackages = overridePkgSet old.llvmPackages_20;
}
