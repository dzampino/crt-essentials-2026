"""Add the GitHub address, as a link, after the footer text in every part of the WICRT template."""
import re
import sys
import zipfile

src, dst = sys.argv[1], sys.argv[2]
URL = 'https://github.com/dzampino/crt-essentials-2026'
TEXT = 'github.com/dzampino/crt-essentials-2026'
RID = 'rIdGitHubFooter'
# Office 2019+ extension: the link takes the footer's text color instead of the theme's hyperlink blue
FOLLOW_TEXT_COLOR = ('<a:extLst><a:ext uri="{A12FA001-AC4F-418D-AE19-62706E023703}">'
                     '<ahyp:hlinkClr xmlns:ahyp="http://schemas.microsoft.com/office/drawing/2018/hyperlinkcolor" val="tx"/>'
                     '</a:ext></a:extLst>')
RUN = re.compile(r'(<a:r><a:rPr lang="en-US" ?/><a:t>CRT Annual Training Conference 2026</a:t></a:r>)')
LINK_RUNS = (r'\1<a:r><a:rPr lang="en-US"/><a:t>  ·  </a:t></a:r>'
             f'<a:r><a:rPr lang="en-US"><a:hlinkClick r:id="{RID}">{FOLLOW_TEXT_COLOR}</a:hlinkClick></a:rPr><a:t>{TEXT}</a:t></a:r>')
REL = f'<Relationship Id="{RID}" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/hyperlink" Target="{URL}" TargetMode="External"/>'

zin = zipfile.ZipFile(src)
changed = set()
parts = {}
for info in zin.infolist():
    data = zin.read(info.filename)
    if info.filename.endswith('.xml'):
        text = data.decode('utf-8')
        new, n = RUN.subn(LINK_RUNS, text)
        if n:
            assert n == 1, info.filename
            changed.add(info.filename)
            data = new.encode('utf-8')
    parts[info.filename] = (info, data)

for name in changed:
    folder, file = name.rsplit('/', 1)
    rels = f'{folder}/_rels/{file}.rels'
    info, data = parts[rels]
    text = data.decode('utf-8')
    assert RID not in text
    parts[rels] = (info, text.replace('</Relationships>', REL + '</Relationships>').encode('utf-8'))

with zipfile.ZipFile(dst, 'w', zipfile.ZIP_DEFLATED) as zout:
    for name, (info, data) in parts.items():
        zout.writestr(info, data)
print(len(changed), 'parts changed')
