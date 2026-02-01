{pkgs, ...}: {
  stylix = {
    enable = true;

    base16Scheme = "${pkgs.base16-schemes}/share/themes/eighties.yaml";
    polarity = "dark";

    fonts = with pkgs; {
      serif.package = alegreya;
      serif.name = "Alegreya";

      sansSerif.package = fira-sans;
      sansSerif.name = "Fira Sans";

      monospace.package = nerd-fonts.iosevka;
      monospace.name = "Iosevka";
    };
  };
}
