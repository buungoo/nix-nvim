# Override neovim-unwrapped to show startup time in the intro screen
pkgs:
pkgs.neovim-unwrapped.overrideAttrs (old: {
  doCheck = false;
  postPatch =
    (old.postPatch or "")
    + ''
        # Add startup time rendering using clock() directly in version.c
        sed -i '/#include "nvim\/version.h"/a #include <time.h>' src/nvim/version.c

        # Replace Uganda lines with startup time line
        sed -i 's|N_("Help poor children in Uganda!"),||' src/nvim/version.c
        sed -i 's|N_("type  :help Kuwasha<Enter>  for information "),|"⚡ startup %.1fms",|' src/nvim/version.c

        # Add startup time formatting as a separate block before do_intro_line
        sed -i '/do_intro_line(row, mesg/i\
      if (strstr(lines[i], "startup") != NULL) {\
        static double ms = 0;\
        if (ms == 0) ms = (double)clock() / (CLOCKS_PER_SEC / 1000);\
        mesg_size = snprintf(NULL, 0, lines[i], ms);\
        assert(mesg_size > 0);\
        mesg = xmallocz((size_t)mesg_size);\
        snprintf(mesg, (size_t)mesg_size + 1, lines[i], ms);\
      }' src/nvim/version.c
    '';
})
