// Markdown -> HTML, one shot, no server. Called by preview.sh.
// Versions are pinned to the URLs peek.nvim (since removed) used, so the deps
// are already in deno's cache and this keeps working offline.
import MarkdownIt from 'https://esm.sh/markdown-it@14.0.0';
import { default as MarkdownItTexmath } from 'https://esm.sh/markdown-it-texmath@1.0.0';
import Katex from 'https://esm.sh/katex@0.16.9';

const md = new MarkdownIt('default', {
  html: true,
  linkify: true,
  typographer: true,
}).use(MarkdownItTexmath, {
  engine: Katex,
  delimiters: ['gitlab', 'dollars'],
  katexOptions: { strict: false, throwOnError: false },
});

console.log(md.render(await Deno.readTextFile(Deno.args[0])));
