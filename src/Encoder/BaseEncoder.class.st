Class {
	#name : #BaseEncoder,
	#superclass : #Object,
	#instVars : [
		'table',
		'unitsMax',
		'shiftBy',
		'reverse',
		'debug',
		'name'
	],
	#classVars : [
		'Crockford',
		'Cypher',
		'Hex',
		'Hex32',
		'NanoId',
		'RFC4648',
		'ZBase32'
	],
	#category : #Encoder
}

{ #category : #accessing }
BaseEncoder class >> allBaseEncoders [
	
	^ self pragmasAllBaseEncoders collect: [ :p |
		self executeMethod:p method
	]
	
]

{ #category : #accessing }
BaseEncoder class >> asUuidString: bytes [

	"Print as uuid official representation, 32 lowercase hexadecimal digits, displayed in five groups separated by hyphens, in the form 8-4-4-4-12 for a total of 36 characters (32 alphanumeric characters and four hyphens) on aStream"

	| hex |

	hex := Hex encodeBytes: self asBytes.
	
	^ String 
		new: 36 
		streamContents: [ :stream | 
	
			1 to: 8 do: [ :c | stream nextPut: (hex at: c) ].
			stream nextPut: $-.
			9 to: 12 do: [ :c | stream nextPut: (hex at: c) ].
			stream nextPut: $-.
			13 to: 16 do: [ :c | stream nextPut: (hex at: c) ].
			stream nextPut: $-.
			17 to: 20 do: [ :c | stream nextPut: (hex at: c) ].
			stream nextPut: $-.
			21 to: 32 do: [ :c | stream nextPut: (hex at: c) ].

		]


]

{ #category : #accessing }
BaseEncoder class >> crockford [

	<baseEncoder>

    ^ Crockford ifNil: [ Crockford := (self newNamed: #crockford)
        bitsPerChar: 5;
    	table: '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    	normalize: 'abcdefghjkmnpqrstvwxyz' to: 'ABCDEFGHJKMNPQRSTVWXYZ';
    	normalize: 'OLIoli' to: '011011';
    	validateEncoder
      ]

]

{ #category : #accessing }
BaseEncoder class >> gtFoxFor: aView [

	<gtView>
	<gtClassView>

	| input items |
	
	input := 'The quick brown fox jumps over the lazy dog.' asByteArray.
	items := { 
		{ nil. #input. (String streamContents: [ :s | input asByteArray printElementsOn: s ]). ''. }.
	}, 
	(self allBaseEncoders collect: [ :encoder |
		{ 
			encoder.
			encoder name.
			encoder encodeBytes: input.
			(encoder decodeAsBytes: (encoder encodeBytes: input)) asString.
		}
	]).
	
	^ aView columnedList
		title: 'Fox';
		priority: 10;
		items: [ items ];
		in: [ :view |
			view column: 'Example' text: [ :ea | ea second ] width: 80.
			view column: 'Encode' text: [ :ea | ea third ].
			view column: 'Decode As String' text: [ :ea | ea fourth ].
		];
		send: [ :ea | ea first ifNotNil: [ :encoder | encoder enableDebug encodeBytes: input; yourself ] ];
		yourself

]

{ #category : #accessing }
BaseEncoder class >> hex [
	<baseEncoder>

    ^ Hex ifNil: [ Hex := (self newNamed: #hex)
        bitsPerChar: 4;
    	table: '0123456789abcdef';
    	normalize: 'ABCDEFoOlI' to: 'abcdef0011';
    	validateEncoder
      ]

]

{ #category : #accessing }
BaseEncoder class >> hex32 [
 	<baseEncoder>

    ^ Hex32 ifNil: [ Hex32 := (self newNamed: #hex32)
        bitsPerChar: 5;
    	table: '0123456789ABCDEFGHIJKLMNOPQRSTUV';
    	validateEncoder
      ]

]

{ #category : #accessing }
BaseEncoder class >> initialize [

	Crockford := nil.
	Hex := nil.
	RFC4648 := nil.
	Hex := nil.
	ZBase32 := nil.
	


	

	
]

{ #category : #accessing }
BaseEncoder class >> nanoId [
	<baseEncoder>

    "https://github.com/ulid/spec/issues/47#issuecomment-784721867"
    "http://www.java2s.com/example/java-utility-method/base64/base64character-int-number-1acdf.html"
	"https://cljdoc.org/d/nano-id/nano-id/1.0.0/doc/readme"
	
    ^ NanoId ifNil: [ NanoId := (self newNamed: #nanoId)
        bitsPerChar: 6;
    	table: '-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz';
    	validateEncoder
      ] 

]

{ #category : #accessing }
BaseEncoder class >> newNamed: aString [ 

	^ self basicNew name: aString
]

{ #category : #accessing }
BaseEncoder class >> pragmasAllBaseEncoders [
	
	^ self withAllSubclasses flatCollect: [ :cl | 
	
		cl pragmasBaseEncoders
			 
	]
	
]

{ #category : #accessing }
BaseEncoder class >> pragmasBaseEncoders [
	
	^ Pragma allNamed: #baseEncoder in: self class

]

{ #category : #accessing }
BaseEncoder class >> rfc4648 [
	<baseEncoder>

    ^ RFC4648 ifNil: [ RFC4648 := (self newNamed: #rfc4648)
        bitsPerChar: 5;
    	table: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
        normalize: 'abcdefghijklmnopqrstuvwxyz' to: 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        normalize: '10' to: 'IO';
    	validateEncoder
      ]

]

{ #category : #accessing }
BaseEncoder class >> zbase32 [

	<baseEncoder>

"
https://philzimmermann.com/docs/human-oriented-base-32-encoding.txt
"
    ^ ZBase32 ifNil: [ ZBase32 := (self newNamed: #zbase32)
        bitsPerChar: 5;
    	table: 'ybndrfg8ejkmcpqxot1uwisza345h769';
    	normalize: 'YBNDRFGEJKMCPQXOTUWISZAH' to: 'ybndrfgejkmcpqxotuwiszah';
    	normalize: '20lL' to: 'zo11';
    	validateEncoder
      ]

]

{ #category : #accessing }
BaseEncoder >> bitsPerChar: nBits [
	shiftBy := nBits.
	unitsMax := (2 raisedTo: nBits) - 1.
]

{ #category : #accessing }
BaseEncoder >> copyAsRandomCypher [

	^ self deepCopy privateAsRandomCypher


]

{ #category : #accessing }
BaseEncoder >> debug [

	^ debug
	
]

{ #category : #accessing }
BaseEncoder >> debug: anObject [
	debug := anObject
]

{ #category : #accessing }
BaseEncoder >> debug: k msg: strBlk [

	debug ifNil: [ ^self ].
	
	debug add: (k,': ', strBlk value asString).
	
	
	
]

{ #category : #accessing }
BaseEncoder >> debugPos: pos buf: buf [
	 self
		debug: 'pos'
		msg: pos asString.
	 self
		debug: 'buf'
		msg: [ ((buf asInteger bitString last: 16) copyFrom: 1 to: 16 - pos) , '|',           		
				((buf bitString last: 16) copyFrom: 17 - pos to: 16) ]
]

{ #category : #accessing }
BaseEncoder >> decodeAsBytes: aString [

	^ self decodeAsBytes: aString startAt: 0




]

{ #category : #accessing }
BaseEncoder >> decodeAsBytes: aString startAt: start [

	self debug: 'decode bytes' msg: aString.
	
	^ ByteArray streamContents: [ :str |

	
		(self decodeFrom: aString readStream 
		      onBytes: str startAt: start)
	
	].
	



]

{ #category : #accessing }
BaseEncoder >> decodeFrom: in onBytes: bytes [
	
	^ self decodeFrom: in onBytes: bytes startAt: 0
		
]

{ #category : #accessing }
BaseEncoder >> decodeFrom: in onBytes: bytes startAt: start [
	| buf pos out next atEnd |
	
	pos := start.
	buf := 0.
	atEnd :=false.

	[ next := in next ifNil: [ atEnd := true. 0 ] ifNotNil: [ :char | self reverseAt: char ].
	
	  next <= unitsMax ifTrue: [
				 
	  self debug: 'in'
			msg: [ (self tableAt: next) asString , ' ' , next asString , ' ('
								, (next bitString last: shiftBy) , ')' ].

			buf := (buf bitShift: shiftBy) + next.
			pos := pos + shiftBy.

			self debugPos: pos buf: buf.

			pos > 7
			ifTrue: [ bytes nextPut: (out := (buf bitShift: 8 - pos) bitAnd: 255).

			buf := buf bitAnd: 255.
			pos := pos - 8.

			self debug: 'out'
				msg: [ out asCharacter asString , ' ' , out asString , ' (' , (out bitString last: 8) , ')' ].
							
			self debugPos: pos buf: buf.
		]
	].
			
	atEnd ] whileFalse: [ ]
							
		
]

{ #category : #accessing }
BaseEncoder >> decodeInteger: aString [

    | int |

    self debug: 'decode integer' msg: aString.

    int := 0.
    
	 (aString copy translateWith: reverse) withIndexDo: [ :num :n |
	 
	 	num asciiValue <= unitsMax ifTrue: [
			  n ~= 1 ifTrue: [ int := int * (unitsMax + 1) ].
	  		int := int + num asciiValue.
	  		
	  		self debug: 'int' msg: [ int bitString , ' ', int asString ].

	     ]
	 ].
	 
	 
	^ int
]

{ #category : #accessing }
BaseEncoder >> enableDebug [

	^ self copy 
		debug: OrderedCollection new;
		yourself
	
]

{ #category : #accessing }
BaseEncoder >> encodeBytes: anArray [ 

^ String streamContents: [ :str |

	self encodeLeftBytes: anArray on: str pad: true.
  ]

	


]

{ #category : #accessing }
BaseEncoder >> encodeBytes: anArray startingAtBit: n pad: writeAllData [

    "Without padding only completed characters are output.
     padding ensures all data is written
     
     The first bit is bit 0 (simplifes the math)"
    
	|pos rem a b |

	pos := n // 8.
	rem := n \\ 8.
	
	a := anArray at: pos + 1.
	b := anArray at: (pos + 2) ifAbsent: [ 
	
		((rem + shiftBy) < 8 or: [ writeAllData ]) ifTrue: 0 ifFalse:[ ^ '' ]
	].
	
	self debug: 'input' msg: [ a asCharacter asString,b asCharacter asString,' (', (a bitString last: 8), (b bitString last: 8), ') ' ]. 
	
	a := (a bitShift: 8) + b.
	
	a := a bitShift: (rem + shiftBy - 16).
	
	b := a bitAnd: unitsMax.
	
	self debug: 'output' msg: [ (self tableAt: b) asString,' (' , ('--------' first: rem), (b bitString last: shiftBy), ('-----------' first: (11 - rem)), ')' ].
	
	^ self tableAt: b
	


]

{ #category : #accessing }
BaseEncoder >> encodeInteger: anInt [

	| int char |
	
	self debug: 'encode integer' msg: anInt.

	int := anInt.

	^ (String  streamContents: [ :str |
	 	[ 
	 	
	 	char := self tableAt: (int bitAnd: unitsMax).
	 	
	 	self debug: 'int' msg: [ int bitString , ' >', char asString ].
	 	
	 	str nextPut: char.
	 	 
	 	  (int := int  bitShift: shiftBy negated) = 0 ]
	 	   
	 		whileFalse: [ ].
	]) reverse
	 

]

{ #category : #accessing }
BaseEncoder >> encodeLeftBytes: anArray on: str pad: writeAllData [

	"encode bits in shiftBy chunks, starting on at the MSBs dropping the LSBs"

	| written |
	
	self debug: 'encode bytes (L)' msg: [ anArray displayString , '(shiftBy:' , shiftBy asString ,')'].
	
	written := 0.
	
	0 to: ((anArray size * 8) - 1) by: shiftBy do: [ :n |

		str << (self encodeBytes: anArray startingAtBit: n pad: writeAllData).
		written := written + 1.
	].
	
	^ written
	


]

{ #category : #accessing }
BaseEncoder >> encodeRightBytes: anArray on: str [ 


	"encode bits in shiftBy chunks dropping the MSBs"


	| written start stop |
	
	self debug: 'encode bytes (R)' msg: [ anArray displayString ].
	
	written := 0.
	
	stop := anArray size * 8.
	start := stop \\ shiftBy.
	
	start to: (stop - 1) by: shiftBy do: [ :n |

		str << (self encodeBytes: anArray startingAtBit: n pad: true).
		written := written + 1.
	].
	
	^ written
	


]

{ #category : #accessing }
BaseEncoder >> gtDebugFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Debug';
		priority: 50;
		items: [ debug ifNil: [ #('debug not enabled') ]];
		"actionUpdateButtonTooltip: 'Update item list';"
		column: 'Step' 
			text: [ :eachItem :eachIndex | 
				eachIndex asRopedText foreground: Color gray ]
			width: 45;
		column: 'Item' 
			text: [ :eachItem | eachItem gtDisplayText glamorousCodeFont ].
]

{ #category : #accessing }
BaseEncoder >> gtDemoFor: aView [
	<gtView>
	| gen integers |
	
	gen := SharedRandom globalGenerator.

	integers := Array new: 256.

	1 to: 15 do: [ :n | integers at: n put: n * 273 ].
	16
		to: 200
		do: [ :n | integers at: n put: (gen nextInteger: SmallInteger maxVal) ].
		
	201 to: 256 do: [ :n | integers at: n put: ((gen nextInteger: SmallInteger maxVal) * (gen nextInteger: SmallInteger maxVal) + 1) ].

	^ aView columnedList
		title: 'Demo';
		priority: 70;
		items: [ 0 to: 255 ];
		column: '#'
			text: [ :n | n asRopedText foreground: Color gray ]
			width: 45;
		column: 'Integer'
			text: [ :n | 
				(integers at: (n + 1))
					-> (self encodeInteger: (integers at: (n + 1)))  ];
		column: 'Decode'
			text: [ :n | self decodeInteger: (self encodeInteger: (integers at: (n+1))) ];
		yourself
]

{ #category : #accessing }
BaseEncoder >> integer: anInteger as: nBits bitArrayOfSize: aNumberOfBytes [ 

	| mask bytes int |

	mask := (2 raisedTo: nBits) - 1.
	bytes := ByteArray new: aNumberOfBytes.
	int := anInteger.
	
	self debug: 'integer' 
		msg: [ int asString, ' > (', nBits asString , ' bit Array of size ', aNumberOfBytes asString,')' ].

	aNumberOfBytes
		to: 1
		by: -1
		do:
			[:i | | byte |
			byte := int bitAnd: mask.
			
			self debug: 'int' msg: [ int bitString , ' >', byte asString ].
	 	

			int := int bitShift: (8 negated).
			bytes at: i put: byte].
			

	int ~= 0
		ifTrue: [self error: 'Loss of precision detected'].
	^bytes
]

{ #category : #accessing }
BaseEncoder >> makeCypher [

 "	self askUser: 'Are you sure'. "
	Cypher := self copyAsRandomCypher.


]

{ #category : #accessing }
BaseEncoder >> name [
	^ name
]

{ #category : #accessing }
BaseEncoder >> name: anObject [
	name := anObject
]

{ #category : #accessing }
BaseEncoder >> normalize: these to: those [ 

	these with: those do: [ :a :b |
		reverse at: (a asciiValue + 1) put: (self reverseAt: b)
	].
	
]

{ #category : #accessing }
BaseEncoder >> on: stream decodeIntegerIn: nChars [  

    
    | int num n char |

    self debug: 'decode integer from chars' msg: nChars.

    int := 0.
    n := 1.
    
    [ stream atEnd or: [ n > nChars ] ] whileFalse: [
	 
	     char := stream next.
	     
	 	(num := self reverseAt: char) <= unitsMax ifTrue: [
	 
			  int := int * (unitsMax + 1).
	  		int := int + num.
	  		n := n + 1.
	  		
	  		self debug: 'int' msg: [ char asString, '> ',int bitString , ' ', int asString ].
	     ]
	 ].
	 
	^ int
]

{ #category : #accessing }
BaseEncoder >> printOn: str [

	super printOn: str.
	str << ' (' << name << ')'.
]

{ #category : #accessing }
BaseEncoder >> privateAsRandomCypher [

	|newTable newReverse |
	
	name := name , '_shuffled'.
	newTable := table shuffled.
	newReverse := reverse collect: [ :val | 
	
		val <= table size 
		ifTrue: [
			 (newTable indexOf: (table at: (val + 1))) - 1
		] 
		ifFalse: [ 255 ].
		
	].
	
	table := newTable.
	reverse := newReverse.


]

{ #category : #accessing }
BaseEncoder >> reverseAt: char [

	^ reverse at: char asciiValue + 1


	

	
]

{ #category : #accessing }
BaseEncoder >> table: chars [

	self assert: chars size equals: unitsMax + 1.
	self assert: (2 raisedTo: shiftBy) equals: unitsMax + 1.
	
	table := chars.
	reverse := ByteArray new: 256 withAll: 255.
	table withIndexDo: [ :ch  :n | reverse at: (ch asciiValue + 1) put: n - 1 ].
	
	
]

{ #category : #accessing }
BaseEncoder >> tableAt: n [

	^ table at: n + 1


	

	
]

{ #category : #accessing }
BaseEncoder >> validate: string [

	^ string allSatisfy: [ :ea | table includes: ea ]
]

{ #category : #accessing }
BaseEncoder >> validateEncoder [

(0 to: 255) collect: [ :b |

	self assert: (self  decodeInteger: (self encodeInteger: (b * 21))) equals: (b * 21).

].

]
