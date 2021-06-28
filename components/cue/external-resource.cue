output: {
    apiVersion: "v1"
    kind:       "Service"
    metadata: {
        name: context.name
    }
    spec: {
        if parameter.dnstype == "A" {
            type: "ClusterIP"
            ports: [ for p in parameter.ports {
                port: p
                targetPort: p
                protocol: parameter.protocol
            }]
        }
        if parameter.dnstype == "CNAME" {
            type: "ExternalName"
            externalName: parameter.cname
        }
    }
}

outputs: {
    if parameter.dnstype == "A" {
        endpoints: {
            apiVersion: "v1"
            kind: "Endpoints"
            metadata: {
                name: context.name
            }
            subsets: [
                {
                    addresses: [ for i in parameter.ips {
                        ip: i
                    }]
                    ports: [ for p in parameter.ports {
                        port: p
                        protocol: parameter.protocol
                    }]
                }
            ]
        }
    }
}

parameter: {
    // +usage=DNS resolution type, only support "A" and "CNAME"
    dnstype: "A" | "CNAME"
    if dnstype == "A" {
        ips: [...string]
        ports: [...int]
        protocol: *"TCP" | "UDP"
    }
    if dnstype == "CNAME" {
        // +usage=cname value, like xxx.com
        cname: string
    }
}

parameter: {
    dnstype: "A"
    ips: ["10.213.60.50"]
    ports: [6379]
}

context: {
    name: "test-dns-a-resolution"
}