Class {
	#name : #CSNSpec2Exporter,
	#superclass : #CSNModelExporter,
	#instVars : [
		'initializeWidgetsExporter'
	],
	#category : #'Casino-Spec2-Exporter'
}

{ #category : #api }
CSNSpec2Exporter >> computeAcceptedNameForClassFrom: aString [
	^ (aString capitalized copyReplaceAll: ' ' with: '') copyReplaceAll: '-' with: '_' 
]

{ #category : #api }
CSNSpec2Exporter >> computeAcceptedNameForVariableFrom: aString [
	^ (aString uncapitalized copyReplaceAll: '(' with: '') copyReplaceAll: ')' with: ''
]

{ #category : #api }
CSNSpec2Exporter >> createAccessorForVariable: each inClass: class [
	"generate the getter and the setter"

	"getter"

	class compile: '' , each , String crlf , String tab , '^ ' , each.
	"setter"
	class compile: '' , each, ': anObject' , String crlf , String tab , each, ' := anObject'.
]

{ #category : #api }
CSNSpec2Exporter >> exportedPackageName [
	^ 'Casino-Exported'
]

{ #category : #api }
CSNSpec2Exporter >> prefix [
	^ 'CSNExported'
]

{ #category : #api }
CSNSpec2Exporter >> prepareExport [
	initializeWidgetsExporter := CSNSpec2InitializeWidgetsExporter new mainExporter: self; yourself
]

{ #category : #api }
CSNSpec2Exporter >> protectString: aString [
	^ aString copyReplaceAll: '''' with: ''''''
]

{ #category : #api }
CSNSpec2Exporter >> recursiveLocalWidgetNameOfPage: aBLPage [
	^ (self recursiveLocalWidgetOfPage: aBLPage) reject: #isNil thenCollect: [:widget | self computeAcceptedNameForVariableFrom: widget name ]
]

{ #category : #api }
CSNSpec2Exporter >> recursiveLocalWidgetOfPage: aBLPage [
	^ aBLPage localWidgets flattened reject: [:widget | widget isKindOf: CSNUIPanel ]
]

{ #category : #api }
CSNSpec2Exporter >> visitCell: aBLCell [
 	^ aBLCell widget ifNil: [ '' ] ifNotNil: [ ' add: ', (self visit: aBLCell widget) ] 
]

{ #category : #api }
CSNSpec2Exporter >> visitInsideAContainerWithLocalVariable: localVariableName andContainedWidgets: containedWidgets [
	localVariableName.
	^ 'newColumn: [ :' , localVariableName
		,
			' |
		'
		,
			(containedWidgets
				flatCollect: [ :widget |
					localVariableName , ' ' , ('' , (self visit: widget) removeSuffix: ';')
						,
							'.
			' indentBy: 4 ])
		,
			'
		]
	'
]

{ #category : #api }
CSNSpec2Exporter >> visitLayout: aBLLayout [

	^ self visitUIVerticalLayout: aBLLayout
]

{ #category : #api }
CSNSpec2Exporter >> visitMooseModel: aMooseModel [
	aMooseModel allCSNPage do: [ :phase | self visit: phase ]
]

{ #category : #api }
CSNSpec2Exporter >> visitPage: aBLPage [
	| class |
	class := ComposablePresenter
		subclass: self prefix , (self computeAcceptedNameForClassFrom: aBLPage name)
		instanceVariableNames: '' , ((self recursiveLocalWidgetNameOfPage: aBLPage) flatCollect: [ :name | name uncapitalized , ' ' ])
		classVariableNames: ''
		package: self exportedPackageName , '-Page'.
	class class
		compile:
			'open
	<example>
	^ self new openWithSpec'.
	class class
		compile:
			'defaultSpec
	<spec: #default>
	^ ' ,
				({aBLPage widgets . aBLPage businessPage} flatten flatCollect: [ :widget | ('' , (self visit: widget) removeSuffix: ';') "ifEmpty: [ '' ] ifNotEmpty: [ :result | result]" ]).
	class compile: 'title' , String crlf , String tab , '^ ' , ('''' , (self protectString: (aBLPage title ifNil: [ '' ])) , '''').
	class instanceVariables do: [ :each | self createAccessorForVariable: each inClass: class ].
	initializeWidgetsExporter exportInitializeWidgetOfPage: aBLPage inClass: class.
	^ self visitWidget: aBLPage
]

{ #category : #api }
CSNSpec2Exporter >> visitUIContainer: aBLUIContainer [
	^ (aBLUIContainer layout
		ifNotNil: [ self visit: aBLUIContainer layout ]
		ifNil: [ self visitInsideAContainerWithLocalVariable: ('row', (self computeAcceptedNameForVariableFrom: aBLUIContainer mooseName , aBLUIContainer mooseID asString) ) andContainedWidgets: aBLUIContainer widgets "aBLUIContainer widgets flatCollect: [ :widget | '' , (self visit: widget) , ';' ]" ])
		,
			(aBLUIContainer attributes
				ifEmpty: [ '' ]
				ifNotEmpty: [ :attributes | 
					(attributes flatCollect: [ :attribute | self visit: attribute ])
						ifNotEmpty: [ :od | 
							od
								removeLast;
								yourself ] ])
]

{ #category : #api }
CSNSpec2Exporter >> visitUIHorizontalLayout: aBLUIHorizontalLayout [
	^ '(SpecBoxLayout newHorizontal'
		,
			((aBLUIHorizontalLayout cell
				flatCollect: [ :cell | 
					' ' , ('' , (self visit: cell) removeSuffix: ';')
						,
							';' indentBy: 4 ]) removeLast; yourself), ')'
]

{ #category : #api }
CSNSpec2Exporter >> visitUIVerticalLayout: aBLUIVerticalLayout [
	^ '(SpecBoxLayout newVertical'
		,
			((aBLUIVerticalLayout cell
				flatCollect: [ :cell | 
					' ' , ('' , (self visit: cell) removeSuffix: ';')
						,
							';' indentBy: 4 ]) removeLast; yourself), ')'
]

{ #category : #api }
CSNSpec2Exporter >> visitWidget: aBLWidget [
	^ '#' , (self computeAcceptedNameForVariableFrom: aBLWidget name uncapitalized) , ' ' , (aBLWidget attributes flatCollect: [ :attribute | self visit: attribute ])
]
