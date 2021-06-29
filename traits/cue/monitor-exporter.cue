outputs: monitor: {
    apiVersion: "apps/v1"
    kind:       "Deployment"
    metadata: {
        name: "\(context.name)-exporter"
    }
    spec: {
        selector: matchLabels: {
            "app.oam.dev/component": "\(context.name)-exporter"
            "app.kubernetes.io/instance": "\(context.name)-exporter"
            "app.kubernetes.io/name": "\(context.name)-exporter"
        }

        template: {
            metadata: {
                annotations: {
                    if parameter.type == "redis" {
                        "prometheus.io/port": "2112"
                    }
                    if parameter.type == "kafka" {
                        "prometheus.io/port": "9308"
                    }
                    if parameter.type == "mysql" {
                        "prometheus.io/port": "9104"
                    }
                    if parameter.type == "mongo" {
                        "prometheus.io/port": "9216"
                    }
                    "prometheus.io/scrape": "true"
                }
                labels: {
                    "app.oam.dev/component": "\(context.name)-exporter"
                    "app.kubernetes.io/instance": "\(context.name)-exporter"
                    "app.kubernetes.io/name": "\(context.name)-exporter"
                }
            }
            spec: {
                containers: [{
                    name:  "\(context.name)-exporter"
                    if parameter.type == "redis" {
                        image: "oliver006/redis_exporter:v1.24.0"
                        env: [{
                                name: "REDIS_ADDR"
                                value: parameter.redisAddr
                            },
                            {
                                name: "REDIS_USER"
                                value: parameter.redisUser
                            },
                            {
                                name: "REDIS_PASSWORD"
                                value: parameter.redisPasswd
                            },
                        ]
                    }

                    if parameter.type == "kafka" {
                        image: "danielqsj/kafka-exporter:v1.2.0"
                        command: ["/bin/kafka_exporter","--kafka.server=\(parameter.kafkaAddr)"]
                    }

                    if parameter.type == "mysql" {
                        image: "prom/mysqld-exporter:v0.13.0"
                        env: [{
                            name: "DATA_SOURCE_NAME"
                            value: parameter.mysqlAddr
                        }]
                    }

                    if parameter.type == "mongo" {
                        image: "bitnami/mongodb-exporter:0.20.6"
                        command: [
                        "/opt/bitnami/mongodb-exporter/bin/mongodb_exporter",
                        "--mongodb.uri=\(parameter.mongoAddr)",
                        "--log.level=info"
                        ]
                    }

                    resources: {
                        requests: {
                            cpu: "50m"
                            memory: "50Mi"
                        },
                        limits: {
                            cpu: "200m"
                            memory: "100Mi"
                        }
                    }
                }]
            }
        }
    }
}

parameter: {
    // +usage=Which exporter to use, like "redis", "kafka", "mysql", "mongo"
    type: "redis" | "kafka" | "mysql" | "mongo"
    if type == "redis" {
        // +usage=Which address of redis, like "redis://localhost:6379" 
        redisAddr: "redis://localhost:6379" | string
        // +usage=Which username of redis
        redisUser: *"" | string
        redisPasswd: *"" | string
    }
    if type == "kafka" {
        // +usage=Which address of kafka, like "kafka-zt-persona.databases.svc:9092"
        kafkaAddr: string
    }
    if type == "mysql" {
        // +usage=Which address of mysql, like "username:password@(hostname:port)/"
        mysqlAddr: string
    }
    if type == "mongo" {
        // +usage=Which address of mongo, like "mongodb://user:pass@127.0.0.1:27017/admin?ssl=true"
        mongoAddr: string
    }
}


// mock: mock context
context: {
    name: "kafka-zt-persona"
}


// mock: mock parameter
parameter: {
    type: "kafka"
    kafkaAddr: "kafka-zt-persona.databases.svc:9092"
}