"""Make the dark-mode version of each diagram: NAME.svg -> NAME-dark.svg.

The colors match the site's dark theme (site/dark.scss, site/styles.css).
Render each SVG to a 1600 x 900 PNG the same way as the light ones, for example:
  msedge --headless=new --window-size=1600,900 --screenshot=NAME-dark.png NAME-dark.svg
"""
import pathlib
import re

HERE = pathlib.Path(__file__).parent

# Order matters: the specific patterns run before the general color swaps.
STEPS = [
    # The page background
    (r'<rect width="1600" height="900" fill="#ffffff"/>', '<rect width="1600" height="900" fill="#1B1F26"/>'),
    # Solid navy boxes become a lighter navy, so they stand out from the dark page; their white text stays
    (r'(<rect [^>]*?)fill="#0C2454"', r'\1fill="#2D4A85"'),
    # Outlined boxes are filled with the site's dark surface color
    (r'fill="#ffffff" stroke=', 'fill="#1F2329" stroke='),
    # Navy outlines and text, then the other colors
    (r'#0C2454', '#A9C1EC'),
    (r'#1A1D23', '#E3E7ED'),
    (r'#5A6472', '#A5AEBB'),
    (r'#D9383A', '#F2807D'),
    (r'#EEF1F5', '#2A303A'),
]

for source in sorted(HERE.glob('*.svg')):
    if source.stem.endswith('-dark'):
        continue
    svg = source.read_text(encoding='utf-8')
    for pattern, replacement in STEPS:
        svg = re.sub(pattern, replacement, svg)
    target = source.with_name(source.stem + '-dark.svg')
    target.write_text(svg, encoding='utf-8', newline='\n')
    print(target.name)
