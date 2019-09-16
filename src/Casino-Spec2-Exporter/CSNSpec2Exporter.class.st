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
CSNSpec2Exporter >> recursiveLocalWidgetNameOfBLBusinessPage: aBLBuisinessPage [
	^ (self recursiveLocalWidgetOfBLBusinessPage: aBLBuisinessPage) collect: [ :widget | self computeAcceptedNameForVariableFrom: widget name ]
]

{ #category : #api }
CSNSpec2Exporter >> recursiveLocalWidgetNameOfPage: aBLPage [
	^ (self recursiveLocalWidgetOfPage: aBLPage) reject: #isNil thenCollect: [:widget | self computeAcceptedNameForVariableFrom: widget name ]
]

{ #category : #api }
CSNSpec2Exporter >> recursiveLocalWidgetOfBLBusinessPage: aBLBusinessPage [
	^ (aBLBusinessPage widgets collect: [ :widget | widget allToScope: CSNWidget until: [ :widgetInBusiness | widgetInBusiness isKindOf: CSNBusinessPage ] ]) flattened
		reject: [ :widget | widget isKindOf: CSNUIPanel ]
]

{ #category : #api }
CSNSpec2Exporter >> recursiveLocalWidgetOfPage: aBLPage [
	^ (aBLPage allToScope: CSNWidget until: [:widget | widget isKindOf: CSNBusinessPage] ) flattened reject: [:widget | widget = aBLPage or: [ widget isKindOf: CSNUIPanel ] ]
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNAttribute: aBLAttribute [
	^ ''
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNBusinessPage: aBLBusinessPage [
	| class |
	class := SpPresenter
		subclass: self prefix , (aBLBusinessPage name capitalized , aBLBusinessPage mooseID asString)
		instanceVariableNames:
			''
				,
					((self recursiveLocalWidgetNameOfBLBusinessPage: aBLBusinessPage)
						flatCollect: [ :name | name uncapitalized , ' ' ])
		classVariableNames: ''
		package: self exportedPackageName , '-Components'.
	class class
		compile:
			'open
	<example>
	^ self new openWithSpec'.
	class class
		compile:
			'defaultSpec
	<spec: #default>
	^ ', 	(aBLBusinessPage widgets
						flatCollect: [ :widget | 
							('' , (self visit: widget) removeSuffix: ';')]).
	class instanceVariables
		do: [ :each | self createAccessorForVariable: each inClass: class ].
	class
		compile:
			'title' , String crlf , String tab , '^ '
				, ('''' , (self protectString: (aBLBusinessPage title ifNil: [ '' ])) , '''').
	initializeWidgetsExporter
		exportInitializeWidgetOfBusinessPage: aBLBusinessPage
		inClass: class.
	^ self visitCSNWidget: aBLBusinessPage
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNContainer: aBLUIContainer [
	^ (aBLUIContainer layout
		ifNotNil: [ self visit: aBLUIContainer layout ]
		ifNil: [ 
			self visitCSNWidget: aBLUIContainer
			
			"self visitInsideAContainerWithLocalVariable: ('row', (self computeAcceptedNameForVariableFrom: aBLUIContainer mooseName , aBLUIContainer mooseID asString) ) andContainedWidgets: aBLUIContainer widgets" "aBLUIContainer widgets flatCollect: [ :widget | '' , (self visit: widget) , ';' ]" ])
		,
			(aBLUIContainer attributes
				ifEmpty: [ '' ]
				ifNotEmpty: [ :attributes |
						| localConstraintVariable |
						localConstraintVariable := 'constraint', aBLUIContainer mooseID asString.
					' withConstraints: [ :', localConstraintVariable , ' | ',  
					(attributes flatCollect: [ :attribute | localConstraintVariable, ' ' ,  (self visit: attribute), '.' ]), ' ] ' ])
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNLCell: aBLCell [
 	^ aBLCell widget ifNil: [ '' ] ifNotNil: [ ' add: ', (self visit: aBLCell widget) ] 
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNLHorizontalLayout: aBLUIHorizontalLayout [
	^ '(SpBoxLayout newHorizontal'
		,
			((aBLUIHorizontalLayout cell
				flatCollect: [ :cell | 
					' ' , ('' , (self visit: cell) removeSuffix: ';')
						,
							';' indentBy: 4 ])), ' yourself)'
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNLLayout: aBLLayout [

	^ self visitCSNLVerticalLayout: aBLLayout
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNLVerticalLayout: aBLUIVerticalLayout [
	^ '(SpBoxLayout newVertical'
		,
			((aBLUIVerticalLayout cell
				flatCollect: [ :cell | 
					' ' , ('' , (self visit: cell) removeSuffix: ';')
						,
							';' indentBy: 4 ]) removeLast; yourself), ')'
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNPage: aBLPage [
	| class |
	class := SpPresenter
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
				({aBLPage widgets . aBLPage businessPage} flatten flatCollect: [ :widget | ('' , (self visit: widget) removeSuffix: ';') ]).
	class compile: 'title' , String crlf , String tab , '^ ' , ('''' , (self protectString: (aBLPage title ifNil: [ '' ])) , '''').
	class instanceVariables do: [ :each | self createAccessorForVariable: each inClass: class ].
	initializeWidgetsExporter exportInitializeWidgetOfPage: aBLPage inClass: class.
	^ self visitCSNWidget: aBLPage
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNUIAbsoluteHeight: aBLUIAbsoluteHeight [
	^ aBLUIAbsoluteHeight attributeValue onlyNumbers
		ifEmpty: [ self visitCSNAttribute: aBLUIAbsoluteHeight ]
		ifNotEmpty: [ aBLUIAbsoluteHeight name , ': ' , aBLUIAbsoluteHeight attributeValue onlyNumbers ]
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNUIAbsoluteWidth: aBLUIAbsoluteWidth [
	^ aBLUIAbsoluteWidth attributeValue onlyNumbers
		ifEmpty: [ self visitCSNAttribute: aBLUIAbsoluteWidth ]
		ifNotEmpty: [ aBLUIAbsoluteWidth name , ': ' , aBLUIAbsoluteWidth attributeValue onlyNumbers]
]

{ #category : #api }
CSNSpec2Exporter >> visitCSNWidget: aBLWidget [
	^ '#' , (self computeAcceptedNameForVariableFrom: aBLWidget name uncapitalized)
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
CSNSpec2Exporter >> visitMooseModel: aMooseModel [
	aMooseModel allCSNPage do: [ :phase | self visit: phase ]
]
