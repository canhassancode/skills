# OCR on intake

A scanned PDF has no text layer, so it is invisible to `grep`, `/ask`, and your own synthesis. OCR it on the way in, then file the searchable copy as the raw.

## Only OCR what needs it

A PDF that already has a text layer must not be re-rasterised — that degrades it and loses the crisp text. Classify first by text density per page:

```sh
pages=$(pdfinfo "$f" | awk '/^Pages:/{print $2}')
chars=$(pdftotext "$f" - | tr -d '[:space:]' | wc -c)
echo $(( chars / pages ))   # < ~100 chars/page → scanned image → OCR; otherwise keep as-is
```

Title plans, maps, and photos are legitimately text-sparse — OCR adds nothing; keep them.

## OCR a scan

Prefer `ocrmypdf` when present — it adds a text layer in place and skips pages that already have text:

```sh
ocrmypdf --skip-text in.pdf out.pdf
```

If `ocrmypdf` is absent (it needs `qpdf`), use the render → recognise → merge chain from `tesseract` + `poppler` + `ghostscript`:

```sh
pdftoppm -r 300 -png in.pdf "$tmp/pg"          # render each page at 300 dpi
n=0; for img in "$tmp"/pg-*.png; do
  printf -v pad "%03d" "$((++n))"
  tesseract "$img" "$tmp/out-$pad" -l eng pdf  # per-page searchable PDF
done
gs -q -dNOPAUSE -dBATCH -sDEVICE=pdfwrite -sOutputFile=out.pdf "$tmp"/out-*.pdf
```

The output keeps the original page image with a searchable text layer beneath it. Verify: `pdftotext out.pdf - | wc -c` should jump from near-zero to full text.

## After OCR

- Store the searchable PDF under the matter's `raw/`; it is the immutable source of truth.
- OCR text carries artefacts (dotted-leader lines, the odd merged word). It is good for search and synthesis, not for a verbatim legal quote — check the page image before quoting a clause exactly.
