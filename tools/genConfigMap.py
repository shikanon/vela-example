# -*- coding:utf-8 -*-
'''
Author: shikanon
 
File: genConfigMap.py
Description: 
Created Date: Thursday, June 17th 2021, 9:09:29 pm
'''
import os
from jinja2 import Template

# 不要随便改这个格式，特别是空格和缩进
config_tmp = Template("""apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ name }}
data:
  {% for datafile in datafiles %}
    {{ datafile.name -}}:
{{ datafile.content }}
  {% endfor %}
""")


import click

@click.command()
@click.option('--path', help='Config in the path')
@click.option('--name', help='The name of configmap.')
@click.option('--output', help='the output of configmap generated.')
def genConfimap(name, path, output):
    for root,dir,filenames in os.walk(path):
        datafiles = list()
        for f in filenames:
            with open(os.path.join(root, f),"r",encoding="utf-8") as fr: 
                data = "".join(map(lambda x: " "*8+x+"\n", fr.read().split("\n")))
                datafiles.append({"name": f, "content": data})
        content = config_tmp.render(datafiles=datafiles)
        print(data)
        targetfile = os.path.join(output, name)
        with open(targetfile, "w", encoding="utf-8") as fw:
          fw.write(content)


if __name__ == '__main__':
    genConfimap()