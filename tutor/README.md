# Nvim Power Course — What It Is and How to Use It

## What this actually is (not a document — a gym)

A `.tutor` file is NOT something you read like markdown. It is an
**interactive practice buffer**:

- The exercises are real, editable lines of text sitting inside the
  tutorial. You perform the actual keystrokes on them.
- Neovim **grades you live**. Every exercise line has a hidden expected
  result. While your line is wrong there is a `✗` sign in the left
  margin. The instant your edit produces the exact expected text, it
  flips to `✓`. No reading comprehension — your fingers either did it
  or they didn't.
- Mistakes cost nothing. The buffer **cannot be saved**. `u` undoes,
  and reopening the chapter resets everything to factory state.

A markdown file can show you `d3w`. Only this can tell you whether your
`d3w` actually worked. That is the entire point: vim skill lives in
muscle memory, and muscle memory only forms by doing.

This is the same machinery as Neovim's built-in `vimtutor` (what you
get from bare `:Tutor`) — these 9 chapters are an advanced course built
on top of it, using your config's real keymaps.

## 60-second test drive

1. Open Neovim, type `:PowerTutor 01-motions`
2. Scroll down (`j` or `<C-d>`) to **EXERCISE 3**. You'll see this line,
   with a `✗` in the left margin:

   ```
   signal counter : integer range 0 to 255]
   ```

3. Put the cursor anywhere on that line. Type `$` (jump to end of
   line), then `r;` (replace the character under the cursor with `;`).
4. The `✗` flips to `✓`. That's the loop. Clear all the `✗` marks in a
   chapter and you've earned it.

## Opening chapters

| You type | You get |
|----------|---------|
| `:PowerTutor` | Chapter 0 — the course overview, start here |
| `:PowerTutor 05-macros` | A specific chapter directly |
| `:Tutor power` + `Tab` | Completion list of all 9 chapters |
| `:Tutor` (no argument) | **NOT this course** — Neovim's built-in beginner tutorial (stock behavior) |

The chapters:

```
power-00-overview      how the course works, training rules
power-01-motions       f/t, word vs WORD, counts, %
power-02-operators     ci" da( cit, the dot command
power-03-registers     yank register "0, named regs, "=
power-04-search        * cgn ., :s captures, :global
power-05-macros        record, replay, edit, apply via :g
power-06-navigation    marks, jumplist, buffers, windows
power-07-visualblock   column edits, g Ctrl-a numbering
power-08-ide           LSP, Telescope, gitsigns — your keys
```

## The three interactive mechanics inside a chapter

1. **Exercise lines** — shaded lines with `✗`/`✓` signs. Do what the
   surrounding EXERCISE text says, watch the sign.
2. **Links** — anything like `[registers](...)`. Cursor on it, press
   `Enter`. It opens the relevant `:help` page **inside Neovim** in a
   split (nothing goes to a web browser). Close the help window with
   `:q`. Chapter-to-chapter links open the next chapter the same way.
   Bonus: `K` on almost any word in the tutor opens its help too.
3. **Runnable command lines** — indented lines starting with `:`, like
   `:Telescope keymaps`. Put the cursor on the line and type `>>` to
   execute it without retyping.

## How to train with it

- One chapter per sitting, in order. 10–20 minutes.
- A chapter is *done* when you can clear every `✗` **without reading
  the instructions**. First pass is learning; the repeats are the
  actual training.
- Same day, use one new trick in real code on purpose. That's what
  makes it stick.

## Maintenance (only if you edit the chapter text)

The expected answers live in `*.tutor.json` files keyed by line number.
After editing any `.tutor` file, regenerate them — never edit the json
by hand:

```bash
python3 ~/.config/nvim/tutor/build_expects.py
```
