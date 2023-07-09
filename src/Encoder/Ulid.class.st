Class {
	#name : #Ulid,
	#superclass : #Object,
	#instVars : [
		'timestamp',
		'payload'
	],
	#classVars : [
		'Collisions',
		'Crockford',
		'FirstByteMask',
		'Hex',
		'LastTime'
	],
	#category : #Encoder
}

{ #category : #accessing }
Ulid class >> << stringOrUlid [

	^ self basicNew initialize fromStream: stringOrUlid readStream 


]

{ #category : #accessing }
Ulid class >> <<? stringOrUlid [
	
	| str |
	
	str := stringOrUlid readStream. "only debug the import"

	^ self basicNew initialize enableDebug fromStream: str


]

{ #category : #accessing }
Ulid class >> initialize [

	Collisions := 0.
	FirstByteMask := self payloadOversizeMask.


]

{ #category : #accessing }
Ulid class >> new [

	^ (self basicNew)
			timestampMonotonic;
			payload;
			initialize
			


]

{ #category : #accessing }
Ulid class >> newAsap [

	^ (self basicNew)
			timestamp;
			payload;
			initialize
			


]

{ #category : #accessing }
Ulid class >> payloadBitsOversize [

  ^ (self payloadSize * 8) - (self  payloadEncodedSize * 5)


]

{ #category : #accessing }
Ulid class >> payloadEncodedSize [

	^ 14 "chars"


]

{ #category : #accessing }
Ulid class >> payloadOversizeMask [
	
  ^ 255 bitShift: (0 -  (self payloadBitsOversize))

]

{ #category : #accessing }
Ulid class >> payloadSize [

	^ 9 "bytes"


]

{ #category : #accessing }
Ulid class >> timestampEncodedSize [

	^ self timestampMillisEncodedSize + self timestampMicrosEncodedSize


]

{ #category : #accessing }
Ulid class >> timestampMicrosEncodedSize [

	^ 2 "chars"


]

{ #category : #accessing }
Ulid class >> timestampMillisEncodedSize [

	^ 10 "chars"


]

{ #category : #accessing }
Ulid >> <= b [

	"the random bytes are redundant"
	
	^ self timestamp <= b timestamp 
]

{ #category : #accessing }
Ulid >> asBytes [

  | micros  twoBits pl |
  
  pl := self payload.
  micros := self unixMicroseconds \\ 1000.
  twoBits := (micros bitAnd: 3) bitShift: 6.
  
	^ ByteArray
		new: 36
		streamContents: [ :s | 
		
			s nextPutAll: (self integerAsByteArray: self unixMilliseconds ofSize: 6).
			
			s nextPut: (micros // 4).

			s nextPut: ((pl at:1) bitAnd: twoBits).
			
			2 to: self class payloadSize do: [:n | s nextPut: (pl at:n) ].
			
		].
]

{ #category : #accessing }
Ulid >> asString [

	^ String 
		new: 30
		streamContents: 
			[ :s | 	
			
			s nextPutAll: self timestampMillisEncoded.
			s nextPutAll: self timestampMicrosEncoded.
	        self payloadEncodeOn: s.
	        
			].
	
]

{ #category : #accessing }
Ulid >> asUUID [

	"Return a String with my official representation, 32 lowercase hexadecimal digits, displayed in five groups separated by hyphens, in the form 8-4-4-4-12 for a total of 36 characters (32 alphanumeric characters and four hyphens)"

	^ String 
		new: 36 
		streamContents: [ :stringStream | self asUuidOn: stringStream ]
]

{ #category : #accessing }
Ulid >> asUuidString [

	"Return a String with my official representation, 32 lowercase hexadecimal digits, displayed in five groups separated by hyphens, in the form 8-4-4-4-12 for a total of 36 characters (32 alphanumeric characters and four hyphens)"

	^ String 
		new: 36 
		streamContents: [ :stringStream | self asUuidStringOn: stringStream ]
]

{ #category : #accessing }
Ulid >> asUuidStringOn: aStream [

	"Print my official representation, 32 lowercase hexadecimal digits, displayed in five groups separated by hyphens, in the form 8-4-4-4-12 for a total of 36 characters (32 alphanumeric characters and four hyphens) on aStream"

	| hex |
	
	hex := Hex encodeBytes: self asBytes.
	
	1 to: 8 do: [ :c | aStream nextPut: (hex at: c) ].
	aStream nextPut: $-.
	9 to: 12 do: [ :c | aStream nextPut: (hex at: c) ].
	aStream nextPut: $-.
	13 to: 16 do: [ :c | aStream nextPut: (hex at: c) ].
	aStream nextPut: $-.
	17 to: 20 do: [ :c | aStream nextPut: (hex at: c) ].
	aStream nextPut: $-.
	21 to: 32 do: [ :c | aStream nextPut: (hex at: c) ].


]

{ #category : #accessing }
Ulid >> collisions [

	^ Collisions
]

{ #category : #accessing }
Ulid >> displayStringOn: s [

	s nextPutAll: self timestampMillisEncoded.
	s nextPut: $-.
	s nextPutAll: self timestampMicrosEncoded.
	s nextPut: $-.
	self payloadEncodeOn: s.

]

{ #category : #accessing }
Ulid >> enableDebug [

	Crockford enableDebug	
]

{ #category : #accessing }
Ulid >> fromStream: str [


	timestamp := (Crockford on: str decodeIntegerIn: self class timestampMillisEncodedSize) * 1000 
		+ (Crockford on: str decodeIntegerIn: self class timestampMicrosEncodedSize) 
		+ 2177452800000000.
	
	payload := Crockford decodeAsBytes: (str next: self class payloadEncodedSize) startAt: self class payloadBitsOversize

	
	
]

{ #category : #accessing }
Ulid >> getRandomPayload [

	^ self payloadApplyMask: self getRandomPayload_InternalGenerator
]

{ #category : #accessing }
Ulid >> getRandomPayload_InternalGenerator [

	| bytes gen |
	
	gen := SharedRandom globalGenerator.

	bytes := ByteArray new: (self class payloadSize).
	
	1 to: bytes size do: [ :each |
		bytes at: each put: (gen nextInteger: 256) - 1.
	].
	

	^ bytes
]

{ #category : #accessing }
Ulid >> getRandomPayload_LcLibCrypto [

	^ LcLibCrypto uniqueInstance randomBytesOfSize: self class payloadSize.
]

{ #category : #accessing }
Ulid >> gtDebugFor: aView [
	<gtView>
	^ aView columnedList
		title: 'Debug';
		priority: 50;
		items: [ Crockford debug ifNil: [ #('debug not enabled') ]];
		"actionUpdateButtonTooltip: 'Update item list';"
		column: 'Step' 
			text: [ :eachItem :eachIndex | 
				eachIndex asRopedText foreground: Color gray ]
			width: 45;
		column: 'Item' 
			text: [ :eachItem | eachItem gtDisplayText glamorousCodeFont ].
]

{ #category : #accessing }
Ulid >> initialize [

	"although these are class vars, this resets the internal debug state"
	Crockford := BaseEncoder crockford.
	Hex := BaseEncoder hex.
	
]

{ #category : #accessing }
Ulid >> integerAsByteArray: anInteger
ofSize: aNumberOfBytes [

	| bytes int |
	bytes := ByteArray new: aNumberOfBytes.
	int := anInteger.
	aNumberOfBytes
		to: 1
		by: -1
		do:
			[:i | | byte |
			byte := int bitAnd: 16rFF.
			int := int bitShift: -8.
			bytes at: i put: byte].
	int ~= 0
		ifTrue: [self error: 'Loss of precision detected'].
	^bytes
]

{ #category : #accessing }
Ulid >> on: stream asBytes: int [

	int bytesCount to: 1 by: -1 do: [:digitIndex |
	
		stream nextPut: (self byteAt: digitIndex)
	].
		
		
]

{ #category : #accessing }
Ulid >> payload [

	^ payload ifNil: [ payload := self getRandomPayload]
]

{ #category : #accessing }
Ulid >> payloadApplyMask: bytes [

	"Trim the payload to fit the space available"
	
	^ bytes at: 1 put: (bytes first bitAnd: FirstByteMask); 
			yourself
	
	
]

{ #category : #accessing }
Ulid >> payloadEncodeOn: str [

    Crockford encodeRightBytes: self payload on: str   


	
]

{ #category : #accessing }
Ulid >> printOn: s [

	s << self class name.
	s << ' << '''.
	self displayStringOn: s.
	s << ''''
	
]

{ #category : #accessing }
Ulid >> printString [

	"avoid inheriting limited length printing"

	^ String streamContents: [ :s |
		self printOn: s
	]
	
]

{ #category : #accessing }
Ulid >> readStream [

	^ self asString readStream
]

{ #category : #accessing }
Ulid >> timestamp [

	^ timestamp ifNil: [ timestamp := Time primUTCMicrosecondsClock ]
]

{ #category : #accessing }
Ulid >> timestampMicrosEncoded [

    ^ (Crockford encodeInteger: (self unixMicroseconds \\ 1000)) 
			padLeftTo: self class timestampMicrosEncodedSize with: $0
]

{ #category : #accessing }
Ulid >> timestampMillisEncoded [

    ^ (Crockford encodeInteger: self unixMilliseconds) 
			padLeftTo: self class timestampMillisEncodedSize with: $0
]

{ #category : #accessing }
Ulid >> timestampMonotonic [

	^ timestamp ifNil: [ 
	
	
		 [ timestamp := Time primUTCMicrosecondsClock.
		   LastTime ~= timestamp ] whileFalse: [ Collisions := Collisions + 1 ]. 
	
		LastTime := timestamp.
		
		
	]
]

{ #category : #accessing }
Ulid >> unixEpoch [ 

	^ 2177452800000000

]

{ #category : #accessing }
Ulid >> unixMicroseconds [

	^ self utcMicroseconds - self unixEpoch
	
	


]

{ #category : #accessing }
Ulid >> unixMilliseconds [
	^ self unixMicroseconds // 1000
]

{ #category : #accessing }
Ulid >> unixSeconds [

	^ self unixMicroseconds // 1000000
]

{ #category : #accessing }
Ulid >> utcMicroseconds [

	^ self timestamp 
	
	


]

{ #category : #accessing }
Ulid >> utcSeconds [

	^ self utcMicroseconds // 1000000
]
