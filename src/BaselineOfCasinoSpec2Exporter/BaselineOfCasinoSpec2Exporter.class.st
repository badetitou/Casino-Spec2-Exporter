Class {
	#name : #BaselineOfCasinoSpec2Exporter,
	#superclass : #BaselineOf,
	#category : #BaselineOfCasinoSpec2Exporter
}

{ #category : #baselines }
BaselineOfCasinoSpec2Exporter >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ 
			self defineDependencies: spec.
			self definePackages: spec.
			self defineGroups: spec ]
]

{ #category : #baselines }
BaselineOfCasinoSpec2Exporter >> defineDependencies: spec [
	spec
		baseline: 'Casino'
		with: [ spec
				loads: 'core-extented';
				repository: 'github://badetitou/Casino:master/src' ]
]

{ #category : #baselines }
BaselineOfCasinoSpec2Exporter >> defineGroups: spec [
]

{ #category : #baselines }
BaselineOfCasinoSpec2Exporter >> definePackages: spec [
	spec
		package: 'Casino-Spec2-Exporter'
			with: [ spec requires: #('Casino') ]
]
