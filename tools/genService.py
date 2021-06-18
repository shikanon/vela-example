# -*- coding:utf-8 -*-
'''
Author: shikanon
 
File: generator.py
Description: 
Created Date: Friday, May 28th 2021, 8:51:22 pm
'''

import yaml
import os
from jinja2 import Template


svc_temp = Template('''apiVersion: v1
kind: Service
metadata:
  name: {{ name }}
  namespace: databases
spec:
  ports:
  {% for port in ports -%}
  - port: {{ port }}
    protocol: TCP
    targetPort: {{ port }}
  {% endfor -%}
  type: ClusterIP
''')

ep_temp = Template('''apiVersion: v1
kind: Endpoints
metadata:
  name: {{ name }}
  namespace: databases
subsets:
- addresses:
  {% for ip in IPs -%}
  - ip: {{ ip }}
  {% endfor -%}
  ports:
  {% for port in ports -%}
  - port: {{ port }}
    protocol: TCP
  {% endfor -%}
''')

cname_temp = Template('''apiVersion: v1
kind: Service
metadata:
  name: {{ name }}
  namespace: databases
spec:
  externalName: {{ externalName }}
  ports:
  {% for port in ports -%}
  - port: {{ port }}
    protocol: TCP
    targetPort: {{ port }}
  {% endfor -%}
  type: ExternalName
''')


output_path = "output/"


def exist_or_create(path):
    if not os.path.exists(path):
        os.mkdir(path)


def savefile(filename, content):
    with open(filename+".yaml", "w") as fw:
        fw.write(content)


def genService(servicefile):
    exist_or_create(output_path)
    with open(servicefile, "r") as fr:
        content = yaml.load(fr.read())
        # 生成 external svc ep
        for svc_addr in content["Address"]:
            svc_name = svc_addr["name"]
            svc_ips = svc_addr["ip"].split(",")
            svc_ports = str(svc_addr["ports"]).split(",")
            savefile(output_path+"svc_"+svc_name, svc_temp.render(name=svc_name, ports=svc_ports))
            savefile(output_path+"ep_"+svc_name, ep_temp.render(name=svc_name, IPs=svc_ips, ports=svc_ports))
        # 生成 external name svc
        for svc in content["CName"]:
            svc_name = svc["name"]
            svc_external =svc["external-name"]
            svc_ports = str(svc["ports"]).split(",")
            savefile(output_path+"svc_"+svc_name, cname_temp.render(name=svc_name, externalName=svc_external, ports=svc_ports))
        print(content["CName"])
        print(content["Address"])

if __name__ == "__main__":
    genService("external-service.yaml")