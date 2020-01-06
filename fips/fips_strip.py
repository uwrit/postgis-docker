import os
import re

REGEX_ABBR = r'<td>([A-Z]{2})</td><td>([0-9]{2})</td>'

def main():
    with open(f'{os.getcwd()}{os.path.sep}fips.html') as f:
        content = f.read().replace('\n','').replace(' ','')
        pairs = re.findall(REGEX_ABBR, content)

    with open(f'{os.getcwd()}{os.path.sep}fips.txt', 'w') as f:
        for pair in pairs:
            f.write(f'"{pair[0]}")  fips={pair[1]};;\n')
main()