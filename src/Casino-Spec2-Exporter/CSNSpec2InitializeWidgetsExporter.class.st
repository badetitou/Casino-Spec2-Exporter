Class {
	#name : #CSNSpec2InitializeWidgetsExporter,
	#superclass : #CSNModelExporter,
	#instVars : [
		'mainExporter'
	],
	#category : #'Casino-Spec2-Exporter'
}

{ #category : #accessing }
CSNSpec2InitializeWidgetsExporter >> computeWidgetName: aWidget [
	^ self mainExporter computeAcceptedNameForVariableFrom: aWidget name
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> exportInitializeWidgetOfBusinessPage: aBLBuisinessPage inClass: aClass [
	aClass compile: 'initializeWidgets
	', ((self recursiveLocalWidgetOfBLBusinessPage: aBLBuisinessPage) flatCollect: [:widget | (self visit: widget), '.', String crlf, String tab])
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> exportInitializeWidgetOfPage: aBLPage inClass: aClass [
	aClass compile: 'initializeWidgets
	', ((self recursiveLocalWidgetOfPage: aBLPage) flatCollect: [:widget | (self visit: widget), '.', String crlf, String tab])
]

{ #category : #accessing }
CSNSpec2InitializeWidgetsExporter >> mainExporter [
	^ mainExporter
]

{ #category : #accessing }
CSNSpec2InitializeWidgetsExporter >> mainExporter: anObject [
	mainExporter := anObject
]

{ #category : #'private - utilities' }
CSNSpec2InitializeWidgetsExporter >> protectString: aString [
	^ self mainExporter protectString: aString
]

{ #category : #accessing }
CSNSpec2InitializeWidgetsExporter >> recursiveLocalWidgetOfBLBusinessPage: aBLBusinessPage [
	^ (aBLBusinessPage widgets collect: #localWidgets) flattened
		reject: [ :widget | widget isKindOf: CSNUIPanel ]
]

{ #category : #accessing }
CSNSpec2InitializeWidgetsExporter >> recursiveLocalWidgetOfPage: aBLPage [
	^ aBLPage localWidgets flattened reject: [:widget | widget isKindOf: CSNUIPanel ]
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitAttribute: aBLAttribute [
	^ ''
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitMooseModel: aMooseModel [
	self shouldNotImplement 
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitPage: aBLPage [
	^ aBLPage name uncapitalized , ' := (self instantiate: '
		,self mainExporter prefix, aBLPage name capitalized , ')'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitPageMetier: aBLBusinessPage [
	^ aBLBusinessPage name uncapitalized , ' := (self instantiate: '
		, self mainExporter prefix , (aBLBusinessPage name capitalized, aBLBusinessPage mooseID asString) , ')'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIButton: aBLUIButton [
	^ (self computeWidgetName: aBLUIButton) , ' := self newButton '
		,
			(aBLUIButton attributes
				flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ])
		, 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIContainer: aBLUIContainer [
	^ (self computeWidgetName: aBLUIContainer)
		, ' := (self instantiate: NullPresenter)'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIDisabled: aBLUIDisabled [
	^ 'disable;'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIInput: aBLUIInput [
	^ (self computeWidgetName: aBLUIInput) , ' := self newTextInput '
		, (aBLUIInput attributes flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ]) , 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIInputCheckbox: aBLUIInputCheckbox [
	^ (self computeWidgetName: aBLUIInputCheckbox) , ' := self newCheckBox '
		, (aBLUIInputCheckbox attributes flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ]) , 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIInputPassword: aBLUIInputPassword [
	^ (self computeWidgetName: aBLUIInputPassword)
		,
			' := self newTextInput 
		encrypted: true;' , (aBLUIInputPassword attributes flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ])
		, 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIInputText: aBLUIInputText [
	^ (self computeWidgetName: aBLUIInputText) , ' := self newTextInput '
		, (aBLUIInputText attributes flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ]) , 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUILabel: aBLUILabel [
	^ 'label: ''' , (self protectString: aBLUILabel attributeValue) , ''';'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUILink: aBLUILink [
	^ (self computeWidgetName: aBLUILink) , ' := self newLabel '
		, (aBLUILink attributes flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ]) , 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIList: aBLUIList [
	^ (self computeWidgetName: aBLUIList) , ' := self newList '
		, (aBLUIList attributes flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ]) , 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIParagraph: aBLUIParagraph [
	^ (self computeWidgetName: aBLUIParagraph) , ' := self newLabel '
		, (aBLUIParagraph attributes flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ]) , 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIPlaceholder: aBLUIPlaceholder [
	^ 'placeholder: ''' , (self protectString: aBLUIPlaceholder attributeValue) , ''';'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUISelect: aBLUISelect [
	^ (self computeWidgetName: aBLUISelect) , ' := self newDropList '
		, (aBLUISelect attributes flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ]) , 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUITextarea: aBLUITextarea [
	^  (self computeWidgetName: aBLUITextarea) , ' := self newText '
		, (aBLUITextarea attributes flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ]) , 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUITitle: aBLUITitle [
	^ 'help: ''' , (self protectString: aBLUITitle attributeValue) , ''';'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUITree: aBLUITree [
	^  (self computeWidgetName: aBLUITree) , ' := self newTable '
		, (aBLUITree attributes flatCollect: [ :attribute | (self visit: attribute) , String crlf , String tab , String tab ]) , 'yourself'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitUIValue: aBLUIValue [
	^ 'text: ''' , (self protectString: aBLUIValue attributeValue) , ''';'
]

{ #category : #visiting }
CSNSpec2InitializeWidgetsExporter >> visitWidget: aBLWidget [
	^ ' "not handle -->  ' , (self computeWidgetName: aBLWidget) , '"'
]
