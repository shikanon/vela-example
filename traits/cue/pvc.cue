outputs: pvc: {
	apiVersion: "v1"
	kind:       "PersistentVolumeClaim"
	metadata: {
		name:      parameter.name
		namespace: context.namespace
		annotations: {
			if parameter.pvc == "ssd" {
				"everest.io/disk-volume-type": "SSD"
			}
			if parameter.pvc == "sas" {
				"everest.io/disk-volume-type": "SAS"
			}
			if parameter.pvc == "obs" {
				"everest.io/obs-volume-type": "STANDARD"
				"csi.storage.k8s.io/fstype":  "obsfs"
			}
		}
		if parameter.pvc == "ssd" || parameter.pvc == "sas" {
			labels: {
				"failure-domain.beta.kubernetes.io/region": parameter.region
				"failure-domain.beta.kubernetes.io/zone":   "\(parameter.region)\(parameter.zone)"
			}
		}

	}
	spec: {
		if parameter.pvc == "ssd" || parameter.pvc == "sas" {
			accessModes: ["ReadWriteOnce"]
		}
		if parameter.pvc == "nas" || parameter.pvc == "obs" {
			accessModes: ["ReadWriteMany"]
		}
		if parameter.pvc == "ssd" || parameter.pvc == "sas" {
			storageClassName: "csi-disk"
		}
		if parameter.pvc == "nas" {
			storageClassName: "csi-nas"
		}
		if parameter.pvc == "obs" {
			storageClassName: "csi-obs"
		}
		resources:
			requests:
				storage: "\(parameter.size)Gi"
	}
}

parameter: {
	// +usage=the name created pvc 
	name: string
	// +usage=the type of pvc in huawei cloud, only "nas", "obs", "ssd", "sas"
	pvc: *"obs" | "nas" | "ssd" | "sas"
	// +usage=the storage size, unit is Gi, size=10 mean size is 10Gi
	size: *5 | int
	// +usage=regine and zone when the disk created which must mount the node, like "ssd" and "sas"
	region?: string
	zone?:   string
}

parameter: {
	name:   "testpvc"
	pvc:    "ssd"
	size:   10
	region: "cn-north-4"
	zone:   "a"
}

context: {
	name:      "test-application"
	namespace: "test-ns"
}
