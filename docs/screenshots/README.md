# Screenshots

Drop UI captures for CloudChart here. These are referenced from the top-level
`README.md` and should stay in sync with the current layout of each sub app.

## Naming convention

Use `<sub_app>__<module_id>.png`, lower-case, underscores only. Examples:

- `hub__landing.png`
- `core_plots__dot_plot.png`
- `advanced_plots__umap.png`
- `statistics__stats_posthoc.png`
- `statistics__stats_logreg.png`
- `statistics__stats_survival.png`
- `statistics__stats_effect_size.png`
- `data_tools__data_pivot.png`

## Capture checklist

For every module screenshot:

1. Load the built-in example data via the **Example Data** tab
2. Jump to **Data & Parameters**, pick sensible columns
3. Click **Run Analysis** (statistics) or **Build Plot** (plots)
4. Capture the **Results** tab at 1440 × 900 with the browser chrome cropped out
5. Save as PNG (lossless) and keep file size under ~400 KB when possible

## Referencing from README

```md
![Post-hoc Tests](docs/screenshots/statistics__stats_posthoc.png)
```

Keep captions short and describe what the user is looking at, not how it was
generated.
