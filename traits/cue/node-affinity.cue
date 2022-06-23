spec: 
    template: 
        spec: {
            affinity: nodeAffinity: {
              if parameter["requiredLabel"] != _|_ {
                requiredDuringSchedulingIgnoredDuringExecution: nodeSelectorTerms: [{
                    matchExpressions: [
                        for v in parameter.requiredLabel {
                          {
                            key:      v.key
                            operator: "In"
                            values:   v.values
                          }
                        },
                    ]}]              
              }

              if parameter["preferredLabel"] != _|_ {
                preferredDuringSchedulingIgnoredDuringExecution: [
                  for v in parameter.preferredLabel {
                    {
                      weight: v.weight
                      preference: matchExpressions: [{
                        key:      v.key
                        operator: "In"
                        values:   v.values
                      }]
                    }
                  }
                ]
              }
            }
        }

parameter: {
    requiredLabel?:[...{
        key: string
        values: [...string]
    }]
    preferredLabel?:[...{
        key: string
        values: [...string]
        weight: *1 | int
    }]
}

parameter: {
    requiredLabel: [{
        key: "dev-groups"
        values: ["rcmd"]
    }
    ]
    preferredLabel: [{
        key: "dev-groups-external"
        values: ["media"]
    }
    ]
}