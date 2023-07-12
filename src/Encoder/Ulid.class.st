"
A Variant on the standard Ulid, that is better (by some definiton of better) and backwards compatible.

The standard Ulid is 10 bytes time and 16 bytes randomness with a bit of non-randomness and
unneccessary complexity thrown in as a counter, that is likely to be needed to compensate for
the coarse clock.

This variant Ulid is 
	
	`<10 chars milliseconds time>` `<2 chars microseconds>` `<14 chars randomness>`.

	This slightly quirky pattern retains essential backwards compatability with the canonical form.

Loosing 10 bits of randomness is more than made up for by the 1000x finer clock, chances of collisions decrease.

Pharo is able to generate and collect > 380000/ulids per second (on a 2013 Macbook)  Parsing rate is 100k/sec

At this rate the micro-second time resolution of this implementation is sufficient to provide a guarentee of lexical sorting that 
betters the original's lack of sincerity.

If it doesnt, then the solution is to simply slow downor do something else!! 
By default this implementation resists creating 2 timestamps within a single microsecond, 
and thus guarentees both a monotonic clock,  and lexical sorting, without any of the usual compromises.

If you needed faster, then likely you wouldnt be using smalltalk. 
(Some python ulid implementations boast 5000/sec)

380000/sec raw instanciations collecting (without printing/encoding).
150000/sec with encodings
 
 refs:
 https://wvlet.org/airframe/docs/airframe-ulid
airframe-ulid can produce 5 million ULIDs / sec. 
As of April 2021, airframe-ulid is the fastest ULID generator in Scala:


https://github.com/Sofya2003/ULID-with-sequence
"
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
		'LastTime'
	],
	#category : #Encoder
}

{ #category : #accessing }
Ulid class >> << stringOrUlid [

	^ self basicNew initialize fromStream: stringOrUlid readStream 


]

{ #category : #accessing }
Ulid class >> <<< bytesOrHexString [

	^ self basicNew initialize 
		fromBytes: (bytesOrHexString isString 
						ifTrue: [ BaseEncoder hex decodeAsBytes: bytesOrHexString ]
						ifFalse: bytesOrHexString)


]

{ #category : #accessing }
Ulid class >> <<<? bytesOrHexString [

	| bytes hex |
	
	bytes := bytesOrHexString isString ifTrue: [
	    	
	    	hex := BaseEncoder hex enableDebug.
	    	
			hex  decodeAsBytes: bytesOrHexString.
			
			] ifFalse: bytesOrHexString.


	^ self basicNew initialize enableDebug
	    in: [ :me | 
	    	
	    	Crockford debug: hex debug.
	    	Crockford debug: 'bytes' msg: bytes printString
	    ];
		fromBytes: bytes
		
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

	self timestamp == b timestamp ifTrue: [ ^ self payload <= b payload ].
	
	^ self timestamp < b timestamp
]

{ #category : #accessing }
Ulid >> = b [

	^ self timestamp == b timestamp ifFalse: false ifTrue: [ self payload = b payload ]
]

{ #category : #accessing }
Ulid >> asBytes [

  | micros  twoBits pl |
  
  pl := self payload.
  micros := self unixMicroseconds \\ 1000.

	^ ByteArray
		new: 36
		streamContents: [ :s | 
		
			s nextPutAll: (Crockford integer: self unixMilliseconds as: 8 bitArrayOfSize: 6).
			
			s nextPut: (micros // 4).
  		
  		  twoBits := (micros bitAnd: 3) bitShift: 6.
  
			s nextPut: ((pl at:1) + twoBits).
			
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
Ulid >> asUuidString [

	^ BaseEncoder asUuidString: self asBytes.
	

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

	Crockford := Crockford enableDebug.
	
]

{ #category : #accessing }
Ulid >> fromBytes: bytes [

	| millis micros twoBits |

	millis := LargePositiveInteger new: 6.
	millis byteAt: 1 put: (bytes at: 6).
	millis byteAt: 2 put: (bytes at: 5).
	millis byteAt: 3 put: (bytes at: 4).
	millis byteAt: 4 put: (bytes at: 3).
	millis byteAt: 5 put: (bytes at: 2).
	millis byteAt: 6 put: (bytes at: 1).

	Crockford debug: 'millis' msg: [ millis asString, ' ', millis asByteArray printString ].

	micros := bytes at: 7.  "8 bits" 
	micros := micros bitShift: self class payloadBitsOversize.
	
	Crockford debug: 'micros' msg: [ micros asString, ' [',(bytes at: 7) asString,'<<2] (', (micros bitString last: 8), ' | ??)' ].

	twoBits := (bytes at: 8) bitShift: (self class payloadBitsOversize - 8).
	
	micros := micros + twoBits.
	
	self unixMillis: millis micros: micros.
	
	Crockford debug: 'micros' msg: [ micros asString, ' (', (micros bitString last: 10),')' ].

	Crockford debug: 'timestamp' msg: [ self timestamp asString ].

	
	payload := bytes copyFrom: 8 to: self class payloadSize + 7.
	
	Crockford debug: 'payload (+2 MSBs)' msg: [ payload asByteArray printString ].

	payload := self payloadApplyMask: payload.
	
	Crockford debug: 'payload (-2 MSBs)' msg: [ payload asByteArray printString ].


	
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
Ulid >> hash [

	^ self timestamp hash bitXor: self payload hash
]

{ #category : #accessing }
Ulid >> initialize [

	"reset to the non-debug default"
	Crockford := BaseEncoder crockford.
	
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
Ulid >> unixMillis: millis micros: micros [
	timestamp := (millis * 1000) + micros + self unixEpoch
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
