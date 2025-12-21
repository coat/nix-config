{lib, ...}: {
  plugins.obsidian = {
    enable = true;

    settings = {
      legacy_commands = false;

      new_notes_location = "notes";
    };
  };

  keymaps = [
    {
      mode = "n";
      key = "<leader>od";
      action = "<cmd>Obsidian dailies<cr>";
      options.desc = "Daily notes";
    }
    {
      mode = "n";
      key = "<leader>on";
      action = "<cmd>Obsidian new<cr>";
      options.desc = "New note";
    }
    {
      mode = "n";
      key = "<leader>oo";
      action = "<cmd>Obsidian open<cr>";
      options.desc = "Open in Obsidian app";
    }
    {
      mode = "n";
      key = "<leader>os";
      action = "<cmd>Obsidian search<cr>";
      options.desc = "Search notes";
    }
    {
      mode = "n";
      key = "<leader>oq";
      action = "<cmd>Obsidian quick_switch<cr>";
      options.desc = "Quick switch";
    }
    {
      mode = "n";
      key = "<leader>ot";
      action = "<cmd>Obsidian today<cr>";
      options.desc = "Today's note";
    }
    {
      mode = "n";
      key = "<leader>oy";
      action = "<cmd>Obsidian yesterday<cr>";
      options.desc = "Yesterday's note";
    }
    {
      mode = "n";
      key = "<leader>oT";
      action = "<cmd>Obsidian tomorrow<cr>";
      options.desc = "Tomorrow's note";
    }
    {
      mode = "n";
      key = "<leader>og";
      action = "<cmd>Obsidian tags<cr>";
      options.desc = "Tags";
    }
    {
      mode = "x";
      key = "<leader>oe";
      action = "<cmd>Obsidian extract_note<cr>";
      options.desc = "Extract to note";
    }
    {
      mode = "x";
      key = "<leader>ol";
      action = "<cmd>Obsidian link<cr>";
      options.desc = "Link selection";
    }
    {
      mode = "x";
      key = "<leader>oL";
      action = "<cmd>Obsidian link_new<cr>";
      options.desc = "Link selection to new note";
    }
  ];

  autoGroups.obsidian_keymaps = {};

  autoCmd = [
    {
      event = ["User"];
      group = "obsidian_keymaps";
      pattern = "ObsidianNoteEnter";
      callback = lib.nixvim.mkRaw ''
        function(ev)
          vim.keymap.set("n", "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", {
            buffer = ev.buf,
            desc = "Toggle checkbox",
          })
          vim.keymap.set("n", "<leader>ob", "<cmd>Obsidian backlinks<cr>", {
            buffer = ev.buf,
            desc = "Backlinks",
          })
          vim.keymap.set("n", "<leader>or", "<cmd>Obsidian rename<cr>", {
            buffer = ev.buf,
            desc = "Rename note",
          })
          vim.keymap.set("n", "<leader>oi", "<cmd>Obsidian template<cr>", {
            buffer = ev.buf,
            desc = "Insert template",
          })
          vim.keymap.set("n", "<leader>op", "<cmd>Obsidian paste_img<cr>", {
            buffer = ev.buf,
            desc = "Paste image",
          })
          vim.keymap.set("n", "<leader>of", "<cmd>Obsidian follow_link<cr>", {
            buffer = ev.buf,
            desc = "Follow link",
          })
          vim.keymap.set("n", "<leader>oK", "<cmd>Obsidian toc<cr>", {
            buffer = ev.buf,
            desc = "Table of contents",
          })
          vim.keymap.set("n", "<leader>ok", "<cmd>Obsidian links<cr>", {
            buffer = ev.buf,
            desc = "Links in note",
          })
        end
      '';
    }
  ];
}
