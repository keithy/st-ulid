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
		'Last'
	],
	#category : #Encoder
}

{ #category : #accessing }
Ulid class >> initialize [

	Collisions := 0.
	FirstByteMask := self payloadOversizeMask.


]

{ #category : #accessing }
Ulid class >> payloadBitsOversize [

  ^ (self payloadSize * 8) - (self  payloadEncodedSize * 5)


]

{ #category : #accessing }
Ulid class >> payloadOversizeMask [
	
  ^ 255 bitShift: (0 -  (self payloadBitsOversize))

]

{ #category : #accessing }
Ulid >> asBytes [

	^ ByteArray 
		new: 36
		streamContents: 
			[ :s | 	
			
			self on: s bits: 48 int: (self unixMicroseconds \\ 1000)
			
			"need to shift one into the other"
			self on: s bits: 10 int: (self unixMicroseconds // 1000)
			self on: s bits: 70 int: self payload.
			
			].
	
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

	1 to: 4 do: [ :i | (self at: i) printLowercaseHexByteOn: aStream ].
	aStream nextPut: $-.
	5 to: 6 do: [ :i | (self at: i) printLowercaseHexByteOn: aStream ].
	aStream nextPut: $-.
	7 to: 8 do: [ :i | (self at: i) printLowercaseHexByteOn: aStream ].
	aStream nextPut: $-.
	9 to: 10 do: [ :i | (self at: i) printLowercaseHexByteOn: aStream ].
	aStream nextPut: $-.
	11 to: 16 do: [ :i | (self at: i) printLowercaseHexByteOn: aStream ]
]

{ #category : #accessing }
Ulid >> on: stream asBytes: int [

	int bytesCount to: 1 by: -1 do: [:digitIndex |
	
		stream nextPut: (self byteAt: digitIndex)
	].
		
		
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
