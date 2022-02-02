package examples

listObject: {
	apiVersion: "v1"
	kind:       "List"
	items:      objects
}

objects: [ for objectSet in [pods, services] for object in objectSet {object}]

_Object: {
	_name: string

	apiVersion: "v1"
	kind:       string
	metadata: {
		name: _name
		labels: {
			"app.kubernetes.io/name": _name
		}
	}
}

pods: [Name=_]: _Object & {
	_name: Name
	kind:  "Pod"
}

pods: {
	"spanner-emulator": Self={
		spec: {
			containers: [{
				name: Self._name
				image: "gcr.io/cloud-spanner-emulator/emulator"
			}]
		}
	}
}

services: [Name=_]: _Object & {
	_name: Name
	kind: "Service"
}

services: {
	"spanner-emulator": Self={
		spec: {
			selector: "app.kubernetes.io/name": Self._name
			ports: [{
				name: "grpc"
				protocol: "TCP"
				port: 9010
				targetPort: port
			}]
		}
	}
}
