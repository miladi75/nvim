# The Nvim Tutorial — What It Is and How to Use It

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
  and rerunning `:Tutorial` resets the chapter to factory state.

A markdown file can show you `d3w`. Only this can tell you whether your
`d3w` actually worked. That is the entire point: vim skill lives in
muscle memory, and muscle memory only forms by doing.

## 60-second test drive

1. Open Neovim, type `:Tutorial 01-basics`
2. Scroll to **EXERCISE 1**. You'll see this line, with `✗` in the
   left margin:

   ```
   2 + 2 =
   ```

3. Put the cursor on that line. Press `A` (append at end of line),
   then type a **space** followed by **4**, press `Esc`. The line must
   read exactly `2 + 2 = 4`.
4. The `✗` flips to `✓` the moment the line matches. That's the loop.
   Clear all the `✗` marks in a chapter and you've earned it.

The checks are character-exact: a missing or extra space keeps the
`✗`. If a sign won't flip, press `u` until the line is back to its
original state and redo it carefully.

## Opening chapters

| You type | You get |
|----------|---------|
| `:Tutorial` | The course overview — start here |
| `:Tutorial 06-macros` | A specific chapter directly |
| `:Tutor tutorial` + `Tab` | Completion list of all chapters |
| `:Tutor` (no argument) | **NOT this course** — Neovim's stock beginner tutorial |

The course (one chapter per sitting, in order):

```
tutorial                  overview, training rules
tutorial-01-basics        modes, movement, edits, search, NvChad keys
tutorial-02-motions       f/t, word vs WORD, counts, %
tutorial-03-operators     ci" da( cit, the dot command
tutorial-04-registers     yank register "0, named regs, "=
tutorial-05-search        * cgn ., :s captures, :global
tutorial-06-macros        record, replay, edit, apply via :g
tutorial-07-navigation    marks, jumplist, buffers, windows
tutorial-08-visualblock   column edits, g Ctrl-a numbering
tutorial-09-ide           LSP, Telescope, gitsigns — your keys
```

Chapter 1 condenses the classic vimtutor plus NvChad basics into one
file — total beginner friendly. Chapters 2-9 build to power-user level.

## The three interactive mechanics inside a chapter

1. **Exercise lines** — shaded lines with `✗`/`✓` signs. Do what the
   surrounding EXERCISE text says, watch the sign.
2. **Links** — anything like `[registers](...)`. Cursor on it, press
   `Enter`. It opens the relevant `:help` page **inside Neovim** in a
   split (nothing goes to a web browser). Close the help window with
   `:q`. Chapter-to-chapter links open the next chapter the same way.
   Bonus: `K` on almost any word in the tutorial opens its help too.
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
