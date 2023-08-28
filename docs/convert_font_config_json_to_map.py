#!/bin/python3
# This code convert the font config.json file to a Map<String,int> table
# This config.json is generated by https://fontello.com/, online font
# generator.

import json


def generate_dart_map(config_file):
    with open(config_file, 'r') as f:
        data = json.load(f)

    dart_map = {}
    for glyph in data['glyphs']:
        css = glyph['css']
        code = glyph['code']
        dart_map[css] = code

    return dart_map


if __name__ == "__main__":
    config_file = "config.json"
    dart_map = generate_dart_map(config_file)

    print("Map<String, int> dartMap = {")
    for css, code in dart_map.items():
        print(f'  "{css}": {code},')
    print("};")
