# -*- coding:utf-8 -*-
'''
Author: shikanon
 
File: genConfigMap.py
Description: 
Created Date: Thursday, June 17th 2021, 9:09:29 pm
'''
import os
import click
import json
from jinja2 import Template


@click.command()
@click.option('--tpl', help='the path of template file.')
@click.option('--kv', help='the template file key-values.')
@click.option('--output', help='the output dockerfile.')
def genDockerfile(tpl, kv, output):
    assert os.path.exists(tpl)
    with open(tpl, "r",encoding="utf-8") as fr:
        tpl_content = fr.read()
    kv = json.loads(kv)
    tpl_obj = Template(tpl_content)
    result = tpl_obj.render(**kv)
    with open(output, "w", encoding="utf-8") as fw:
        fw.write(result)
        


if __name__ == '__main__':
    genDockerfile()